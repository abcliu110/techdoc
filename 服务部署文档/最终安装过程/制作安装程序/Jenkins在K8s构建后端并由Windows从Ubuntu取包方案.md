# Jenkins 在 K8s 构建后端并由 Windows 从 Ubuntu 取包方案

## 1. 当前环境

- Ubuntu 物理机 IP：`192.168.1.119`
- Ubuntu 用户：`jj`
- Jenkins 部署在 RKE2 Kubernetes 集群中
- 构建产物保存目录：`/data/backend-build-output/01-nms4pos-java`
- SSH 凭据复用前端的 `ubuntu-output-ssh-key`

## 2. Ubuntu 物理机准备

```bash
sudo mkdir -p /data/backend-build-output/01-nms4pos-java
sudo chown -R jj:jj /data/backend-build-output
```

## 3. 产物目录说明

老脚本（Windows xcopy）对应关系：

| 老脚本目录 | Ubuntu 目录 | 来源模块 |
|---|---|---|
| `libs/` | `/data/backend-build-output/01-nms4pos-java/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/` | pos3boot-app/target/libs、pos3boot-app.jar、pos4cloud-api.jar、pos5sync-api.jar |
| `printerlibs/` | `/data/backend-build-output/01-nms4pos-java/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/` | pos10printer-app/target/libs、pos10printer-app.jar |
| `libs6/` | `/data/backend-build-output/01-nms4pos-java/nms4cloud-pos6monitor/target/` | pos6monitor.jar |

## 4. Nexus 凭据配置

在 Jenkins 中添加凭据：

- 类型：`Username with password`
- ID：`nexus-credentials`
- 用户名/密码：Nexus 账号

## 5. Jenkins Pipeline 最终版

