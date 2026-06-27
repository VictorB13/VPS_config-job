pipeline {
    agent any

    //painting the jenkins logs
    options {
        ansiColor('xterm')
    }

    // The fields for the user to fill in the UI
    parameters {
        string(name: 'SERVER_NAME', defaultValue: '', description: 'The name of the VPS (like written in Vault)')
        password(name: 'VAULT_TOKEN', defaultValue: '', description: 'Personal Vault Token') 
    }

    stages {
        stage('Validate Input') {
            steps {
                script {
                    if (params.SERVER_NAME == '') {
                        error "ERROR: Server name can not be empty!"
                    }
                    echo "INPUT Validtion Passed for Server name: ${params.SERVER_NAME}"
                }
            }
        }

        // Fetch Server info from Vault
        stage('Fetch VPS secrets from VAULT'){
            steps{
                script{
                    echo "Fetching VPS secrets from Vault"
                    //fetching the secrets
                    withVault(vaultUrl: 'http://vault:8200', vaultToken: "${params.VAULT_TOKEN}", engineVersion: 2){
                        withVaultSecrets([
                            [$class: 'VaultSecretMapping', requestVariable: 'SERVER_IP', secretValue: 'Production/data/servers/digitalOcean_1:server_ip'],
                            [$class: 'VaultSecretMapping', requestVariable: 'SERVER_PASSWORD', secretValue: 'Production/data/servers/digitalOcean_1:server_password'],
                            [$class: 'VaultSecretMapping', requestVariable: 'SSH_PORT', secretValue: 'Production/data/servers/digitalOcean_1:ssh_port']
                        ]){
                            env.VAULT_IP = "${SERVER_IP}"
                            env.VAULT_PASSWORD = "${SERVER_PASSWORD}"
                            env.VAULT_PORT = "${SSH_PORT}"
                        }
                    }
                    echo "Successfully fetched secrets for IP: ${env.VAULT_IP}"
                }
            }
        }   
        // Generate dynamic inventory.ini file for the VPS parameters
        stage('Generate Inventory File') {
            steps {
                script {
                    echo "Creating Dynamic inventory file from Jenkins UI parameters..."

                    sh """
                    echo "[Production]" > ansible/hosts
                    echo "good_VPS ansible_host=${env.VAULT_IP} ansible_port=${env.VAULT_PORT} ansible_user=root ansible_password='${env.VAULT_PASSWORD}'" >> ansible/hosts
                    """
                }
            }
        }

        stage('Run ansible playbook') {
            steps {
                dir('ansible'){
                    sh "chmod 600 ansible.cfg" 

                    echo "Running the playbook on the server..."
                    sh "ANSIBLE_FORCE_COLOR=true ansible-playbook -i hosts playbook.yaml"
                }
            }
        }
    }

    post {
        success {
            script {
                echo """
                ==================================================================
                🚀🚀🚀 VPS CONFIGURATION COMPLETED SUCCESSFULLY! 🚀🚀🚀
                ==================================================================
                
                Your server is now secure and ready for production use.
                
                💻 HOW TO CONNECT VIA SSH:
                --------------------------
                ssh root@${env.VAULT_IP} -p 22
                
                🔒 OPENVPN STATUS:
                ------------------
                The OpenVPN container is RUNNING, Initialized, and Verified.
                
                📄 YOUR OPENVPN CLIENT CERTIFICATE (*.ovpn):
                --------------------------------------------
                You can find the full certificate content in the Ansible log above 
                between 'START_CERTIFICATE_OUTPUT' and 'END_CERTIFICATE_OUTPUT'.
                Copy that text, save it as 'client.ovpn', and use it in your VPN client!
                
                ==================================================================
                """
            }
        }

        failure {
            echo "Deployment Failed. Please check the Jenkins console output above to investigate the error"
        }

        always {
            echo "Cleaning senitive files..."
            sh "rm -f ansible/hosts"
        }
    }
}