#!/bin/bash

#elevando permissão de usuário para root
sudo su - 

#atualizando os pacotes do servidor
yum upgrade -y
cd /

#instalando o amazon-efs-utils (e habilitando sua inicialização junto do boot do servidor e inicando esse serviço)
yum install -y amazon-efs-utils
chkconfig amazon-efs-mount-watchdog.service on
service amazon-efs-mount-watchdog start

#instalando o docker (e habilitando sua inicialização junto do boot do servidor e inicando esse serviço)
yum install -y docker
chkconfig docker on
service docker start

#baixando, instalando e dando permissão para o docker compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#criando os diretórios que serão usados no laboratório
mkdir wordpress && cd wordpress
mkdir compose && mkdir data

#inserir o comando aqui para a montagem do sistema de arquivos (aws efs) criado (sudo mount..., substituir efs por "data" - é o diretório que será montado em nosso sistema de arquiqos)

cd compose

#criando o arquivo docker-compose.yml
cat << EOF > docker-compose.yml
services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: \${DB_HOST}
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: \${SENHA_DB}
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - /wordpress/data:/var/www/html
EOF

#criando o arquivo .env (que vai conter as variaveis de senha do usuario do banco e endpoint da instância rds)
cat << EOF > .env
SENHA_DB=inserir senha do usuário do banco de dados 
DB_HOST=inserir_host_rds
EOF

#subindo o container do wordpress da instância ec2
docker-compose up -d
