pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        amiNameTagValue = ''
        thisTestNameVar = ''
        thisTestValue = 'exploratory-testing'
        ProjectName = 'petclinic-spring'
        fileProperties = 'file.properties'
    }

    stages {
        stage('Get Exploratory Testing Repo') {
            steps {
                echo 'Getting Exploratory Testing Repo'
                git(url: 'git@github.com:shahram29/petclinic-exploratory.git', credentialsId: 'exploratory', branch: 'main')
            }
        }

        stage('Read Properties File') {
            steps {
                script {
                    copyArtifacts(projectName: "${ProjectName}")
                    props = readProperties file: "${fileProperties}"

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
                        thisTestNameVar = "test-name=\"$thisTestValue\""

                        def readContent = readFile 'terraform.tfvars'
                        writeFile file: 'terraform.tfvars', text: "$readContent\n$amiNameTag\n$thisTestNameVar"

                        sh 'pwd'
                        sh 'ls -l'
                        sh '/usr/local/bin/terraform init -input=false'
                        sh '/usr/local/bin/terraform plan'
                        sh '/usr/local/bin/terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('TEST RESULTS - INPUT REQUIRED') {
            steps {
                echo 'Starting --- exploratory testing'
                sh 'pwd'
                script {
                    env.TEST_PASSED = input message: 'Was the Exploratory Testing Successfully Completed?', parameters: [choice(name: 'Test Results', choices: 'YES\nNO', description: 'Please make a selection')]
                }
                echo "Exploratory Test successfully completed: ${env.TEST_PASSED}"
            }
        }

        stage('Destroy Environment') {
            steps {
                dir('./infrastructure') {
                    script {
                        echo 'Test completed, destroying environment'
                        sh '/usr/local/bin/terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            emailext subject: "Pipeline Status: ${currentBuild.currentResult}", 
                      body: "Build ${currentBuild.fullDisplayName} has finished. Result: ${currentBuild.currentResult}",
                      to: "svaziri@apple.com",
                      replyTo: "jenkins-noreply@example.com"
        }
    }
}
