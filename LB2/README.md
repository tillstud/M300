# LB2
- [LB2](#lb2)
  - [Documentation](#documentation)
    - [Idea](#idea)
    - [Overview](#overview)
    - [Test cases](#test-cases)
    - [Security](#security)
      - [Firewall](#firewall)
      - [Reverse-Proxy](#reverse-proxy)
      - [User and Rights distribution](#user-and-rights-distribution)
      - [Access via SSH tunnel](#access-via-ssh-tunnel)
    - [Reflection](#reflection)
      - [General](#general)
      - [Lessons Learned](#lessons-learned)
  - [Grading criteria](#grading-criteria)
    - [K1 | Tool environment](#k1--tool-environment)
    - [K2 | Learning environment](#k2--learning-environment)
    - [K3 | Vagrant](#k3--vagrant)
    - [K4 | Security](#k4--security)
    - [K5 | Misc criteria](#k5--misc-criteria)

---
---

## Documentation
This Project is based on: https://github.com/mc-b/M300/tree/master/vagrant/fwrp

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
![A Web-, Database- and IAM-Server](/LB2/assets/for_documentation/architecture_diagram.svg)

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

### Test cases
| Nr. | Description | Check | Should-Situation | Is-Situation | OK? |
|:-:|-|-|-|-|:-:|
| 1 | `web` should be able to ping `iam` on port `80` | `nc -vz 192.168.55.102 80` | `Connection to 192.168.55.102 80 port [tcp/http] succeeded!` | `Connection to 192.168.55.102 80 port [tcp/http] succeeded!` | Y |
| 2 | `web` should be able to ping `db` on port `3306` | `nc -vz 192.168.55.100 3306` | `Connection to 192.168.55.100 3306 port [tcp/mysql] succeeded!` | `Connection to 192.168.55.100 3306 port [tcp/mysql] succeeded!` | Y |
| 3 | `db` should NOT be able to ping `iam` on port `80` | `nc -vz 192.168.55.102 80` | `nc: connect to 192.168.55.102 port 80 (tcp) failed: Connection timed out` | `nc: connect to 192.168.55.102 port 80 (tcp) failed: Connection timed out` | Y |
| 4 | `iam` should NOT be able to ping `db` on port `3306` | `nc -vz 192.168.55.100 3306` | `nc: connect to 192.168.55.100 port 3306 (tcp) failed: Connection timed out` | `nc: connect to 192.168.55.100 port 3306 (tcp) failed: Connection timed out` | Y |
| 5 | On [web](http://localhost:8080/) anybody should be able to input their name, proposal and press submit.<br>After that the information should be stored in the `proposals/data` on the `db` server. | 1. `mysql -uroot -pS3cr3tp4ssw0rd`<br>2. `use proposals;`<br>3. `SELECT uname, proposal FROM data;` | check if the input values are visible in the list | Input Variables are visible. | Y |
| 6 | Check if Python backend worked | After some Values are submitted on [web](http://localhost:8080/), they should be displayed under the submit button. | Values are displayed | Values are displayed, after I cleared my browser history. | N |
| 7 | Check if reverse proxy works | Visiting [localhost:8080/iam](http://localhost:8080/iam) should show the default apache2 site | Show apache2 default page | Show apache2 default page | Y |
| 8 | Check if `Adminer` works | Open [localhost:8080/adminer.php](http://localhost:8080/adminer.php) and input the credentials described in the [Overview](#overview) section.<br>After that you should be presented with the view to select the `data` table. | Presented with the view to select the `data` table. | Presented with the view to select the `data` table. | Y |
| 9 | Check if php LDAP admin works | Open [localhost:8080/iam/phpldapadmin/](http://localhost:8080/iam/phpldapadmin/) and input the credentials described in the [Overview](#overview) section.<br>After that you should be able to select the `nodomain` domain controller. | Able to select the `nodomain` domain controller. | Able to select the `nodomain` domain controller. | Y |

For debugging:
```shell
# on web server
sudo tail /var/log/apache2/error.log
sudo tail /var/log/apache2/access.log
```

### Security
In general I'm not quite happy with the Security measures taken, because for example the CGI can be accessed by anybody and no IAM solution is properly implemented. Also every password is hardcoded and accessible to by every server (because /vagrant is synced), which makes lateral movements through the network very easy!

I wouldn't expose this setup to the Internet!

#### Firewall
| Server | Firewall Rules |
|:-:|-|
| web | sudo ufw allow 80/tcp<br>sudo ufw allow 22/tcp |
| iam | sudo ufw allow 22/tcp<br>sudo ufw allow from 192.168.55.101 to any port 80 |
| db | sudo ufw allow 22/tcp<br>sudo ufw allow from 192.168.55.101 to any port 3306 |

#### Reverse-Proxy
The Reverse Proxy is managed in `/etc/apache2/sites-available/001-reverseproxy.conf`:
```xml
# general Proxy settings
ProxyRequests Off
<Proxy *>
      Order deny,allow
      Allow from all
</Proxy>

# redirection to IAM
ProxyPass /iam http://iam	
ProxyPassReverse /iam http://iam  
```

#### User and Rights distribution
The `iam` Server (openLDAP), is setup and configured, but isn't used. Every user is hardcoded:

| Server | User | Password |
|:-:|-|-|
| web | www-data |  |
| iam | admin | admin |
| db | root | admin |

#### Access via SSH tunnel
Once the VM's are up (`vagrant up`), their accessible via:
```shell
vagrant ssh web
vagrant ssh iam
vagrant ssh db
```

### Reflection
#### General
I was already familiar with Git, GitHub, VSCode, Python 3 and somewhat with Linux.

But before this project I hadn't even heard of Vagrant, so everything was new to me.
At first this was quite overwhelming, but after a couple of sessions I got the hang of if quite quickly.
I started to use `vagrant reload xxxx` instead of destroying and creating a new VM for every change my self and wrote down the command I had used inside the vagrant VM, so I could trace back what I did and put the commands into my Vagrantfile.
I also learned how to use Python as a backend (something which I have always wanted to do!) and how to setup a Reverse Proxy. I made the mistake of first going through all of the Theory and doing+writing down (which you can find in the [main README](https://github.com/tillstud/M300) of this repo) everything I did, instead of going through the Theory during the project, as a "side-task".


#### Lessons Learned
- Set End of Line Sequence to "LF" in you IDE of choice (for me it is VSCode)!
- Theory is a side-task!

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
- [x] Personal Knowledge base on the following topics is documented:
  - [x] Linux
  - [x] Virtualization
  - [x] Vagrant
  - [x] Version Control / Git
  - [x] Mark Down
  - [x] System Security
- [x] Important Learning steps are documented
### K3 | Vagrant
- [X] Setup VM from Vagrant Cloud
- [X] Knows the Vagrant Commands
- [X] Setup is documented
  - [X] Environment Variables
  - [X] Network diagram
  - [X] Security aspects
- [X] Functionality tested with Test cases
- [X] second prebuilt VM from Vagrant setup
- [x] Project documented with MarkDown
### K4 | Security
- [X] Firewall with Rules is setup
- [X] Reverse-Proxy is setup
- [] User and Rights distribution is setup
- [X] Access via SSH tunnel is secured
- [X] Security measures are documented
- [x] Project documented with MarkDown
### K5 | Misc criteria
- [X] Creativity
- [X] Complexity
- [] Scope
- [] Cloud-Integration
- [] AuthO & AuthN via LDAP
- [x] Contribute to the original Documentation
  - Extend the Firewall & Proxy theory with my documentation?
  - Autocorrect error? (Applikations-Funktionalitäten integrieren soll (z.B. ist die "Quota" auf einem Mailserver keine `personenbezogenes Datum`, sondern eine Applikations-Information).)
- [X] Comparison prior vs increased knowledge
- [X] Reflection