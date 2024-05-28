#! /bin/bash

# Variables
REPO="bootcamp-devops-2023"
BRANCH='clase2-linux-bash'
USER=$(id -u)

# Colors
LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'

function check_package () 
{
    package_name=$1
    
    if dpkg -l |grep -q -e "$package_name";
    then
        echo -e "\n${LGREEN}$package_name is already installed${NC}"
    else
        echo -e "\n${LRED}$package_name isn't installed${NC}"
        echo -e "\n${LGREEN}Installing $package_name${NC}\n"
        apt install -y $package_name
    fi
}

function test_and_enable () 
{
    service=$1
    if systemctl status $service |grep -q -e "active" ;
    then
        echo -e "\n${LGREEN}$service is running${NC}"
    else
        echo -e "\n${LRED}$service isn't running${NC}"
        echo -e "\n${LGREEN}Trying to run $service${NC}"
        systemctl start $service
    fi
    echo -e "\n${LGREEN}Enable service $service${NC}"
    systemctl enable $service    
}

function reload_service ()
{
    service=$1
    systemctl reload $service
}

echo -e "\n${LBLUE}STAGE 1 [Init]"

if [ "$USER" -ne 0 ] ;
then
    echo -e "\n${LRED}You have to run with ROOT${NC}"
    exist
fi

apt update
package_to_check="apache2"
check_package "$package_to_check"
test_and_enable "$package_to_check"
package_to_check="mariadb-server"
check_package "$package_to_check"
package_to_check="mariadb"
test_and_enable "$package_to_check"
package_to_check="php"
check_package "$package_to_check"
package_to_check="libapache2-mod-php"
check_package "$package_to_check"
package_to_check="php-mysql"
check_package "$package_to_check"
package_to_check="git"
check_package "$package_to_check"
package_to_check="curl"
check_package "$package_to_check"

echo -e "\n${LBLUE}STAGE 2 [Init]${NC}"

if [ ! -d "$REPO" ] ;
then
    echo -e "\n${LRED}The folder $REPO doesn't exist${NC}"
    echo -e "\n${LGREEN}Downloading....${NC}"
    git clone -b $BRANCH https://github.com/roxsross/$REPO.git
    mv /var/www/html/index.html /var/www/html/index.html.bkp
    cp -r $(find . -type d -name app-ecommerce)/* /var/www/html/
    sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
    echo 
else
    echo -e "\n${LGREEN}The folder $REPO already exist${NC}"
    echo -e "\n${LGREEN}Doing pull request....${NC}"
    cd $REPO
    git pull origin
    cp -u  $(find . -type d -name app-ecommerce)/ /var/www/html/
    sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
fi


if [ ! -d "db-config-$REPO.sql" ] ;
then 
    echo -e "\n${LRED}The db configuration file doesn't exist!${NC}"
    echo -e "\n${LGREEN}Creating....${NC}"
    cat > db-config-$REPO.sql <<-EOL
    CREATE DATABASE ecomdb;
    CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
    GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
    FLUSH PRIVILEGES;
EOL
    echo -e "\n${LGREEN}DONE....${NC}"
    echo -e "\n${LGREEN}Applying confing....${NC}"
    mysql < db-config-$REPO.sql
    echo -e "\n${LGREEN}DONE....${NC}"
else
    echo -e "\n${LGREEN}You already have the config file.${NC}"
fi

if [ ! -d " db-load-script-$REPO.sql" ] ;
then 
    echo -e "\n${LRED} The data file doesn't exist!${NC}"
    echo -e "\n${LGREEN}Creating....${NC}"
    cat > db-load-data-$REPO.sql <<-EOL
    USE ecomdb;
    CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
    INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOL
    echo -e "\n${LGREEN}DONE....${NC}"
    echo -e "\n${LGREEN}Applying Data....${NC}"
    mysql < db-load-data-$REPO.sql
    echo -e "\n${LGREEN}DONE....${NC}"
else
    echo -e "\n${LGREEN}You already have the data file.${NC}"

fi

reload_service 'apache2'
 