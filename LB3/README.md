# LB3
- [LB3](#lb3)
  - [Documentation](#documentation)
    - [Idea](#idea)
    - [Overview](#overview)
    - [Installation](#installation)
    - [Usage](#usage)
    - [Test cases](#test-cases)
    - [Security](#security)
    - [Theory](#theory)
    - [Reflection](#reflection)
      - [General](#general)
      - [Lessons Learned](#lessons-learned)
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
https://github.com/mc-b/M300/tree/master/docker/apache
https://github.com/mc-b/M300/tree/master/docker/mysql
https://github.com/mc-b/M300/tree/master/docker/compose

### Idea
Currently my friends and I use the description field of our WhatsApp Group the write down what we'd like to do together.
But recently we encountered a little problem, the description field has a max. character length...
Also it can be quite tricky to figure out what the original idea was, because we don't write down our names with the event proposal.

So I came up with the following solution:

Create multiple machines and connect them together to create a Web portal where only members can write text, but that text is visible in read only mode to anybody visiting the Webpage.

For this I needed:
- Web service
- Database
- User and Rights distribution

In the end I left out the IAM part, because of a lack of time and energy, but I still setup the server.

### Overview
![A Web-, Database- and IAM-Server](/LB3/assets/architecture_diagram.svg)

- [HomePage](http://localhost:8080/)
- [ReverseProxy_to_IAMServer](http://localhost:8080/iam)
- [Adminer.php](http://localhost:8080/adminer.php)
  - Server: `192.168.55.100`
  - Username: `root`
  - Password: `admin`
  - Database: `proposals`
- [openLDAP](http://localhost:8080/iam/phpldapadmin/)
  - Username: `cn=admin,dc=nodomain`
  - Password: `admin`

### Installation
1. git clone the repo
2. [setup docker](https://docs.docker.com/engine/install/)
3. install docker compose `sudo apt-get install docker-compose`
4. run `docker build -t db .` in `M300/LB3/the_wall/db`
5. run `docker build -t web .` in `M300/LB3/the_wall/web`
6. run `docker build -t monitor .` in `M300/LB3/the_wall/monitor`

### Usage
1. `docker run --rm -d --name db db`
2. `docker run --rm -d -p 8080:80 --name web web`
3. `docker run --rm -d --name monitor monitor`
4. Visit `http://localhost:8080/` in your browser

### Test cases


### Security


### Theory
https://docs.docker.com/engine/install/ubuntu/  

### Reflection
#### General


#### Lessons Learned


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
- [ ] Personal Knowledge base on the following topics is documented:
  - [ ] Container
  - [ ] Docker
  - [ ] Micro-services
- [x] Important Learning steps are documented
### K3 | Docker
- [ ] Combine existing Docker containers
- [ ] Use existing container as a backend and a desktop app as fronted
- [ ] Volumes for persistent File storage is implemented
- [ ] Knows the Docker commands
- [ ] Setup is documented
  - [ ] Environment Variables
  - [ ] Network diagram
  - [ ] Layers
  - [ ] Security aspects
- [ ] Functionality tested with Test cases
- [X] Project documented with MarkDown
### K4 | Security
- [ ] Service monitoring is implemented
- [ ] Active notifications are setup
- [ ] min. 3 aspects of Container segmentation are taken into consideration
  - [ ] Kernel Exploits
  - [ ] Denial-of-Service-(DoS-) Attacks
  - [ ] Container-Breakouts
  - [ ] Poisoned images
    - Use verified images
  - [ ] Revealed secrets
- [ ] Security measures are documented
- [X] Project documented with MarkDown
### K5 | Misc criteria (general)
- [ ] Creativity
- [ ] Complexity
- [ ] Scope
- [ ] Realization of your own idea
- [ ] Contribute to the original Documentation
  - Bestehenden Docker-`Dontainer` kombinieren
  - MAINTAINER ist veraltet (https://docs.docker.com/engine/reference/builder/#maintainer-deprecated)
- [ ] Comparison prior vs increased knowledge
- [ ] Reflection
### K6 | Misc criteria (Systems engineers)
- [ ] Complex networking of Container Infrastructure (Approaches for real usage scenarios)
- [ ] Make Image available (via Dockerfile, Registry or Archive file)
- [ ] CI setup (Continuous Integration)
- [ ] Cloud-Integration
- [ ] Part of the Kubernetes exercise are implemented and documented