```groovy
def generateMavenSettings() {
    sh """
        cat > \${MAVEN_SETTINGS} <<EOF
<settings>
  <mirrors>
    <mirror>
      <id>nexus-mirror</id>
      <mirrorOf>*</mirrorOf>
      <url>\${NEXUS_URL}/repository/\${NEXUS_REPO_GROUP}/</url>
    </mirror>
  </mirrors>
  <servers>
    <server>
      <id>nexus-mirror</id>
      <username>\${NEXUS_USER}</username>
      <password>\${NEXUS_PASS}</password>
    </server>
    <server>
      <id>nexus-releases</id>
      <username>\${NEXUS_USER}</username>
      <password>\${NEXUS_PASS}</password>
    </server>
    <server>
      <id>nexus-snapshots</id>
      <username>\${NEXUS_USER}</username>
      <password>\${NEXUS_PASS}</password>
    </server>
  </servers>
  <profiles>
    <profile>
      <id>nexus-profile</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <repositories>
        <repository>
          <id>nexus-mirror</id>
          <url>\${NEXUS_URL}/repository/\${NEXUS_REPO_GROUP}/</url>
          <releases><enabled>true</enabled></releases>
          <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
            <checksumPolicy>warn</checksumPolicy>
          </snapshots>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>nexus-mirror</id>
          <url>\${NEXUS_URL}/repository/\${NEXUS_REPO_GROUP}/</url>
          <releases><enabled>true</enabled></releases>
          <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
          </snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
</settings>
EOF
    """
}

pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-21
    command:
    - cat
    tty: true
    resources:
      requests:
        cpu: 1000m
        memory: 2Gi
      limits:
        cpu: 4000m
        memory: 4Gi
    env:
    - name: MAVEN_OPTS
      value: "-Xmx2048m -XX:+UseG1GC -XX:MaxMetaspaceSize=512m"
"""
    }
  }

  parameters {
    choice(
      name: 'BUILD_MODULE',
      choices: 'all\npos3boot\npos6monitor\npos10printer',
      description: '选择构建模块'
    )
    string(
      name: 'GIT_BRANCH',
      defaultValue: 'master',
      description: 'Git 分支'
    )
    booleanParam(
      name: 'SKIP_TESTS',
      defaultValue: true,
      description: '跳过单元测试'
    )
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
  }

  environment {
    MAVEN_SETTINGS     = '/tmp/maven-settings.xml'
    NEXUS_URL          = 'http://nexus.nexus:8081'
    NEXUS_REPO_GROUP   = 'maven-public'
    NEXUS_CRED_ID      = 'nexus-credentials'

    GIT_CREDENTIAL_ID  = 'aliyun-codeup-token'
    GIT_REPO_URL       = 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/nms4cloud-pos-java/nms4pos.git'

    UBUNTU_HOST        = '192.168.1.119'
    UBUNTU_USER        = 'jj'
    SSH_CREDENTIALS_ID = 'ubuntu-output-ssh-key'
    REMOTE_BASE        = '/data/backend-build-output/01-nms4pos-java'
  }

  stages {

    stage('代码检出') {
      steps {
        container('maven') {
          script {
            withCredentials([usernamePassword(
              credentialsId: "${NEXUS_CRED_ID}",
              usernameVariable: 'NEXUS_USER',
              passwordVariable: 'NEXUS_PASS'
            )]) {
              generateMavenSettings()
            }
          }
          checkout([
            $class: 'GitSCM',
            branches: [[name: "*/${params.GIT_BRANCH}"]],
            extensions: [
              [$class: 'CloneOption', depth: 1, shallow: true, timeout: 20]
            ],
            userRemoteConfigs: [[
              credentialsId: "${GIT_CREDENTIAL_ID}",
              url: "${GIT_REPO_URL}"
            ]]
          ])
        }
      }
    }

    stage('拉取 pos3boot 静态资源') {
      when {
        expression { params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos3boot' }
      }
      steps {
        container('maven') {
          withCredentials([sshUserPrivateKey(
            credentialsId: "${SSH_CREDENTIALS_ID}",
            keyFileVariable: 'SSH_KEY'
          )]) {
            script {
              def sshOpts = "-i \$SSH_KEY -o StrictHostKeyChecking=no"
              def remoteStaticDir = "/data/frontend-build-output/01-nms4pos-ui/app/pos4desktop/www"
              def localStaticDir = "nms4cloud-pos3boot/nms4cloud-pos3boot-app/src/main/resources/static"

              sh """
                set -e
                command -v ssh >/dev/null 2>&1
                command -v scp >/dev/null 2>&1
                ssh ${sshOpts} ${UBUNTU_USER}@${UBUNTU_HOST} "test -d ${remoteStaticDir}"
                rm -rf ${localStaticDir}
                mkdir -p ${localStaticDir}
                scp ${sshOpts} -r ${UBUNTU_USER}@${UBUNTU_HOST}:${remoteStaticDir}/* ${localStaticDir}/
              """
            }
          }
        }
      }
    }

    stage('Maven 构建') {
      steps {
        container('maven') {
          script {
            def skipTests = params.SKIP_TESTS ? '-Dmaven.test.skip=true' : ''
            if (params.BUILD_MODULE == 'all') {
              sh "mvn clean install ${skipTests} -s ${MAVEN_SETTINGS}"
            } else {
              sh "mvn clean install -pl nms4cloud-${params.BUILD_MODULE} -am ${skipTests} -s ${MAVEN_SETTINGS}"
            }
          }
        }
      }
    }

    stage('上传产物到 Ubuntu') {
      steps {
        container('maven') {
          withCredentials([sshUserPrivateKey(
            credentialsId: "${SSH_CREDENTIALS_ID}",
            keyFileVariable: 'SSH_KEY'
          )]) {
            script {
              def sshOpts = "-i \$SSH_KEY -o StrictHostKeyChecking=no"

              if (params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos3boot') {
                sh """
                  set -e
                  ssh ${sshOpts} ${UBUNTU_USER}@${UBUNTU_HOST} "rm -rf ${REMOTE_BASE}/nms4cloud-pos3boot && mkdir -p ${REMOTE_BASE}/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs"
                  scp ${sshOpts} nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/
                  scp ${sshOpts} nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/nms4cloud-pos3boot-app-*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/
                  ssh ${sshOpts} ${UBUNTU_USER}@${UBUNTU_HOST} "mkdir -p ${REMOTE_BASE}/nms4cloud-pos4cloud/nms4cloud-pos4cloud-api/target"
                  scp ${sshOpts} nms4cloud-pos4cloud/nms4cloud-pos4cloud-api/target/nms4cloud-pos4cloud-api-*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos4cloud/nms4cloud-pos4cloud-api/target/
                  ssh ${sshOpts} ${UBUNTU_USER}@${UBUNTU_HOST} "mkdir -p ${REMOTE_BASE}/nms4cloud-pos5sync/nms4cloud-pos5sync-api/target"
                  scp ${sshOpts} nms4cloud-pos5sync/nms4cloud-pos5sync-api/target/nms4cloud-pos5sync-api-*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos5sync/nms4cloud-pos5sync-api/target/
                """
              }

              if (params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos10printer') {
                sh """
                  set -e
                  ssh ${sshOpts} ${UBUNTU_USER}@${UBUNTU_HOST} "rm -rf ${REMOTE_BASE}/nms4cloud-pos10printer && mkdir -p ${REMOTE_BASE}/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs"
                  scp ${sshOpts} nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/
                  scp ${sshOpts} nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/nms4cloud-pos10printer-app-*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/
                """
              }

              if (params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos6monitor') {
                sh """
                  set -e
                  ssh ${sshOpts} ${UBUNTU_USER}@${UBUNTU_HOST} "rm -rf ${REMOTE_BASE}/nms4cloud-pos6monitor && mkdir -p ${REMOTE_BASE}/nms4cloud-pos6monitor/target"
                  scp ${sshOpts} nms4cloud-pos6monitor/target/nms4cloud-pos6monitor-*.jar ${UBUNTU_USER}@${UBUNTU_HOST}:${REMOTE_BASE}/nms4cloud-pos6monitor/target/
                """
              }
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo "构建成功，产物已上传到 ${UBUNTU_HOST}:${REMOTE_BASE}"
    }
    failure {
      echo '构建失败，请检查 Git 拉取、Maven 构建或 SSH 上传步骤'
    }
  }
}
```

## 5. Windows 从 Ubuntu 取包

```powershell
# 取 libs
scp -r jj@192.168.1.119:/data/backend-build-output/01-nms4pos-java/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/* D:\制包目录\libs\

# 取 printerlibs
scp -r jj@192.168.1.119:/data/backend-build-output/01-nms4pos-java/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/* D:\制包目录\printerlibs\

# 取 libs6
scp -r jj@192.168.1.119:/data/backend-build-output/01-nms4pos-java/nms4cloud-pos6monitor/target/* D:\制包目录\libs6\
```

## 6. 关键检查项

- Ubuntu 目录已创建且 `jj` 用户有写权限
- Jenkins 中已配置 `ubuntu-output-ssh-key`
- `pos6monitor` 的 jar 在 `nms4cloud-pos6monitor/target/`（无子 app 目录）
