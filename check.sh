#! /bin/bash

# Variables
repo="The-DevOps-Journey-101"
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
c
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

