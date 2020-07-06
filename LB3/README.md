# LB3
- [LB3](#lb3)
  - [Documentation](#documentation)
    - [Idea](#idea)
    - [Overview](#overview)
    - [Installation](#installation)
    - [Usage](#usage)
      - [Web UI](#web-ui)
      - [CLI](#cli)
    - [Test cases](#test-cases)
    - [Security](#security)
      - [Aspects](#aspects)
    - [Theory](#theory)
      - [Container](#container)
        - [Traits](#traits)
        - [History](#history)
      - [Docker](#docker)
        - [Architecture](#architecture)
        - [Commands](#commands)
        - [Dockerfile](#dockerfile)
        - [Concepts](#concepts)
        - [Networking](#networking)
          - [Host Connection](#host-connection)
          - [Container Connection](#container-connection)
        - [Volumes](#volumes)
          - [Volumes](#volumes-1)
          - [File container](#file-container)
          - [Named Volumes](#named-volumes)
        - [Installation](#installation-1)
      - [Micro-services](#micro-services)
    - [Reflection](#reflection)
  - [Grading criteria](#grading-criteria)
    - [K1 | Tool environment](#k1--tool-environment)
    - [K2 | Learning environment](#k2--learning-environment)
    - [K3 | Docker](#k3--docker)
    - [K4 | Security](#k4--security)
    - [K5 | Misc criteria (general)](#k5--misc-criteria-general)
    - [K6 | Misc criteria (Systems engineers)](#k6--misc-criteria-systems-engineers)

---
---

## Documentation
This Project is based on: https://github.com/mc-b/M300/tree/master/docker/compose

### Idea
Currently my friends and I use the description field of our WhatsApp Group the write down what we'd like to do together.
But recently we encountered a little problem, the description field has a max. character length...
Also it can be quite tricky to figure out what the original idea was, because we don't write down our names with the event proposal.

So I came up with the following solution:

Create multiple container and connect them together to create a Web portal visiters can write text and that text is visible to anybody visiting the Webpage.

For this I needed:
- Web service
- Database
- Monitoring Service

### Overview
![A Web-, Database- and IAM-Server](/LB3/assets/architecture_diagram.svg)

- [HomePage](http://localhost:8080/)
- [Adminer.php](http://localhost:8080/adminer.php)
  - Server: `172.20.0.11:3306`
  - Username: `www-data`
  - Password: `S3cr3tp4ssw0rd`
  - Database: `proposals`
- [cAdvisor](http://localhost:9999/)

### Installation
1. git clone the repo
2. [setup docker](https://docs.docker.com/engine/install/)
3. install docker compose `sudo apt-get install docker-compose`
4. `docker-compose up -d`

### Usage

#### Web UI

1. Visit `http://localhost:8080/` in your browser
2. Visit `http://localhost:9999/containers/` in your browser
3. Visit `http://localhost:8080/adminer.php` in your browser
> Use the credentials described in the [Overview](#overview) section.

#### CLI

1. Get into the Container `docker exec -it the_wall_web_1 bash`
2. `python3 /usr/lib/cgi-bin/backend.py -n [THE_NAME] -p [THE_PROPOSAL]`
3. Visit `http://localhost:8080/` in your browser

### Test cases
| Nr. | Description | Check | Should-Situation | Is-Situation | OK? |
|:-:|-|-|-|-|:-:|
| 1 | `web` should be able to ping `db` on port `3306` | `nc -vz 172.20.0.11 3306` | `Connection to 172.20.0.11 3306 port [tcp/mysql] succeeded!` | `Connection to 172.20.0.11 3306 port [tcp/mysql] succeeded!` | Y |
| 2 | `db` should be able to ping `web` on port `80` | `nc -vz 172.20.0.12 80` | `Connection to 172.20.0.12 80 port [tcp/httpd] succeeded!` | `Connection to 172.20.0.12 80 port [tcp/httpd] succeeded!` | Y |
| 3 | On [web](http://localhost:8080/) anybody should be able to input their name, proposal and press submit.<br>After that the information should be stored in the `proposals/data` on the `db` server. | 1. `mysql -uwww-data -pS3cr3tp4ssw0rd`<br>2. `use proposals;`<br>3. `SELECT uname, proposal FROM data;` | check if the input values are visible in the list | Input Variables are visible. | Y |
| 4 | Check if Python backend Web interface worked | After some Values are submitted on [web](http://localhost:8080/), they should be displayed under the submit button. | Values are displayed | Values aren't displayed, the browser doesn't pass the submitted values to the backend adn cant locate the backend file in `/usr/lib/cgi-bin/backend.py`. | N |
| 5 | Check if Python backend CLI worked | After some Values are submitted on via the CLI, like : `python3 /usr/lib/cgi-bin/backend.py -n Tester -p "Works :)"` , they should be displayed under the submit button on the [Web UI]((http://localhost:8080/)) and also via [Adminer.php](http://localhost:8080/adminer.php) on the `db`. | Values are displayed and stored on `db` | Values are displayed and stored on `db` | Y |
| 6 | Check if `cAdvisor` works | After the containers are up and running [cAdvisor](http://localhost:9999/) should desplay live stats | Stats are displayed | Stats are displayed | Y |
| 7 | Check if `Adminer` works | Open [localhost:8080/adminer.php](http://localhost:8080/adminer.php) and input the credentials described in the [Overview](#overview) section.<br>After that you should be presented with the view to select the `data` table. | Presented with the view to select the `data` table. | Presented with the view to select the `data` table. | Y |

For debugging:
```shell
# on web server
tail /var/log/apache2/error.log
tail /var/log/apache2/access.log
```

### Security
In general I'm not quite happy with the Security measures taken, because for example the CGI can be accessed by anybody and no IAM solution is implemented. Also every password is hardcoded and accessible to anybody (because this repo is public), which makes lateral movements through the network very easy!

I wouldn't expose this setup to the Internet!

#### Aspects
- DoS-attacks are only monitored, via the HEALTHCHECK of `web` Container, but not actively hindered. For this a provider like Cloudflare or load-balancer would be needed.
- Container-Breakouts are possible and very dangerous, because my Docker-Engine is run as root. This means that if a malicious actor can breakout of the container he/she will have root access on the host and can do whatever he/she wants. Currently this isn't a big issue, since I don't have any critical information stored on my docker host.
- Poisoned images, are not a problem since I'm strictly using verified images. If a malicious actor would want to poison them he/she would have to start a MITM (Man-in-the-middle) attack.


### Theory

#### Container

##### Traits
Containers are fundamentally changing the way we develop, distribute, and run software.
Developers can build software locally that will run the same elsewhere - be it a rack in the IT department, a user's laptop or a cluster in the cloud.
Administrators can focus on networks, resources, and uptime, and spend less time configuring environments and fighting system dependencies.

**Features**

- Containers share resources with the host operating system
- Containers can be started and stopped in a fraction of a second
- Applications that run in containers cause little to no overhead
- Containers are portable -> Done with "But it worked on my computer!"
- Containers are lightweight, i.e. dozens can be operated in parallel.
- Containers are "cloud ready"!

##### History

Containers are an old concept. For decades, the chroot command has been available in UNIX systems, which offers a simple form of file system isolation.

FreeBSD has had the jail tool since 1998, which extends chroot sandboxing to processes.

Solaris Zones offered quite a complete containerization technology in 2001, but it was limited to Solaris OS.

Also in 2001 Parallels Inc. (then still SWsoft) published the commercial container technology Virtuozzo for Linux, the core of which was later (in 2005) made available as Open Source under the name OpenVZ.

Then Google started developing CGroups for the Linux kernel and started moving its infrastructure to containers.

The Linux Containers Project (LXC) was initiated in 2008, merging (among other things) CGroups, kernel namespaces and chroot technology to provide a complete containerization solution.

In 2013 Docker finally delivered the missing parts for the containerization puzzle, and the technology began to reach the mainstream.

Recommended reading: [The Missing Introduction To Containerization](https://medium.com/faun/the-missing-introduction-to-containerization-de1fbb73efc5)


#### Docker

Docker took the existing Linux container technology and packaged and expanded it in many ways - primarily through portable images and a user-friendly interface - to create a complete solution for creating and distributing containers.

Put simply, the Docker platform consists of two separate components: the Docker Engine, which is responsible for creating and executing containers, and the Docker Hub, a cloud service for distributing container images.

>Docker was developed for 64-bit Linux systems, but can also be operated using VirtualBox on Mac and Windows.

##### Architecture

**Docker Deamon**

- Build, run and monitor the containers
- Build and save images

The Docker daemon is usually started by the host operating system.

**Docker client**

- Docker is operated via the command line (CLI) using the Docker client
- Communicates with the Docker daemon via HTTP REST

Since all communication is done over HTTP, it is easy to connect to remote Docker daemons and develop bindings to programming languages.

**Images**

- Images are built environments that can be started as containers
- Images cannot be changed, but can only be newly formed.
- Images consist of name and version (TAG), e.g. ubuntu: April 16
  - If no version is specified, the latest is added automatically.

**Container**

- Containers are the executed images
- An image can be executed as a container as often as you like
- Containers and their contents can be changed, so-called Union File Systems are used, which only save the changes to the original image.

**Docker registry**

- Images are stored and distributed in Docker Registries

The standard registry is the Docker Hub, on which thousands of publicly available images are available, but also "official" images.

Many organizations and companies use their own registries to host commercial or "private" images, but also to avoid the overhead associated with downloading images over the Internet.

##### Commands

Official Docs: https://docs.docker.com/engine/reference/commandline/docker/

**docker run**

- Is the command to start new containers.
- By far the most complex command, it supports a long list of possible arguments.
- Allows the user to configure how the image should run, overwrite Dockerfile settings, configure connections and set permissions and resources for the container.

Standard test:
```shell
docker run hello-world
```

Starts a container with an interactive shell (interactive, tty):
```shell
docker run -it ubuntu /bin/bash
```

Starts a container that runs in the background (detach):
```shell
docker run -d ubuntu sleep 20
```

Starts a container in the background and removes it after the job has ended:
```shell
docker run -d --rm ubuntu sleep 20
```

Starts a container in the background and creates a file:
```shell
docker run -d ubuntu touch /tmp/lock
```

Starts a container in the background and outputs the ROOT directory (/) after STDOUT:
```shell
docker run -d ubuntu ls -l
```

**docker ps**

- Provides an overview of the current containers, such as Names, IDs and status.

Show active containers:
```shell
docker ps
```

Show active and finished containers (all):
```shell
docker ps -a
```

Output only IDs (all, quit):
```shell
docker ps -a -q
```

**docker images**

- Returns a list of local images, including information about repository names, tag names and sizes.

Output local images:
```shell
docker images
```

Alternatively with `... image ls`:
```shell
docker image ls
```

**docker rm and docker rmi**

- `docker rm`
  - Removes one or more containers. Returns the names or IDs of successfully deleted containers.
- `docker rmi`
  - Deletes the specified image or images. These are specified by their ID or repository and tag names.

Delete Docker Container:
```shell
docker rm [THE_CONTAINER_NAME]
```

Delete all finished containers:
```shell
docker rm `docker ps -a -q`
```

Delete all containers, including active ones:
```shell
docker rm -f `docker ps -a -q`
```

Delete Docker Image:
```shell
docker rmi ubuntu
```

Delete intermediate images (have no name):
```shell
docker rmi `docker images -q -f dangling=true`
```

**docker start**

- Starts one (or more) stopped containers.
  - Can be used to restart a container that has ended, or to start a container that was created with docker create but never started.

Restart Docker Container, the data is retained:
```shell
docker start [THE_CONTAINER_ID]
```

**Stop and kill containers**

- `docker stop`
  - Stops one or more containers (without removing them). After calling `docker stop` for a container, it is transferred to the "exited" state.
- `docker kill`
  - Sends a signal to the main process (PID 1) in a container. By default, SIGKILL is sent, which stops the container immediately.

**Get info about containers**

- `docker logs`
  - Outputs the "logs" for a container. It is simply everything that was written within the container according to STDERR or STDOUT.
- `docker inspect`
  - Outputs extensive information about containers or images. This includes most configuration options and network settings, as well as volume mappings.
- `docker diff`
  - Reports the changes to the container's file system compared to the image from which it was started.
- `docker top`
  - Returns information about the running processes in a specified container.


##### Dockerfile

A Dockerfile is a text file with a number of steps that can be used to create a Docker image.

To do this, a directory is first created and a file named "Dockerfile" in it.

The image can then be formed as follows:
```shell
docker build -t mysql .
```

Start:
```shell
docker run --rm -d --name mysql mysql
```

Check functionality:
```shell
docker exec -it mysql bash
```

Checking in the container:
```shell
ps -ef
netstat -tulpen
```

>Tipp: use this template: https://gist.github.com/ju2wheels/3d1a1dfa498977874d03

##### Concepts

**Build context**

- The `docker build` command requires a docker file and a build context.
  - The build context is the set of local files and directories that can be addressed from ADD or COPY instructions in the Dockerfile.
  - It is generally defined as the path to a directory.

**Layer / image layers**

- Each instruction in a Dockerfile leads to a new image layer - a layer - which can be used to start a new container.
- The new layer is created by starting a container with the image of the previous layer, then executing the Dockerfile instruction and finally saving a new image.
- If a Dockerfile instruction has been successfully completed, the temporarily created container is deleted again.

**Instructions in the Dockerfile**

- `FROM`
  - Which base image from [hub.docker.com](https://hub.docker.com/) should be used, e.g. ubuntu:20.04
- `ADD`
  - Copies files from the build context or from URLs into the image.
- `CMD`
  - Executes the specified statement when the container is started. If an ENTRYPOINT is also defined, the statement is used as an argument for ENTRYPOINT.
- `COPY`
  - Used to copy files from the build context to the image. There are two forms: COPY src dest and COPY ["src", "dest"]. The JSON array format is necessary if the paths contain spaces.
- `ENTRYPOINT`
  - Specifies an executable (and standard arguments) to run when the container starts.
  - Any CMD statements or arguments passed to `docker run` after the image name are passed as parameters to the executable.
  - ENTRYPOINT statements are often used to trigger "start scripts" that initialize variables and services before other arguments passed are evaluated.
- `EPS`
  - Sets environment variables in the image.
- `EXPOSE`
  - Docker explains that the container contains a process that is listening on the specified port (s).
- `HEALTHCHECK`
  - The Docker Engine regularly checks the status of the application in the container.

```Dockerfile
HEALTHCHECK --interval=5m --timeout=3s \ CMD curl -f http://localhost/ || exit 1`
```

- `MAINTAINER`
  - Sets the "author metadata" of the image to the specified value.
- `RUN`
  - Executes the specified statement in the container and confirms the result.
- `SHELL`
  - The SHELL instruction allows Docker 1.12 to set the shell for the following RUN command. So it is possible that bash, zsh or powershell commands can now be used directly in a Dockerfile.
- `USER`
  - Sets the user (by name or UID) to be used in the following RUN, CMD or ENTRYPOINT statements.
- `VOLUME`
  - Declares the specified file or directory as a volume. If the file or directory already exists in the image, it is copied to the volume when the container is started.
- `WORKDIR`
  - Sets the working directory for all subsequent RUN, CMD, ENTRYPOINT, ADD or COPY statements.


##### Networking

###### Host Connection

Imagine running a web server in a container. How can you then give the outside world access to it?

The answer is to "publish" ports with the -p or -P commands. This command forwards ports to the container's host.

**Examples**

Forward MySQL container permanently to host port 3306:
```shell
docker run --rm -d -p 3306:3306 mysql
```

Connect MySQL container to the next free port:
```shell
docker run --rm -d -P mysql
```

**Dockerfile extension**

To forward ports to the host or the network, these must be entered in the Dockerfile via EXPOSE.

Example MySQL standard port:
```Dockerfile
EXPOSE 3306
```

**Allow access from host**

In order to access the container via the host, some work has to be done.

Installation of the MySQL client on the host:
```shell
sudo apt-get install mysql-client
```

Release of the port in the MySQL config in the container, e.g. via Dockerfile:
```Dockerfile
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
```

SQL release, set up via MySQL client in the container:
```sql
CREATE USER 'root'@'%' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
```

Once all work has been carried out, the MySQL server in the Docker Container should be accessible from the host using the following command:
```shell
mysql -u root -p admin -h 127.0.0.1
```

###### Container Connection

With Docker, "networks" can be created and managed separately from containers.

When you start containers, they can be assigned to an existing network so that they can exchange directly with other containers in the same network.

The following networks are set up as standard:

- bridge
  - The standard network in which mapped ports are visible to the outside.
- none
  - For containers without a network interface or without a network connection.
- host
  - Adds the containers to the internal host network, ports are not visible to the outside.

**Commands**

List the existing networks:
```shell
docker network ls
```

Detailed information, including the running containers to a network:
```shell
docker network inspect bridge
```

Create containers without network interface:
```shell
docker run --network=none -it --name c1 --rm busybox
ifconfig
```

Create containers with the host network:
```shell
docker run --network=host -itd --name c1 --rm busybox
docker inspect host
```

Create a new Brigde network:
```shell
docker network create --driver bridge isolated_nw
```

Start the previous MySQL & Ubuntu example and connect to a new bridge network:
```shell
docker run --rm -d --network=isolated_nw --name mysql mysql
docker run -it --rm --network=isolated_nw --name ubuntu ubuntu:14.04 bash
```

In the Ubuntu container, check the connection to the MySQL server port:
```shell
sudo apt-get update && sudo apt-get install -y curl
curl -f http://mysql:3306
```

**Container linking (deprecated)**

Docker links are the easiest way to let containers talk to each other on the same host. If you use Docker's standard network model, the communication between containers takes place via an internal Docker network so that they cannot be reached in the host network.

Example:
```shell
docker run -it --rm --link mysql:mysql ubuntu:14.04 bash
```

Inside the MySQL container:
```
env

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=53a8e2acc32c
MYSQL_PORT=tcp://172.17.0.2:3306
MYSQL_PORT_3306_TCP=tcp://172.17.0.2:3306
MYSQL_PORT_3306_TCP_ADDR=172.17.0.2
MYSQL_PORT_3306_TCP_PORT=3306
MYSQL_PORT_3306_TCP_PROTO=tcp
MYSQL_NAME=/tender_feynman/mysql
HOME=/root

sudo apt-get update && sudo apt-get install -y curl mysql-client
```

Test whether the port is active (on Ubuntu):
```shell
curl -f http://${MYSQL_PORT_3306_TCP_ADDR}:${MYSQL_PORT_3306_TCP_PORT}
```

Start MySQL Client (on Ubuntu):
```shell
mysql -u root -p admin -h ${MYSQL_PORT_3306_TCP_ADDR}
```

##### Volumes

So far, all changes in the file system were completely lost when the Docker container was deleted.

Docker provides various options for keeping data persistent:

- Store the data on the host
- Share data between containers
- Create your own, so-called volumes, for storing data

**Extension in Dockerfile**

To save data on the host or in volumes, the directory with the data must be entered in the Dockerfile via VOLUME.

Example MySQL:
```Dockerfile
VOLUME /var/lib/mysql
```

###### Volumes

Volumes are a special directory on the host in which one or more containers store their data.

Volumes offer several useful functions for persistent or shared data:

- Volumes are initialized when a container is created.
- If the image of the container contains data at the specified mount point, the existing data is copied to the new volume after volume initialization.
- Volumes can be shared and reused under containers.
- Changes to a "data volume" are made directly.
- Changes to a "data volume" are not taken into account when you update an image.
- Volumes remain even if the container itself is deleted.
- Volumes are designed so that the data persists regardless of the life cycle of the container.
- Docker never deletes volumes automatically when you remove a container, so "garbage" can be left over

####### Examples

Start the Busybox container and create a new volume `/data`:

```
docker run --network=host -it --name c2 -v /data --rm busybox
    
# In the container
cd /data
mkdir t1
echo "Test" >t1/test.txt
    
# CTRL + P + CTRL + Q
docker inspect c2
    
# Search for mounts, e.g.
        "Mounts": [
        {
            "Type": "volume",
            "Name": "ea996345....46ad55c67/_data",
            "Destination": "/data",
            "Driver": "local",
            "Mode": "",
            "RW": true,
            "Propagation": ""
        }
    
# Output file (on host)
sudo cat /var/lib/docker/volumes/ea996345....46ad55c67/_data/t1/test.txt
```

Mount data directory `/var/lib/mysql` from the container on the host (mount):
```shell
docker run -d -p 3306:3306  -v ~/data/mysql:/var/lib/mysql --name mysql --rm mysql
ls -l ~/data/mysql
```

Mount a single file on the host:
```shell
docker run --rm -it -v ~/.bash_history:/root/.bash_history ubuntu /bin/bash
```

###### File container

In the past, data containers were created, the sole purpose of which was to share data with other containers.

First a container had to be started via `docker run` so that others could access it via `--volumes-from`.

This method was functional but could not be expanded.

####### Examples

Create container with data container `dbdata`:
```shell
docker create -v /dbdata --name dbstore busybox 
```

Create a second container that accesses the data container `dbdata`:
```shell
docker run -it --volumes-from dbstore --name db busybox
ls -l /dbdata
```

The data container `dbdata` is now mounted under the root directory as `/dbdata`.

###### Named Volumes

The `docker volume` command for managing volumes on a Docker host has existed since version 1.9 of Docker:

- It can be used to provide various volume driver file systems for containers.
- A volume can now be created on a host and made available to the various containers.
- Volumes can be managed consistently using these commands.
- If no default files are required on the volume, a separate data container can be omitted.
- With this step, various file systems and options can now be used efficiently in containers.

####### Examples

Create a volume `mysql`:
```shell
docker volume create mysql
```

Output of all existing volumes:
```shell
docker volume ls
```

Creates a container `c2` and mounts the volume under `/var/lib/mysql`:
```shell
docker run  -it --name c2 -v mysql:/var/lib/mysql --rm busybox
```

The dependency volume directory can also be stored in the Dockerfile:
```Dockerfile
VOLUME mysql:/var/lib/mysql
```

##### Installation

To get started with Docker Engine on Ubuntu, make sure you [meet the prerequisites](https://docs.docker.com/engine/install/ubuntu/#prerequisites), then [install Docker](https://docs.docker.com/engine/install/ubuntu/#installation-methods).

#### Micro-services

Microservices are one of the largest use cases and the strongest driving force behind the rise of containers.

Microservices are a way of developing and combining software systems in such a way that they consist of small, independent components that interact with each other via the network. This is in contrast to the classic, monolithic way of software development, where there is a single, large program.

If such a monolith then has to be scaled, it is usually only possible to choose to scale up vertically, additional requirements are provided in the form of more RAM and more computing power. Microservices, on the other hand, are designed in such a way that they can be scaled out horizontally (scale out) by processing additional requests by several computers to which the load can be distributed.

In a microservices architecture, it is possible to scale only the resources that are required for a particular service, and thus to be restricted to the bottlenecks of the system. In a monolith, everything or nothing is scaled, which leads to wasted resources.

### Reflection

I was already familiar with Git, GitHub, VSCode, Python 3 and somewhat with Linux.
But before this project I hadn't written Dockerfile whatsoever, so everything was new to me.

At first this was quite overwhelming, but after a couple of sessions I got the hang of if quite quickly.
I started to use docker compose with `docker-compose kill && docker-compose rm` and `docker-compose up -d --build` and wrote down the command I had used inside the container (`docker exec -it [THE_CONTAINER_NAME] bash`), so I could trace back what I did and put the commands into my Dockerfile.
I also learned to use `sys` and `getopt` from the [Python Standard Library](https://docs.python.org/3/library/) to create a CLI interface.
This time I didn't make the mistake of spending most of my time on Theory, rather focus on my project and treat the Theory documentation part rather as a side-task.

---
---

## Grading criteria

### K1 | Tool environment

- [x] VirtualBox
- [x] Vagrant
- [x] VS Code
- [x] Git Client
- [X] SSH Key for Client

### K2 | Learning environment

- [x] GitHub Account created
- [x] Git-Client was used
- [x] Documentation is written in Markdown
- [x] MarkDown editor selected and setup
- [x] MarkDown is properly structured
- [X] Personal Knowledge base on the following topics is documented:
  - [X] Container
  - [X] Docker
  - [X] Micro-services
- [x] Important Learning steps are documented

### K3 | Docker

- [x] Combine existing Docker containers
- [x] Use existing container as a backend and a desktop app as fronted
- [x] Volumes for persistent File storage is implemented
- [x] Knows the Docker commands
- [X] Setup is documented
  - [X] Environment Variables
  - [X] Network diagram
  - [X] Layers
  - [X] Security aspects
- [X] Functionality tested with Test cases
- [X] Project documented with MarkDown

### K4 | Security

- [x] Service monitoring is implemented
- [ ] Active notifications are setup
- [X] min. 3 aspects of Container segmentation are taken into consideration
  - [X] Kernel Exploits
  - [X] Denial-of-Service-(DoS-) Attacks
  - [X] Container-Breakouts
  - [X] Poisoned images
  - [ ] Revealed secrets
- [X] Security measures are documented
- [X] Project documented with MarkDown

### K5 | Misc criteria (general)

- [x] Creativity
- [x] Complexity
- [X] Scope
- [X] Realization of your own idea
- [X] Contribute to the original Documentation
  - Bestehenden Docker-`Dontainer` kombinieren
  - MAINTAINER ist veraltet (https://docs.docker.com/engine/reference/builder/#maintainer-deprecated)
- [X] Comparison prior vs increased knowledge
- [X] Reflection

### K6 | Misc criteria (Systems engineers)

- [X] Complex networking of Container Infrastructure (Approaches for real usage scenarios)
- [X] Make Image available (via Dockerfile, Registry or Archive file)
- [ ] CI setup (Continuous Integration)
- [ ] Cloud-Integration
- [ ] Part of the Kubernetes exercise are implemented and documented
