FROM ubuntu:jammy
RUN apt-get update && apt-get install -y ansible sshpass nano
COPY $PWD/playbooks/playbook.yml /playbook.yml
COPY $PWD/playbooks/hosts /etc/ansible/hosts
COPY $PWD/playbooks/startjob.sh /startjob.sh
COPY $PWD/playbooks/phpinfo.php.j2 /phpinfo.php.j2
# Добавляем команду ожидания
CMD ["/./startjob.sh"]
