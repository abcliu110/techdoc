# Jenkins 在 K8s 构建 nms4cloud-mall 方案（仅构建，不上传）

## 1. 本地编译命令参考

```bat
set JAVA_HOME=D:\Java\jdk-21.0.5
mvn clean install -pl nms4cloud-app/2_business/nms4cloud-mall/nms4cloud-mall-app -am -DskipTests
```

## 2. Jenkins Pipeline 最终版

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
    MAVEN_SETTINGS    = '/tmp/maven-settings.xml'
    NEXUS_URL         = 'http://nexus.nexus:8081'
    NEXUS_REPO_GROUP  = 'maven-public'
    NEXUS_CRED_ID     = 'nexus-credentials'

    GIT_CREDENTIAL_ID = 'aliyun-codeup-token'
    GIT_REPO_URL      = 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/nms4cloud.git'
    MAVEN_MODULE      = 'nms4cloud-app/2_business/nms4cloud-mall/nms4cloud-mall-app'
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

    stage('Maven 构建') {
      steps {
        container('maven') {
          script {
            def skipTests = params.SKIP_TESTS ? '-Dmaven.test.skip=true' : ''
            sh "mvn clean install -pl ${MAVEN_MODULE} -am ${skipTests} -s ${MAVEN_SETTINGS}"
          }
        }
      }
    }
  }

  post {
    success {
      echo '构建成功，nms4cloud-mall-app 已完成编译'
    }
    failure {
      echo '构建失败，请检查 Git 拉取、Maven 构建或 Nexus 配置'
    }
  }
}
```

## 3. 关键说明

- `GIT_REPO_URL` 指向 `nms4cloud.git`（多模块主仓库）
- `-pl` 使用完整相对路径 `nms4cloud-app/2_business/nms4cloud-mall/nms4cloud-mall-app`
- 当前方案只做构建，不做 Ubuntu 上传

## 4. 关键检查项

- Jenkins 中已配置 `nexus-credentials` 和 `aliyun-codeup-token`
- K8s Maven 容器内能正常访问 Nexus 和 Git 仓库
