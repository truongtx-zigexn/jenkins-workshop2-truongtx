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
        string(name: 'YOUR_NAME', defaultValue: 'truongtx', description: 'Your personal folder name')
        string(name: 'RETAIN_RELEASES', defaultValue: '5', description: 'Number of releases to keep')
        booleanParam(name: 'DEPLOY_TO_FIREBASE', defaultValue: false, description: 'Deploy to Firebase')
        booleanParam(name: 'DEPLOY_TO_REMOTE', defaultValue: true, description: 'Deploy to remote server')
    }

    environment {
        // FIREBASE_TOKEN = credentials('firebase-token')
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
    }

    // post {
    //     success {
    //         slackSend(
    //             channel: env.SLACK_CHANNEL,
    //             color: 'good',
    //             message: ":white_check_mark: ${env.BUILD_USER} deploy job ${JOB_NAME} #${BUILD_NUMBER} succeeded!\nFirebase: ${params.DEPLOY_TO_FIREBASE ? 'Deployed' : 'Skipped'}\nRemote: ${params.DEPLOY_TO_REMOTE ? 'Deployed' : 'Skipped'}"
    //         )
    //     }
    //     failure {
    //         slackSend(
    //             channel: env.SLACK_CHANNEL,
    //             color: 'danger',
    //             message: ":x: ${env.BUILD_USER} deploy job ${JOB_NAME} #${BUILD_NUMBER} failed!\nCheck console log for details."
    //         )
    //     }
    // }
}
