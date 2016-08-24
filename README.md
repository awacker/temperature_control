# Temperature Control (MongoDB->Tornado->RESTful API Example)


## Prerequisites

####EC2 based on Ubuntu Server 14.04 LTS (HVM), SSD Volume Type 
> See [https://aws.amazon.com/ec2/?nc1=h_ls](https://aws.amazon.com/ec2/?nc1=h_ls)

####NGINX http server with uWSGI plugin
```sh
$ sudo apt-get update
$ sudo apt-get install nginx-full uwsgi uwsgi-plugin-python
```
add configuration param to /etc/nginx/nginx.conf
```
http {
        server_names_hash_bucket_size 128;
        ...
```
> sudo service nginx start, stop, restart

####MongoDB server
```sh
  $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  $ echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  $ sudo apt-get update
  $ sudo apt-get install -y mongodb-org
```

## Installation
- git clone https://github.com/awacker/temperature_control.git
- Define HOST_NAME variable in the install.sh according with domain name
- Run install.sh
