#! /bin/bash
if [[ $* == *--[sS][sS][Ll]* ]]
then
    echo "Installing in HTTPS mode"
    SSL="yes"
else 
    echo "installing in HTTP mode"
    SSL="no"
fi 

mkdir ./nginx ./gitlab

if [ $SSL == "yes" ]
then
    #Make folder for SSL certs which will be mounted at /tmp on the container
    mkdir ./nginx/ssl
    #Read in the NGINX SSL config file 
    #certs will need to be placed in the ./nginx/ssl/ folder before the container is started
    echo "server {
  listen 443 SSL;
  ssl_certificate /tmp/nginx.crt;
  ssl_certificate_key /tmp/nginx.key;
  location / {
    proxy_pass http://gitlabsvr/;
  }
}"> ./nginx/nginx.conf

    #read in the SSL config for the docker-compose file. Basically the same execpt it binds to 443 as well and mounts the SSL volume
    echo "version: '3'
services:
  nginx: 
    image: nginx:latest
    container_name: nginx
    restart: always
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./nginx/ssl/:/tmp/
    environment: 
      - GITLAB_SERVER=gitlabsvr:80
    ports:
      - 80:80
      - 443:443
    networks: 
      - glnetwork
    links: 
      - gitlabsvr
    depends_on: 
      - gitlabsvr
      
  gitlabsvr:
    image: 'gitlab/gitlab-ee:latest'
    restart: always
    container_name: gitlab
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/logs:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'  
    networks: 
      - glnetwork   

networks:
  glnetwork:
    driver: bridge">docker-compose.yml

  echo "Add your cert and key to ./nginx/ssl/nginx.crt and ./nginx/ssl/nginx.key"

elif [ $SSL == "no" ]
then
  # Read in the HTTP NGINX config file.
   echo "server {
  listen 80;
  location / {
    proxy_pass http://gitlabsvr/;
  }
}"> ./nginx/nginx.conf

    # Read in the HTTP docker-compose file
    echo "version: '3'
services:
  nginx: 
    image: nginx:latest
    container_name: nginx
    restart: always
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
    environment: 
      - GITLAB_SERVER=gitlabsvr:80
    ports:
      - 80:80
    networks: 
      - glnetwork
    links: 
      - gitlabsvr
    depends_on: 
      - gitlabsvr
      
  gitlabsvr:
    image: 'gitlab/gitlab-ee:latest'
    restart: always
    container_name: gitlab
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost'
    volumes:
      - './gitlab/config:/etc/gitlab'
      - './gitlab/logs:/var/log/gitlab'
      - './gitlab/data:/var/opt/gitlab'  
    networks: 
      - glnetwork   

networks:
  glnetwork:
    driver: bridge">docker-compose.yml
fi

echo "run 'docker-compose up -d' to start the containers"