pipeline {
    agent any

    // tools {
    //     nodejs 'NodeJS-20'
    // }

    parameters {
        string(name: 'SERVER_HOST', defaultValue: '118.69.34.46', description: 'Remote server host')
        string(name: 'SERVER_USER', defaultValue: 'newbie', description: 'Remote server user')
        string(name: 'SERVER_PORT', defaultValue: '3334', description: 'SSH port')
        string(name: 'TARGET_BASE', defaultValue: '/usr/share/nginx/html/jenkins', description: 'Base deployment path')
        string(name: 'YOUR_NAME', defaultValue: 'truongtx2', description: 'Your personal folder name')
        string(name: 'RETAIN_RELEASES', defaultValue: '5', description: 'Number of releases to keep')
        booleanParam(name: 'DEPLOY_TO_FIREBASE', defaultValue: false, description: 'Deploy to Firebase')
        booleanParam(name: 'DEPLOY_TO_REMOTE', defaultValue: true, description: 'Deploy to remote server')
    }

    environment {
        FIREBASE_TOKEN = credentials('firebase-token')
        GOOGLE_APPLICATION_CREDENTIALS = credentials('firebase-adc')
        SLACK_CHANNEL = '#lnd-2025-workshop'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out code from GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Installing dependencies and building...'
                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                sh 'chmod +x test.sh'
                sh './test.sh'
            }
        }

        stage('Deploy-local') {
            steps {
                echo '📦 Deploying to local container (remote_host)...'
                sh 'chmod +x deploy-local.sh'
                sh './deploy-local.sh'
            }
        }

        stage('Deploy-remote') {
            steps {
                echo '📤 Deploying to remote server...'
                sh 'chmod +x deploy-remote.sh'
                sh './deploy-remote.sh'
            }
        }

        // stage('Deploy-firebase') {
        //     steps {
        //         echo '🚀 Deploying to Firebase...'
        //         sh 'chmod +x deploy-firebase.sh'
        //         sh './deploy-firebase.sh'
        //     }
        // }

        stage('Deploy-firebase-adc') {
            steps {
                echo '🚀 Deploying to Firebase using ADC...'
                sh 'chmod +x deploy-firebase-adc.sh'
                sh './deploy-firebase-adc.sh'
            }
        }
    }

    post {
        success {
            script {
                def buildUser = 'Truong Tran'
                def firebaseUrl = 'https://jenkins-lnd-workshop2-truongtx.web.app'
                def timestamp = new Date().format('yyyy-MM-dd HH:mm:ss')

                def message = """
:rocket: *Deployment Successful!* :white_check_mark:

*User:* ${buildUser}
*Job:* ${JOB_NAME} #${BUILD_NUMBER}
*Time:* ${timestamp}
*Branch:* ${env.GIT_BRANCH ?: 'main'}

*Deployment Status:*
:globe_with_meridians: *Firebase:* <${firebaseUrl}|Live Site>
:package: *Local Container:* Deployed

*Build Details:*
• Duration: ${currentBuild.durationString}
• Commit: ${env.GIT_COMMIT?.take(7) ?: 'N/A'}

:point_right: <${BUILD_URL}|View Build Log>
                """.trim()

                slackSend(
                    channel: env.SLACK_CHANNEL,
                    color: 'good',
                    message: message
                )
            }
        }
        failure {
            script {
                def buildUser = 'truongtx'
                def timestamp = new Date().format('yyyy-MM-dd HH:mm:ss')

                def message = """
:x: *Deployment Failed!* :warning:

*User:* ${buildUser}
*Job:* ${JOB_NAME} #${BUILD_NUMBER}
*Time:* ${timestamp}
*Branch:* ${env.GIT_BRANCH ?: 'main'}

*Error Details:*
• Duration: ${currentBuild.durationString}
• Stage: ${env.FAILED_STAGE ?: 'Unknown'}
• Commit: ${env.GIT_COMMIT?.take(7) ?: 'N/A'}

:point_right: <${BUILD_URL}console|Check Console Log>
:hammer_and_wrench: Please review the build logs for details.
                """.trim()

                slackSend(
                    channel: env.SLACK_CHANNEL,
                    color: 'danger',
                    message: message
                )
            }
        }
        always {
            script {
                def buildUser = 'truongtx'
                def status = currentBuild.result ?: 'SUCCESS'
                def emoji = status == 'SUCCESS' ? ':tada:' : ':warning:'

                echo "${emoji} Build ${status} for user ${buildUser}"
                echo "Firebase URL: https://jenkins-lnd-workshop2-truongtx.web.app"
            }
        }
    }
}
