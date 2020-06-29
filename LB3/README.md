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
    - [Container](#container)
    - [Docker](#docker)
    - [Micro-services](#micro-services)
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
1. Visit `http://localhost:8080/` in your browser
2. Visit `http://localhost:9999/containers/` in your browser
3. Visit `http://localhost:8080/adminer.php` in your browser
> Use the credentials described in the [Overview](#overview) section.

### Test cases
| Nr. | Description | Check | Should-Situation | Is-Situation | OK? |
|:-:|-|-|-|-|:-:|
| 1 | `web` should be able to ping `db` on port `3306` | `nc -vz 172.20.0.11 3306` | `Connection to 172.20.0.11 3306 port [tcp/mysql] succeeded!` | `Connection to 172.20.0.11 3306 port [tcp/mysql] succeeded!` | Y |
| 2 | `db` should be able to ping `web` on port `80` | `nc -vz 172.20.0.12 80` | `Connection to 172.20.0.12 80 port [tcp/httpd] succeeded!` | `Connection to 172.20.0.12 80 port [tcp/httpd] succeeded!` | Y |
| 3 | On [web](http://localhost:8080/) anybody should be able to input their name, proposal and press submit.<br>After that the information should be stored in the `proposals/data` on the `db` server. | 1. `mysql -uwww-data -pS3cr3tp4ssw0rd`<br>2. `use proposals;`<br>3. `SELECT uname, proposal FROM data;` | check if the input values are visible in the list | Input Variables are visible. | Y |
| 4 | Check if Python backend worked | After some Values are submitted on [web](http://localhost:8080/), they should be displayed under the submit button. | Values are displayed | Values are displayed, after I cleared my browser history. | N |
| 5 | Check if `cAdvisor` works | After the containers are up and running [cAdvisor](http://localhost:9999/) should desplay live stats | Stats are displayed | Stats are displayed | Y |
| 6 | Check if `Adminer` works | Open [localhost:8080/adminer.php](http://localhost:8080/adminer.php) and input the credentials described in the [Overview](#overview) section.<br>After that you should be presented with the view to select the `data` table. | Presented with the view to select the `data` table. | Presented with the view to select the `data` table. | Y |

### Security
In general I'm not quite happy with the Security measures taken, because for example the CGI can be accessed by anybody and no IAM solution is implemented. Also every password is hardcoded and accessible to anybody (because this repo is public), which makes lateral movements through the network very easy!

I wouldn't expose this setup to the Internet!

### Theory
### Container
https://docs.docker.com/engine/install/ubuntu/
### Docker
### Micro-services


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
- [x] Combine existing Docker containers
- [x] Use existing container as a backend and a desktop app as fronted
- [x] Volumes for persistent File storage is implemented
- [x] Knows the Docker commands
- [ ] Setup is documented
  - [X] Environment Variables
  - [X] Network diagram
  - [X] Layers
  - [ ] Security aspects
- [ ] Functionality tested with Test cases
- [X] Project documented with MarkDown
### K4 | Security
- [x] Service monitoring is implemented
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
- [x] Creativity
- [x] Complexity
- [ ] Scope
- [X] Realization of your own idea
- [X] Contribute to the original Documentation
  - Bestehenden Docker-`Dontainer` kombinieren
  - MAINTAINER ist veraltet (https://docs.docker.com/engine/reference/builder/#maintainer-deprecated)
- [ ] Comparison prior vs increased knowledge
- [ ] Reflection
### K6 | Misc criteria (Systems engineers)
- [x] Complex networking of Container Infrastructure (Approaches for real usage scenarios)
- [ ] Make Image available (via Dockerfile, Registry or Archive file)
- [ ] CI setup (Continuous Integration)
- [ ] Cloud-Integration
- [ ] Part of the Kubernetes exercise are implemented and documented
