pipeline {
  agent {
    kubernetes {
      defaultContainer 'maven'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  restartPolicy: Never
  containers:
  - name: maven
    image: 192.168.253.128:30083/dockerhub/library/maven:3.9-eclipse-temurin-21
    command: [cat]
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    command: [cat]
    tty: true
    volumeMounts:
    - name: harbor-auth
      mountPath: /kaniko/.docker
  volumes:
  - name: harbor-auth
    secret:
      secretName: harbor-registry-secret
      items:
      - key: .dockerconfigjson
        path: config.json
'''
    }
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'master', credentialsId: 'aliyun-codeup-token', url: 'https://codeup.aliyun.com/613895a803e1c17d57a7630f/nms4cloud-pos-java/nms4cloud-pos11report.git'
      }
    }
    stage('Package') {
      steps {
        sh 'mvn -DskipTests package'
      }
    }
    stage('Publish Image') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor --context=dir://$WORKSPACE/nms4cloud-pos11report-app --dockerfile=$WORKSPACE/nms4cloud-pos11report-app/Dockerfile --destination=harbor-core.harbor/library/nms4cloud-pos11report:$BUILD_NUMBER --insecure --skip-tls-verify'
        }
      }
    }
  }
}
