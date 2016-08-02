# ubuntu-16-passenger-python-3.5

**_Current Status: Work In Progress_**

A Docker image to use as a basis for Python 3.5 based web applications running under Phusion Passenger and nginx. Intended for eventual deployment under OpenShift.

* Python is a programming language: https://www.python.org/
* Phusion Passenger is a web application server: https://www.phusionpassenger.com/
* Nginx is a high performance HTTP server: https://www.nginx.com/
* OpenShift is a container application platform based on Docker: https://www.openshift.org/
* Docker is an software containerization tool: https://www.docker.com/

## Quick Start

```
docker run -d -P -v /var/www/ --name=djangoapp astrolox/ubuntu-16-passenger-python-3.5
```

## Environment variables

All configuration is via environment variables.

* ``SSL_CERT`` - Path to an x509 PEM encoded digitgial certificate
* ``SSL_KEY`` - Path to the x509 PEM encoded key for the digital certificate
