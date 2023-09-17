# Bash-Script-Project
A bash script file that automate the deployment of an Ecommerce-application

This is a bash script file that automtate the deployment of an E-commerce Application which includes:
1. Setting up the database the application needs
2. Checking the status of a particular service and to confirm maybe a firewalld rule is configured on the database
3. Installing an httpd web server, confirm maybe it has a firewall d rule configured, start and enable the httpd web server and also confirm maybe the server is running
4. Clone the e-commerce website from github and also check maybe some item are presnt in the output displayed when the aplication has been deployed.

**Testing script locally.**

Using the terminal;

Clone the repository

git clone https://github.com/Ayomide05/Bash-Script-Project.git

#navigate to the application directory.

cd Bash-Script-Project

#Give the file the necessary permission to be able to run it.

chmod +x deploy-ecommerce-application.sh

#Run the bash script file.

./deploy-ecommerce-application.sh
