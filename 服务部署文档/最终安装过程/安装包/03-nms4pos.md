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
  serviceAccountName: jenkins
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
  containers:
  - name: maven
    image: maven:3.9.11-eclipse-temurin-21
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
    volumeMounts:
    - name: package-output
      mountPath: /package-output
  volumes:
  - name: package-output
    hostPath:
      path: /var/lib/jenkins-package-output
      type: DirectoryOrCreate
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
      defaultValue: 'jujiao_master',
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
  }

  environment {
    MAVEN_SETTINGS     = '/tmp/maven-settings.xml'
    NEXUS_URL          = 'http://nexus.nexus.svc.cluster.local:8081'
    NEXUS_REPO_GROUP   = 'maven-public'
    NEXUS_CRED_ID      = 'nexus-deployer'

    GIT_CREDENTIAL_ID  = 'aliyun-codeup-token'
    GIT_REPO_URL       = 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/nms4cloud-pos-java/nms4pos.git'

    OUTPUT_BASE        = '/package-output/backend/01-nms4pos-java'
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
          script {
              def sharedStaticDir = "/package-output/frontend/01-nms4pos-ui/app/pos4desktop/www"
              def localStaticDir = "nms4cloud-pos3boot/nms4cloud-pos3boot-app/src/main/resources/static"

              sh """
                set -e
                test -d ${sharedStaticDir}
                rm -rf ${localStaticDir}
                mkdir -p ${localStaticDir}
                cp -R ${sharedStaticDir}/. ${localStaticDir}/
              """
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

    stage('Publish package output') {
      steps {
        container('maven') {
          script {

              if (params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos3boot') {
                sh """
                  set -e
                  rm -rf ${OUTPUT_BASE}/nms4cloud-pos3boot
                  mkdir -p ${OUTPUT_BASE}/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs ${OUTPUT_BASE}/nms4cloud-pos4cloud/nms4cloud-pos4cloud-api/target ${OUTPUT_BASE}/nms4cloud-pos5sync/nms4cloud-pos5sync-api/target
                  cp nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/*.jar ${OUTPUT_BASE}/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/
                  cp nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/nms4cloud-pos3boot-app-*.jar ${OUTPUT_BASE}/nms4cloud-pos3boot/nms4cloud-pos3boot-app/target/libs/
                  cp nms4cloud-pos4cloud/nms4cloud-pos4cloud-api/target/nms4cloud-pos4cloud-api-*.jar ${OUTPUT_BASE}/nms4cloud-pos4cloud/nms4cloud-pos4cloud-api/target/
                  cp nms4cloud-pos5sync/nms4cloud-pos5sync-api/target/nms4cloud-pos5sync-api-*.jar ${OUTPUT_BASE}/nms4cloud-pos5sync/nms4cloud-pos5sync-api/target/
                """
              }

              if (params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos10printer') {
                sh """
                  set -e
                  rm -rf ${OUTPUT_BASE}/nms4cloud-pos10printer
                  mkdir -p ${OUTPUT_BASE}/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs
                  cp nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/*.jar ${OUTPUT_BASE}/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/
                  cp nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/nms4cloud-pos10printer-app-*.jar ${OUTPUT_BASE}/nms4cloud-pos10printer/nms4cloud-pos10printer-app/target/libs/
                """
              }

              if (params.BUILD_MODULE == 'all' || params.BUILD_MODULE == 'pos6monitor') {
                sh """
                  set -e
                  rm -rf ${OUTPUT_BASE}/nms4cloud-pos6monitor
                  mkdir -p ${OUTPUT_BASE}/nms4cloud-pos6monitor/target
                  cp nms4cloud-pos6monitor/target/nms4cloud-pos6monitor-*.jar ${OUTPUT_BASE}/nms4cloud-pos6monitor/target/
                """
              }
          }
        }
      }
    }
  }

  post {
    success {
      echo "构建成功，产物目录：${OUTPUT_BASE}"
    }
    failure {
      echo '构建失败，请检查 Git 拉取、Maven 构建或 SSH 上传步骤'
    }
  }
}
