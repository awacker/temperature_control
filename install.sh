#!/bin/bash 


HOST_NAME='ec2-52-40-243-194.us-west-2.compute.amazonaws.com'

uWSGI_PATH='/etc/uwsgi'
nginx_PATH='/etc/nginx'
SCRIPT=$(readlink -f "$0")
PROJECT_PATH=$(dirname "$SCRIPT")

cd $PROJECT_PATH

#Log folder definition
mkdir -p logs
chmod 777 logs

# Install virtual environment
echo '###  001 ############################################# Virtual environment ################################################'
virtualenv .env
source $PROJECT_PATH/.env/bin/activate
pip install -r requirements.txt
deactivate

# uWSGI settings
echo '###  002 ############################################# uWSGI settings ################################################'
sed -e "s#@HOST_NAME@#${HOST_NAME}#g" -e "s#@PROJECT_PATH@#${PROJECT_PATH}#g" ./install_templates/uWSGI.template > ${uWSGI_PATH}/apps-available/${HOST_NAME}.xml
ln -f -s ${uWSGI_PATH}/apps-available/${HOST_NAME}.xml ${uWSGI_PATH}/apps-enabled/${HOST_NAME}.xml

# nginx settings
echo '###  003 ############################################# nginx settings ################################################'
sed -e "s#@HOST_NAME@#${HOST_NAME}#g" -e "s#@PROJECT_PATH@#${PROJECT_PATH}#g" ./install_templates/nginx.template > ${nginx_PATH}/sites-available/${HOST_NAME}
ln -f -s ${nginx_PATH}/sites-available/${HOST_NAME} ${nginx_PATH}/sites-enabled/${HOST_NAME}


# MongoDB
echo '###  004 ############################################# MongoDB check or install  ################################################'

mongo --eval "db.stats()"  # do a simple harmless command of some sort

RESULT=$?   # returns 0 if mongo eval succeeds

if [ $RESULT -ne 0 ]; then
    echo "mongodb not running!"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
    echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org
else
    echo "mongodb running!"
fi

service uwsgi restart
service nginx restart
echo 'end of install'

