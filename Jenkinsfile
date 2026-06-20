pipeline {
    agent any

    parameters {
        string(
            name: 'SERVER_NAME',
            defaultValue: '',
            description: 'Enter the name as written in Vault!!!'
        )

        password(
            name: 'VAULT_PERSONAL_TOKEN',
            defaultValue: '',
            description: 'Paste your Vault token'
        )
    }

    environment {
        VAULT_ADDR = 'http://vault:8200'
    }

    stages {
        stage('Validate INPUT & Fetch Secrets') {
            steps {
                script {
                    if (params.SERVER_NAME == null || params.SERVER_NAME.trim() == '') {
                        error "You did not provide any input for the server name. ABORTING..."
                    }

                    def rawToken = "${params.VAULT_PERSONAL_TOKEN}"
                    if (rawToken == null || rawToken.trim() == '') {
                        error "No token was provided, permission denied"
                    }

                    echo "Input Validation Passed. Fetching secrets..."

                    def secretsJson = sh(
                        script: "curl -s -H 'X-Vault-Token: ${rawToken}' ${VAULT_ADDR}/v1/Production/data/servers/${params.SERVER_NAME}",
                        returnStdout: true
                    ).trim()

                    echo "Raw response from Vault: ${secretsJson}"

                    if (secretsJson == null || secretsJson == "" || secretsJson.contains("errors")) {
                        error "Failed to fetch secrets from Vault. Check if token or server name is correct!"
                    }

                    def props = new groovy.json.JsonSlurper().parseText(secretsJson)
                    
                    if (props?.data?.data == null) {
                        error "Structure 'data.data' not found in Vault response. Is the path correct?"
                    }

                    env.SERVER_IP = props.data.data.server_ip
                    env.SERVER_PORT = props.data.data.ssh_port
                    env.SERVER_PASS = props.data.data.server_password

                    echo "Server details pulled successfully from Vault"
                }
            }
        }

        stage('Generate Inventory File') {
            steps {
                script {
                    echo "Creating dynamic inventory file for ${params.SERVER_NAME}..."
                    sh """
                    echo "[production]" > ansible/hosts
                    echo "${params.SERVER_NAME} ansible_host=${env.SERVER_IP} ansible_port=${env.SERVER_PORT} ansible_user=root ansible_password='${env.SERVER_PASS}'" >> ansible/hosts
                    """
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    echo "Running the playbook on the server"
                    sh "ansible-playbook -i hosts playbook.yaml"
                }
            }
            post {
                always {
                    echo "Cleaning sensitive files...."
                    sh "rm -f ansible/hosts"
                }
            }
        }

        stage('Update Vault Port') {
            steps {
                script {
                    def rawToken = "${params.VAULT_PERSONAL_TOKEN}"
                    echo "Updating the new port (2222) in Vault..."
                    sh """
                    curl -s -X POST \
                        -H "X-Vault-Token: ${rawToken}" \
                        -H "Content-Type: application/json" \
                        -d '{"data": {"server_ip": "${env.SERVER_IP}", "ssh_port": "2222", "server_password": "${env.SERVER_PASS}"}}' \
                        ${VAULT_ADDR}/v1/Production/data/servers/${params.SERVER_NAME}
                    """
                    echo "Vault has been updated"
                }
            }
        }
    }
}