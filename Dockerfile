FROM astrolox/ubuntu-16
MAINTAINER brian.wojtczak@1and1.co.uk
ARG DEBIAN_FRONTEND=noninteractive
COPY files /
RUN \
	apt-get update -q && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
	apt-get install -q -o Dpkg::Options::=--force-confdef -y apt-transport-https ca-certificates openssl-blacklist && \
	sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list' && \
	apt-get update -q && \
	apt-get install -q -o Dpkg::Options::=--force-confdef -y python3-venv python3-virtualenv python3-all python3-setuptools python3-pip nginx-extras passenger ssl-cert apache2-utils && \
	apt-get install -q -o Dpkg::Options::=--force-confdef -y sqlite3 libmysqlclient-dev mysql-common && \
	apt-get autoremove -q -y && \
	apt-get clean -q -y && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/www/html && \
	rm -rf /var/www && \
	mkdir -p /var/www && \
	mkdir -p /var/www/public && \
	chmod -R 777 /var/www /var/log/nginx /var/lib/nginx && \
	chmod -R 755 /hooks /init /etc/ssl/private && \
	chmod 777 /etc/passwd /etc/group /etc && \
	touch /var/log/nginx/access.log /var/log/nginx/error.log && \
	chmod -R 777 /var/log/nginx/ && \
	/usr/bin/pyvenv /python3-virtualenv/ && \
	/bin/bash -c " \
		source /python3-virtualenv/bin/activate && \
		python --version && \
		pip --version && \
		pip install --no-cache-dir --upgrade pip && \
		pip install --no-cache-dir mysqlclient \
	" && \
	echo "" >> /etc/nginx/nginx.conf && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	mkdir -p /etc/nginx/main.d/ && \
	sed -i -e 's|http {|include /etc/nginx/main.d/*;\nhttp {|' /etc/nginx/nginx.conf && \
	sed -i -r -e '/^user www-data;/d' /etc/nginx/nginx.conf && \
	sed -i -e '/sendfile on;/a\        client_max_body_size 0\;' /etc/nginx/nginx.conf && \
	sed -i -e 's|# include /etc/nginx/passenger|include /etc/nginx/passenger|' /etc/nginx/nginx.conf && \
	sed -i -e 's|listen 80|listen 8080|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|listen \[::\]:80|listen \[::\]:8080|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|# listen 443|listen 8443|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|# listen \[::\]:443|listen \[::\]:8443|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|root /var/www/html|root /var/www/public|' /etc/nginx/sites-enabled/default && \
	perl -0 -p -i -e 's/location \/ \{.*?\}/location \/ \{ passenger_enabled on; passenger_app_type wsgi; \}/s' /etc/nginx/sites-enabled/default && \
	echo "passenger_python /python3-virtualenv/bin/python3;" >> /etc/nginx/passenger.conf && \
	echo "passenger_user_switching off;" >> /etc/nginx/passenger.conf && \
	/usr/bin/passenger-config validate-install  --auto --no-colors
EXPOSE 8080 8443
WORKDIR /var/www
