#!/bin/bash
#Automate an e-commerce application deployment
#Printing a message in different color
function print_color(){
        NC='\033[0m'      #this means no color
        case $1 in
                "Blue") COLOR='\033[0;34m'  ;;
                "Light-gray") COLOR='\033[0;37m' ;;
                "*") COLOR='\033[0m'    ;;
        esac
        echo ${COLOR} $2 ${NC}
}
#Check the status of a given service. if not configured exit the script with an error message
function check_service_status(){
        service_is_active=$(sudo systemctl is-active $1 )
        if [ $service_is_active = "active" ]
        then
                echo " $1 is active and running "
        else
                echo " $1 is not active/runnning "
                exit 1
        fi
}
#Check the status of a firewalld rule. if not configured, exit with and error message
function is_firewalld_rule_configured() {
        firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)
        if [[ $firewalld_ports = *$1* ]]
        then
                echo "firewalld has port $1 configured"
        else
                echo "firewalld port $1 is not configured"
                exit 1
        fi
}
#Check if a given item is present in an output
function check_output(){
        if echo "$1" | grep -q "$2";
        then
                print_color "Blue" " $2 is present on the web page "
        else
                print_color "Light-gray" " $2 is not present on the web page "
        fi
}

echo "_____________________ Setup Database server _______________________________"

#Install and configure firewalld
print_color "Blue" "Installing firewalld.. "
sudo yum install -y firewalld
print_color "Blue" "Installing firewalld.. "
sudo service firewalld start
sudo systemctl enable firewalld

check_service_status firewalld

#Install and configure mariadb
print_color "Blue" "Starting mariadb server.."
sudo yum install -y mariadb-server

print_color "Blue" "Starting mariadb server.."
sudo service mariadb start
sudo systemctl enable mariadb

check_service_status mariadb


#Configure firewalld rule
print_color "Blue" "Configuring Firewalld rules for database"
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306

#Configuring database
print_color "Blue" "Setting up Database.."
cat > setup-db.sql <<-EOF
        CREATE DATABASE ecomdb;
        CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
        GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
        FLUSH PRIVILEGES;
EOF
#Run the mysql script
sudo mysql < setup-db.sql
#Loading Inventory into database
print_color "Blue" "Loading inventory data into database.."
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

sudo mysql < db-load-script.sql

#Check if Laptop is present in the list of produts
mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")

if echo "$mysql_db_results" | grep -q "Laptop";
then
        print_color "Blue" "Inventory data loaded into MySQL"
else
        print_color "Blue" "Inventory data not loaded into MYSQL"
        exit 1
fi

print_color "Blue" "_____________Setup Database Server - Finished___________________________"

print_color "Blue" "_____________Setup Web Server ____________________________"

#Install web server packages
print_color "Blue" "Installing Web Server Packages.."
sudo yum install -y httpd php php-mysql


#Configure firewalld rules
print_color "Blue" "Configuring firewalld rules.."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80#Update index.php
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#Start httpd service
print_color "Blue" "Start httpd service.."
sudo service httpd start
sudo systemctl enable httpd

# Check firewalld service is running
check_service_status httpd

#Download code
print_color "Blue" "Install GIT.. "
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

print_color "Blue" "updating index.php"
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "Blue" "________________________________Setup Web Server - finished___________________"

# Test Script
web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
        check_output "$web_page" $item
done




