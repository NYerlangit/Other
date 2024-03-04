Развену ансибел на контейнере.
Dockerfile
FROM ubuntu:jammy
RUN apt-get update && apt-get install -y ansible sshpass nano
COPY $PWD/playbooks/hosts /etc/ansible/hosts
COPY $PWD/playbooks/startjob.sh /startjob.sh
Добавляем команду ожидания (бесконечный цыкл)
CMD ["/./startjob.sh"]

Делаю бесконечный цыкл
startjob.sh
#!/bin/bash
tail -f /dev/null

Не хочу сохранять контейнер, поэтому сделаю через композер.
docker-compose.yml
version: '3'
services:
  ansible:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ./playbooks:/playbook

Подключаюсь к контейнеру.
docker-compose exec ansible bash


#Ansible

Инвентори файл
/playbook/hosts
homevm1 ansible_host=37.151.238.25 ansible_port=2222 ansible_user=ansible ansible_ssh_pass=password

Проверка подключения Ansible и хостами.
ansible all -i /playbook/hosts -m ping

ansible-playbook /playbook/playbook_v2.yml -i /playbook/hosts
Не идет, потому что удаленный хост требует ввести пароль рута. 
Для этого там надо редактировать /etc/sudoers
И добавлять: ansible ALL=(ALL:ALL) NOPASSWD: ALL
Использовать: sudo visudo

playbook/playbook.yml
---
- hosts: "homevm1"
  become: true
  tasks:
  - name: "Install nginx,MySQL_php via apt"
    ansible.builtin.apt:
      name: "{{ item }}"
      state: "latest"
      update_cache: true
    loop:
      - nginx
      - php-fpm
      - php8.1-fpm
      - mysql-server
      - php-mysql
  - name: "Stopped nginx"
    ansible.builtin.service:
      name: "nginx"
      state: "stopped"
  - name: "Copy phpinfo to /var/www/html"
    ansible.builtin.copy:
      src: "/phpinfo.php.j2"
      dest: "/var/www/html/index.php"
      owner: "ansible"
      group: "ansible"
      mode: "0644"
  - name: "Copy nginx configuration"
    ansible.builtin.copy:
      src: "/playbook/default.conf"
      dest: "/etc/nginx/sites-available/default"
      owner: "ansible"
      group: "ansible"
      mode: "0644"
  - name: "Start Nginx_mysql,php-fpm and boot"
    service:
      name: "{{ item }}"
      state: "started"
      enabled: "yes"
    loop:
      - nginx
      - php8.1-fpm
      - mysql



Чтобы включить PHP надо изменить конфиг файл.
/playbook/default
/etc/nginx/sites-available/default
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name _;
        location / { try_files $uri $uri/ =404 }
        location ~ \.php$ {
               include snippets/fastcgi-php.conf;
               fastcgi_pass unix:/run/php/php8.1-fpm.sock; }
        location ~ /\.ht { deny all; }
}
ЗАПУСК!
ansible-playbook /playbook/playbook.yml -i /playbook/hosts --ssh-extra-args='-o StrictHostKeyChecking=no'  -b
Проверка:
http://192.168.1.65/index.php
Есть информация ..... PHP Version 8.1.2-1ubuntu2.14.....
