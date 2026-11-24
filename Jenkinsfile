
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'uat', 'prod'],
            description: 'Select environment'
        )

        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Select Terraform action'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()
                checkout scm
                echo 'GitHub checkout successful'
            }
        }

        stage('Tool Verification') {
            steps {
                sh 'terraform --version'
                sh 'ansible --version'
                sh 'aws sts get-caller-identity'
            }
        }

        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    if (params.ENV == 'dev') {
                        env.TF_STATE_KEY =
                            'terraform-jenkins-project/terraform.tfstate'
                    } else {
                        env.TF_STATE_KEY =
                            "terraform-jenkins-project/${params.ENV}/terraform.tfstate"
                    }
                }

                sh '''
                    terraform init -reconfigure -input=false \
                    -backend-config="key=${TF_STATE_KEY}"
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.ACTION == 'destroy') {
                        sh """
                            terraform plan -destroy \
                            -input=false -no-color \
                            -var-file=envs/${params.ENV}.tfvars \
                            -out=tfplan
                        """
                    } else {
                        sh """
                            terraform plan \
                            -input=false -no-color \
                            -var-file=envs/${params.ENV}.tfvars \
                            -out=tfplan
                        """
                    }
                }
            }
        }

        stage('Approval and Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                input message: "Approve APPLY for ${params.ENV}?",
                      ok: 'Apply'

                sh 'terraform apply -input=false -auto-approve tfplan'
            }
        }

        stage('Ansible Docker Deployment') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'target-ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    script {
                        env.TARGET_PRIVATE_IP =
                            sh(
                                script: 'terraform output -raw private_ip',
                                returnStdout: true
                            ).trim()

                        env.TARGET_PUBLIC_IP =
                            sh(
                                script: 'terraform output -raw public_ip',
                                returnStdout: true
                            ).trim()
                    }

                    sh '''
                        ansible-playbook \
                        -i "${TARGET_PRIVATE_IP}," \
                        -u "${SSH_USER}" \
                        --private-key "$SSH_KEY" \
                        ansible/playbook.yml \
                        -e "deploy_env=${ENV}"
                    '''
                }
            }
        }

        stage('Application Verification') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                    curl --fail --retry 10 --retry-delay 5 \
                    "http://${TARGET_PUBLIC_IP}"
                '''
            }
        }

        stage('Approval and Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: "Are you sure you want to DESTROY ${params.ENV}?",
                      ok: 'Destroy'

                sh 'terraform apply -input=false -auto-approve tfplan'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }
    }
}
