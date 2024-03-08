pipeline {
    agent any

    parameters {
        string(name: 'GIT_REPO_URL', defaultValue: 'git@github.com:shahram29/petclinic-exploratory.git')
        string(name: 'GIT_CREDENTIALS_ID', defaultValue: 'exploratory')
        string(name: 'GIT_BRANCH', defaultValue: 'main')
        string(name: 'PROJECT_NAME', defaultValue: 'petclinic-spring')
        string(name: 'FILE_PROPERTIES', defaultValue: 'file.properties')
        string(name: 'TERRAFORM_BIN_PATH', defaultValue: '/usr/local/bin/terraform')
    }

    options {
        disableConcurrentBuilds()
    }

    environment {
        amiNameTagValue = ''
        thisTestNameVar = ''
    }

    stages {
        stage('Get Exploratory Testing Repo') {
            steps {
                echo 'Getting Exploratory Testing Repo'
                git(url: params.GIT_REPO_URL, credentialsId: params.GIT_CREDENTIALS_ID, branch: params.GIT_BRANCH)
            }
        }

        stage('Read Properties File') {
            steps {
                script {
                    copyArtifacts(projectName: params.PROJECT_NAME)
                    props = readProperties file: params.FILE_PROPERTIES

                    this_group = props.Group
                    this_version = props.Version
                    this_artifact = props.ArtifactId
                    this_full_build_id = props.FullBuildId
                    this_jenkins_build_id = props.JenkinsBuildId

                    ['this_group', 'this_version', 'this_artifact', 'this_full_build_id', 'this_jenkins_build_id'].each {
                        sh "echo Finished setting $it = ${this."$it"}"
                    }
                }
            }
        }

        stage('Deploying App') {
            steps {
                echo 'Starting --- terraform deploy and start'
                sh 'pwd'
                
                dir('./infrastructure') {
                    script {
                        echo 'update terraform variables '
                        
                        amiNameTagValue = "${this_artifact}-${this_jenkins_build_id}"
                        amiNameTag = "build_id=\"$amiNameTagValue\""
                        thisTestNameVar = "test-name=\"${params.THIS_TEST_VALUE}\""

                        def readContent = readFile 'terraform.tfvars'
                        writeFile file: 'terraform.tfvars', text: "$readContent\n$amiNameTag\n$thisTestNameVar"

                        sh 'pwd'
                        sh 'ls -l'
                        sh "${params.TERRAFORM_BIN_PATH} init -input=false"
                        sh "${params.TERRAFORM_BIN_PATH} plan"
                        sh "${params.TERRAFORM_BIN_PATH} apply -auto-approve"
                    }
                }
            }
        }

        stage('TEST RESULTS - INPUT REQUIRED') {
            steps {
                echo 'Starting --- exploratory testing'
                sh 'pwd'
                script {
                    env.TEST_PASSED = input message: 'Was the Exploratory Testing Successfully Completed?', parameters: [choice(name: 'Test Results', choices: 'SUCCESSFULL\nUNSUCCESSFULL', description: 'Please make a selection')]
                }
                echo "Exploratory Test successfully completed: ${env.TEST_PASSED}"
            }
        }

        stage('Destroy Environment') {
            steps {
                dir('./infrastructure') {
                    script {
                        echo 'Test completed, destroying environment'
                        sh "${params.TERRAFORM_BIN_PATH} destroy -auto-approve"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                def summaryMessage = "Summary of Test Results:\n" +
                    "Exploratory Test: ${env.TEST_PASSED}\n" +
                    ".......................................\n" +
                    "Build ${currentBuild.fullDisplayName} has finished.\n Result: ${currentBuild.currentResult}"
                emailext subject: "Pipeline Status: ${currentBuild.currentResult}", 
                      body: summaryMessage,
                      to: "vaziri.sean@gmail.com,vaziri.sean@icloud.com",
                      replyTo: "vaziri.sean@gmail.com"
            }
        }
    }
}
