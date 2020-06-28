# Template: https://gist.github.com/ju2wheels/3d1a1dfa498977874d03

FROM ubuntu:20.04
LABEL maintainer="personal.spareemail@gmail.com"
VOLUME /usr/local/apache2/htdocs/
EXPOSE 80

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update
RUN apt-get -q -y install debconf-utils
RUN echo 'mysql-server mysql-server/root_password password admin' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password admin' | debconf-set-selections
RUN apt-get -y install php libapache2-mod-php php-curl php-cli php-mysql php-gd mysql-client  

# Python backend

RUN apt-get install python3 -y
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1
#RUN update-alternatives --config python
RUN apt install python3-pip -y
RUN pip3 install mysql-connector-python
ADD src/index.html /var/www/html/
# COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf
ADD src/backend.py /usr/lib/cgi-bin/
RUN chown www-data /usr/lib/cgi-bin/backend.py
RUN chmod 755 /usr/lib/cgi-bin/backend.py
RUN mkdir /usr/share/tmp/
RUN touch /usr/share/tmp/text.txt
RUN chmod 755 /usr/share/tmp/text.txt
RUN ln -s /usr/share/tmp/text.txt /var/www/html/text.txt
ADD src/000-default.conf /etc/apache2/sites-available/
RUN chown www-data:www-data /usr/share/tmp/text.txt 

# Admininer SQL UI 
RUN mkdir /usr/share/adminer
RUN apt-get install wget
RUN wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
RUN ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php
RUN echo "Alias /adminer.php /usr/share/adminer/adminer.php" | tee /etc/apache2/conf-available/adminer.conf
RUN a2enconf adminer.conf 
RUN a2enmod cgi
RUN mkdir -p  /var/www/html/data && chown www-data:www-data /var/www/html/data

# Services restart / reload config
RUN service apache2 restart 

CMD /bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
STOPSIGNAL SIGTERM
#HEALTHCHECK --interval=15 --timeout=60 --retries=5 CMD [ "/usr/bin/my_health_check_script", "arg_1" ]