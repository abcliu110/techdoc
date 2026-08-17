pipeline {
  agent {
    kubernetes {
      defaultContainer 'shell'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
  containers:
    - name: shell
      image: busybox:1.37.0
      command: ["cat"]
      tty: true
      volumeMounts:
        - name: package-output
          mountPath: /package-output
  volumes:
    - name: package-output
      hostPath:
        path: /var/lib/jenkins-package-output
        type: DirectoryOrCreate
'''
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 10, unit: 'MINUTES')
  }

  stages {
    stage('Clean package output') {
      steps {
        sh '''
          set -eu
          rm -rf /package-output/frontend/01-nms4pos-ui
          rm -rf /package-output/backend/01-nms4pos-java
          mkdir -p /package-output/frontend/01-nms4pos-ui
          mkdir -p /package-output/backend/01-nms4pos-java
        '''
      }
    }
  }

  post {
    success {
      build job: 'pos-install-package/01-nms4cloud', wait: false
    }
  }
}
