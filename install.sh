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

service uwsgi restart
service nginx restart
echo 'end of install'

