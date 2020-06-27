# Template: https://gist.github.com/ju2wheels/3d1a1dfa498977874d03

FROM ubuntu:20.04
LABEL maintainer="personal.spareemail@gmail.com"
VOLUME /var/www/html
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
EXPOSE 80
RUN sudo apt-get update
RUN sudo apt-get -y install debconf-utils apache2
RUN echo 'mysql-server mysql-server/root_password password admin' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password admin' | debconf-set-selections
RUN sudo apt-get -y install php libapache2-mod-php php-curl php-cli php-mysql php-gd mysql-client  
# Python backend
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1
RUN sudo update-alternatives --config python
RUN sudo apt install python3-pip -y
RUN sudo pip3 install mysql-connector-python
ADD src/index.html /var/www/html/
ADD src/backend.py /usr/lib/cgi-bin/
RUN sudo chown www-data /usr/lib/cgi-bin/backend.py && sudo chmod 755 /usr/lib/cgi-bin/backend.py
RUN sudo mkdir /usr/share/tmp/
RUN sudo touch /usr/share/tmp/text.txt
RUN sudo chmod 755 /usr/share/tmp/text.txt
RUN sudo ln -s /usr/share/tmp/text.txt /var/www/html/text.txt
ADD src/000-default.conf /etc/apache2/sites-available/
RUN sudo chown www-data:www-data /usr/share/tmp/text.txt 
# Admininer SQL UI 
RUN sudo mkdir /usr/share/adminer
RUN sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
RUN sudo ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php
RUN echo "Alias /adminer.php /usr/share/adminer/adminer.php" | sudo tee /etc/apache2/conf-available/adminer.conf
RUN sudo a2enconf adminer.conf 
RUN sudo a2enmod cgi
RUN sudo mkdir -p  /var/www/html/data && sudo chown www-data:www-data /var/www/html/data 
CMD /bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
STOPSIGNAL SIGTERM
#HEALTHCHECK --interval=15 --timeout=60 --retries=5 CMD [ "/usr/bin/my_health_check_script", "arg_1" ]