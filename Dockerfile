FROM astrolox/ubuntu-16:latest
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
	apt-get autoremove -q -y && \
	apt-get clean -q -y && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/www/html && \
	mkdir -p /var/www/html && \
	chmod -R 777 /var/www/html /var/log/nginx /var/lib/nginx && \
	chmod -R 755 /hooks /init /etc/ssl/private && \
	chmod 777 /etc/passwd /etc/group /etc && \
	/usr/bin/pyvenv /python3-virtualenv/ && \
	/python3-virtualenv/bin/python --version && \
	/python3-virtualenv/bin/pip --version && \
	/python3-virtualenv/bin/pip install --no-cache-dir --upgrade pip && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	sed -i -r -e '/^user www-data;/d' /etc/nginx/nginx.conf && \
	sed -i -e '/sendfile on;/a\        client_max_body_size 0\;' /etc/nginx/nginx.conf && \
	sed -i -e 's|# include /etc/nginx/passenger|include /etc/nginx/passenger|' /etc/nginx/nginx.conf && \
	sed -i -e 's|listen 80|listen 8080|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|listen \[::\]:80|listen \[::\]:8080|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|# listen 443|listen 8443|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|# listen \[::\]:443|listen \[::\]:8443|' /etc/nginx/sites-enabled/default && \
	sed -i -e 's|# include snippets/snakeoil.conf;|include snippets/snakeoil.conf;|' /etc/nginx/sites-enabled/default && \
	perl -0 -p -i -e 's/location \/ \{.*?\}/location \/ \{ passenger_enabled on; passenger_app_type wsgi; \}/s' /etc/nginx/sites-enabled/default && \
	echo "passenger_python /python3-virtualenv/bin/python3;" >> /etc/nginx/passenger.conf && \
	echo "passenger_user_switching off;" >> /etc/nginx/passenger.conf && \
	/usr/bin/passenger-config validate-install  --auto --no-colors
EXPOSE 8080 8443
VOLUME /var/www/html
WORKDIR /var/www/html
