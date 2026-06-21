pipeline {
    agent any

    // The fields for the user to fill in the UI
    parameters {
        string(name: 'SERVER_IP', defaultValue: '', description: 'The IP of the VPS')
        string(name: 'SSH_PORT', defaultValue: '', description: 'SSH port of the VPS')
        password(name: 'SERVER_PASSWORD', defaultValue: '', description: 'Password of the VPS') 
    }

    stages {
        stage('Validate Input') {
            steps {
                script {
                    if (params.SERVER_IP == '' || params.SERVER_PASSWORD == '') {
                        error: "ERROR: IP or Passeword Cannot be empty!"
                    }
                    echo "INPUT Validtion Passed for IP: ${params.SERVER_IP}"
                }
            }
        }
        
        // Generate dynamic inventory.ini file for the VPS parameters
        stage('Generate Invenroty File') {
            steps {
                script {
                    echo "Creating Dynamic inventory file from Jenkins UI parameters..."
                    sh """
                    echo "[Production]" > ansible/hosts
                    echo "good_VPS ansible_host=${params.SERVER_IP} ansible_port=${SSH_PORT} ansible_user=root ansilbe_password='${SERVER_PASSWORD}'" >> ansible/hosts
                    """
                }
            }
        }

        stage('Run ansible playbook') {
            steps {
                dir('ansible'){
                    echo "Running the playbook on the server..."
                    sh "ansible-playbook -i hosts playbook.yaml"
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
                ssh root@${params.SERVER_IP} -p 22444
                (Note: The SSH port has been updated to 22444 for security)
                
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