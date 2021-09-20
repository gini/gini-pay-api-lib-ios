pipeline {
  agent any
  environment {
    GIT = credentials('github')
    CLIENT_CREDENTIALS = credentials('gini-mobile-test-client-id')
  }
  stages {
    stage('Prerequisites') {
      environment {
        GEONOSIS_USER_PASSWORD = credentials('GeonosisUserPassword')
      }
      steps {
        sh 'security unlock-keychain -p ${GEONOSIS_USER_PASSWORD} login.keychain'
        lock('refs/remotes/origin/master') {
          sh '/usr/local/bin/pod install --repo-update --project-directory=Example/'
        }
      }
    }
    stage('Build') {
      steps {
        sh '''
            xcodebuild -workspace Example/GiniPayApiLib.xcworkspace \
            -scheme "Example" \
            -destination 'platform=iOS Simulator,name=iPhone 11'
        '''
      }
    }
    stage('Unit tests') {
      steps {
        sh '''
            xcodebuild test \
            -workspace Example/GiniPayApiLib.xcworkspace \
            -scheme "GiniPayApiLib-Unit-Tests" \
            -destination 'platform=iOS Simulator,name=iPhone 11' \
            CLIENT_ID=$CLIENT_CREDENTIALS_USR \
            CLIENT_SECRET=$CLIENT_CREDENTIALS_PSW
        '''
      }
    }
    stage('Documentation') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh 'Documentation/scripts/deploy-documentation.sh $GIT_USR $GIT_PSW'
      }
    }
    stage('Pod release') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh '''
            /usr/local/bin/pod repo push gini-specs GiniPayApiLib.podspec \
            --sources=https://github.com/gini/gini-podspecs.git,https://github.com/CocoaPods/Specs.git \
            --allow-warnings \
            --skip-tests
        '''
      }
    }
  }
}
