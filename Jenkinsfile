def sha, version

pipeline {
  agent {
    label 'slave'
  }

  options {
    ansiColor('xterm')
      timeout(time: 1, unit: 'HOURS')
  }

  stages {
    stage('check-gh-trust') {
      steps {
        checkGitHubAccess()
      }
    }

    stage('cook-image') {
      steps {
        sh 'make cook-image'
      }
    }

    stage('push-to-registry') {
      environment {
        DOCKER_REPO = 'docker-push.ocf.berkeley.edu/'
          DOCKER_REVISION = "${version}"
      }
      when {
        branch 'master'
      }
      agent {
        label 'deploy'
      }
      steps {
        sh 'make push-image'
      }
    }

    stage('deploy-to-prod') {
      when {
        branch 'master'
      }
      agent {
        label 'deploy'
      }
      steps {
        marathonDeployApp('snmp-exporter', version)
      }
    }
  }
}

