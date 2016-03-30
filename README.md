# Docker Image for Atlassian Confluence 5.9.5

*this documentation isn't fully done yet - we're still working on major and minor issues corresponding to this repository base!*

This repository provides the latest version of Atlassians collaboration software [Confluence](https://de.atlassian.com/software/confluence) including the recommended [MySQL java connector](http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz) for an easy and painless docker based Confluence installation. Take note that this repository will be used inside our docker atlassian application workbench sources, which are also available on [Github](https://github.com/dunkelfrosch/docker-atlassian-wb) as soon as documentation is completed. *In this workbench we've combined several Atlassian products (Confluence, Confluence and Bitbucket) using advanced docker features like docker-compose based service management, data-container and links*

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![System Version](https://img.shields.io/badge/version-0.9.9-blue.svg)](VERSION)
[![Build Status](https://api.travis-ci.org/dunkelfrosch/docker-confluence.svg?branch=master)](STATUS)

## Preparation
We recommend the [latest Docker version](https://github.com/docker/docker/blob/master/CHANGELOG.md). For simple system integration and supervision we suggest [Docker Compose](https://docs.docker.com/compose/install/). If you're using MacOS or Windows as host operating system, you may take the advantage of [Docker Machine](https://www.docker.com/docker-machine) for Docker's VM management. Confluence requires a relational database like MySQL or PostgreSQL, so we'll provide a specific Docker Compose configuration file to showcase both a Confluence-MySQL link and a data-container feature configuration. Use the installation guides of provided links down below to comply your Docker preparation process.

[docker installation guide](https://docs.docker.com/engine/installation/)</br>
[docker-compose installation guide](https://docs.docker.com/compose/install/)</br>
[docker machine installation guide](https://docs.docker.com/machine/install-machine/)</br>


## Installation-Method 1, using docker
These steps will show you the generic, pure docker-based installation of Atlassian Confluence image/container, without any database container linked or data-container feature.  *We also will provide (and recommend) a docker-compose based installation in this documentation (↗ Installation-Method 2)*.

1) checkout this repository

```bash
git clone https://github.com/dunkelfrosch/docker-confluence.git .
```

2.1) build your Confluence image (version 5.9.5) on your local docker host, naming image "dunkelfrosch/confluence:5.9.5"

```bash
docker build -t dunkelfrosch/confluence:5.9.5
```

2.2) pull our compiled Confluence image from docker-hub directly by activating the corresponding lines in our docker-compose.yml file below the "restart: always" line: "image: df/dunkelfrosch-confluence"

*take note, that the currently available image version of confluence on docker hub is still 5.9.3, we'll push the latest versions in the next few days*


3) start your new confluence application container

```bash
docker run -d -p 8090:8090 dunkelfrosch/confluence 
```
	
4. finish your installation using atlassian's browser based configuration
just navigate to `http://[dockerhost]:8090`. Please take note, that your dockerhost will depend on your host system. If you're using docker on your mac, you'll properly using docker-machine or the deprecated native boot2docker vbox image. In this case your 'dockerhost' ip will be the vbox ones (just enter `docker-machine ls` and grab your named machine's ip from there. In my case (image down below) the resulting setup-ip will be <strong>192.168.99.100:8080</strong> on any other "real" linux system the setup-ip should be 127.0.0.1/localhost (port will be the tomcat application used port 8090)

4.1 The following steps will help you to finalize your confluence server web-based configuration

*we'll update the web-based configuration documentation (including screenshots of the latest setup version) within the next view days*

## Installation-Method 2, via Docker Compose (simple)
The following steps will show you an alternative way of your Confluence service container installation using Docker Compose

1) checkout this repository

```bash
git clone https://github.com/dunkelfrosch/docker-confluence.git .
```
 
2.1) create/use a docker-compose.yml file in your target directory (or use the existing one), afterwards insert the following lines (docker-compose.yml in *./sample-configs/* directory). 

2.2) you can also pull our compiled Confluence image from docker-hub directly, see step 2.2 of installation method 1 

3) start your Confluence container by docker-compose

```bash
docker-compose up -d confluence
```

4) (*optional*) rename the resulting image after successful build (we'll use our image auto-name result here)

```bash
docker tag dfdockerconfluence_confluence dunkelfrosch/confluence:5.9.5
```

5) the result should by a running container and an available local Confluence image


## Installation-Method 3, docker-compose (using db)
Confluence needs a relational DB and for safety reasons we suggest using data-only container features. Take a look inside your *./sample-config* path, we've provided a few sample docker-compose.yml config files below to show you those feature implementations.

./sample-configs/**docker-compose-dc.yml**
> sample configuration for data-container feature

./sample-configs/**docker-compose-linkdb.yml**
> sample configuration for linking mysql container directly

./sample-configs/**docker-compose-dc-v2.yml**
> new docker compose formatted sample configuration for data-container feature

./sample-configs/**docker-compose-linkdb-v2.yml**
> new docker compose formatted sample configuration for linking mysql container directly

./sample-configs/**docker-compose-netdb-v2.yml**
> sample configuration for new networking feature connected mysql/confluence container


## container access and maintenance
You can check container health by accessing logs of inner Tomcat/Confluence processes directly as long as the container is still running. As you can see in this screenshot, Atlassian Confluence was starting successfully (*Let's ignore some minor warnings ;)* )

```bash
docker logs df-atls-confluence
```

You can log in easily to your running Confluence container to take a deeper look in your Confluence service process. *This Confluence build provides midnight-commander as terminal extension accessible typing `mc` in your container session shell*.

```bash
docker exec -it --user root df-atls-confluence /bin/bash
```


## Contribute

This project is still under development and contributors are always welcome! Please refer to [CONTRIBUTING.md](https://github.com/dunkelfrosch/docker-confluence/blob/master/CONTRIBUTING.md) and find out how to contribute to this project.


## License-Term

Copyright (c) 2015-2016 Patrick Paechnatz <patrick.paechnatz@gmail.com>
                                                                           
Permission is hereby granted,  free of charge,  to any  person obtaining a 
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction,  including without limitation
the rights to use,  copy, modify, merge, publish,  distribute, sublicense,
and/or sell copies  of the  Software,  and to permit  persons to whom  the
Software is furnished to do so, subject to the following conditions:       
                                                                           
The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.
                                                                           
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING  BUT NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING
FROM,  OUT OF  OR IN CONNECTION  WITH THE  SOFTWARE  OR THE  USE OR  OTHER DEALINGS IN THE SOFTWARE.