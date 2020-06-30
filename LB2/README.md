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
    - [Theory](#theory)
      - [Infrastructure automation](#infrastructure-automation)
        - [Theory (Infrastructure as Code)](#theory-infrastructure-as-code)
          - [Goals](#goals)
          - [Tools](#tools)
        - [Packer](#packer)
          - [Installation](#installation)
        - [AWS](#aws)
          - [Theory](#theory-1)
          - [AWS & Vagrant example](#aws--vagrant-example)
      - [Infrastructure Security](#infrastructure-security)
        - [Theory](#theory-2)
          - [Firewall](#firewall-1)
          - [Reverse Proxy](#reverse-proxy-1)
        - [Practice](#practice)
          - [UFW](#ufw)
          - [Reverse Proxy](#reverse-proxy-2)
          - [User & rights management](#user--rights-management)
          - [SSH](#ssh)
          - [Authentication and Authorization](#authentication-and-authorization)
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

### Theory


#### Infrastructure automation

---
##### Theory (Infrastructure as Code)
To comply with the IaC condition a solution must be:
1. Programmable
   - API (Application programming interface) is a **must**!
2. On-Demand
   - Recourses like Servers, Storage and Networks must be created and destroyed quickly
3. Self-Service
   - Resources have to be tailorable to the customers needs
4. Portable
   - Supplier has to be interchangeable to prevent vendor Lock-in
5. Secure
   -  e. g. certified by ISO 27001

IaC is based on software development best practices which usually are:
- Version Control Systems (VCS)
- Testdriven Development (TDD)
- Continuous Integration (CI)
- Continuous Delivery (CD)

###### Goals
- IT Infrastructure supports and allows change
- Change is routine and doesn't cause any headache
- Repeating tasks should be automated
- Business users create and use the resources they need
- Recovery should be quick and easy
- Improvements happen continuously. **NO** risky and expensive "Big Bang" projects
- Problems are solved through implementation, tests and monitoring

###### Tools
- Infrastructure Definition Tools
  - To provide and configure a collection of resources (e.g. OpenStack, TerraForm, CloudFormation)
- Server Configuration Tools
  - For the provision and configuration of servers or VMs (e.g. Vagrant, Packer, Docker)
- Package Management Tools
  - For the provision and distribution of preconfigured software, comparable to an AppStore. 
  - Linux: APT, YUM
  - Windows: WiX 
  - platform-neutral: SBT native packager
- Scripting Tools
  - CLI (Command-Line Interface) for step-by-step processing of commands. 
  - Linux, Mac and Windows 10: Bash
  - pure Windows: PowerShell
- Versioning & Hubs
  - For version control of the definition files and as storage of prepared images. (e.g. GitHub, Vagrant Boxes, Docker Hub, Windows VM)

##### Packer
Packer is a tool to create Images (like Boxes for Vagrant) for multiple Dynamic Infrastructure Platforms via a JSON config file.
Here's and example:
```JSON
    {
      "provisioners": [
        {
          "type": "shell",
          "execute_command": "echo 'vagrant'|sudo -S sh '{{.Path}}'",
          "override": {
            "virtualbox-iso": {
              "scripts": [
                "scripts/server/base.sh",
              ]
            }
          }
        }
      ],
      "builders": [
        {
          "type": "virtualbox-iso",
      "boot_command": [
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-preseed.cfg<wait>",
      ],
        }
      ],
      "post-processors": [
        {
          "type": "vagrant",
          "override": {
            "virtualbox": {
              "output": "ubuntu-server-amd64-virtualbox.box"
            }
          }
        }
      ]      
    }
```

###### Installation
1. [Download](https://www.packer.io/downloads/) Packer
2. Create a `packer` folder in your %USERPROFILE%
3. unzip the downloaded zip to that folder
4. add the folder to your $PATH environment variable
   1. Search for `Edit environment variables for your account`
   2. edit `Path`
   3. select `New` and type in `C:\Users\[YOUR USERNAME]\packer`
5. Test it by opening a new shell and type `packer`

##### AWS
###### Theory
- Root Account
  - Owner of the AWS Account, this user is allowed to do everything
- Regions
  - AWS has multiple server farms around the world, these are separated into regions like Ireland, Frankfurt or Virginia
- IAM (Identity and Access Management)
  - IAM is a managment system which allows the Root Account to create and manage users.
- Network and Security
  - In the AWS EC2 console you have the possibility to create and manage *Security Groups*, *Key Pairs* etc.
    - *Security Groups*: define which ports are open.
    - *Key Pairs*: are Private & Public key's which allow access to the VM's in AWS (The private key is stored by the user, the Public Key in AWS)
- AWS Images
  - Are VM Images provided by AWS out of the box, these can easily be instantiated through the EC2 console

###### AWS & Vagrant example
> I couldn't do this because I couldn't add my credit cart to my AWS account

1. Install AWS Vagrant plugin `vagrant plugin install vagrant-aws`

>> When I tried this I got an error that a `libxml2` package was missing. TO resolve this follow this [StackOverFlow article](https://stackoverflow.com/a/52613723/13419962).

2. Download a dummy VM `vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box`

1. Create a [AWS](https://aws.amazon.com/) account (don't worry its free for a while, but you need a CreditCard and Phone Nr.)
2. Go to [IAM](https://console.aws.amazon.com/iam/home)
3. Under `Users` select `Add user`
4. Under Access type select `Programmatic access`
5. Give the user `AmazonEC2FullAccess` permissions
6. Open the  `EC2` console
7. ......(I got stuck here because I couldn't add my credit cart to my AWS account)


#### Infrastructure Security

---
##### Theory
###### Firewall
A Firewall blocks or allows connections based on predefined Rules.

But there are multiple variations by what it can filter on:
- Packet filter
  - Inspects the IP Header for Source and Destination Address as well as Port.
- Stateful Packet Inspection (SPI)
  - Works on OSI Layer 3 and inspects based on Connection status.
- Application Layer Firewall (ALF)
  - Works on OSI Layer 7 (Application Layer) an can also filter based on file content.

###### Reverse Proxy
A Reverse proxy is a proxy, but the key difference is that the networks are now reversed like this:

Multiple clients of a public network can connect to a internal Service, through the reverse-proxy.

The internal IP address is now unknown to the Client and only traffic which is part of the used Protocol is forwarded to the actual service. Example:
```
User ---HTTPs--> Reverse Proxy --N--> DB Service
                             | --N--> SMB Service
                             | --Y--> Web Service
Y = Allowed
N = Not allowed
* All of these Services can run on the same OS/Machine
```

##### Practice

###### UFW 
UFW aka. `Uncomplicated Firewall` is a frontend for the very powerful, but hard to configure iptables.

1. Create a new folder called `db` adn `cd` into it
2. Create a new Vagrant database box with `vagrant init benson/mongodb`
3. add `.vm.define = "[NAME-OF-THE-VM]"` to the `config block` of your Vagrant files to differentiate between the two. Like this:

```vagrant
Vagrant.configure(2) do |config|
  config.vm.define "web"
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest:80, host:8080, auto_correct: true
  config.vm.synced_folder ".", "/var/www/html"  
config.vm.provider "virtualbox" do |vb|
  vb.memory = "512"  
end
config.vm.provision "shell", inline: <<-SHELL
  # Packages vom lokalen Server holen
  # sudo sed -i -e"1i deb {{config.server}}/apt-mirror/mirror/archive.ubuntu.com/ubuntu xenial main restricted" /etc/apt/sources.list 
  sudo apt-get update
  sudo apt-get -y install apache2 
SHELL
end
```
4. ssh into the web box `vagrant ssh web`
5. Install UFW `sudo apt-get install ufw`
6. Check the status `sudo ufw status`
7. If it isn't active, enable it with `sudo ufw enable` (you can disable it again with `sudo ufw disable`)
8. Add a sample Rule `sudo ufw allow 80/tcp` (this one allows HTTP access for everybody)
9. Now add your IP to the allowed SSH clients `sudo ufw allow from [Your-IP] to any port 22`

> Tip: you can get your IP with the `w` command

10. add the IP of your other VM on port 3306 `sudo ufw allow from [IP of Web-VM] to any port 3306`
11. Test the connection `curl -f 192.168.7.101` and `curl -f 192.168.7 .100:3306`
12. List the ufw rules numbered `sudo ufw status numbered`
13. Delete a rule `sudo ufw delete 1`
14. By default any connection to the outside is allowed, but we can change that `sudo ufw deny out to any`
15. And after add rules which overrule the "deny out to any" rule `sudo ufw allow out 22/tcp`

###### Reverse Proxy
The Apache WebServer can be used as a reverse Proxy, to do this you need to do the following steps:
1. Installation

```shell
sudo apt-get install libapache2-mod-proxy-html
sudo apt-get install libxml2-dev
```

2. Activate Modules

```shell
sudo a2enmod proxy
sudo a2enmod proxy_html
sudo a2enmod proxy_http 
```

3. Append `ServerName localhost` to `/etc/apache2/apache2.conf`
4. Restart the service `sudo service apache2 restart`
5. Configure the reverse proxy sites:

You could create file this in for example `sites-enabled/0001-reverseproxy.conf`
```conf
    ProxyRequests Off
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
    # Redirection to master
    ProxyPass /master http://master
    ProxyPassReverse /master http://master
```
###### User & rights management
####### Users
Linux and every distribution, like Ubuntu, Mint, Debian etc. is familiar with the Multi-user Concept and not every user has the same rights.

This capability is not only used to create multiple realworld user accounts, but also to segment the different services from each other. This allows that if one service is exploitable the others aren't directly affected. 

| Username | Function |
|-:|-|
| root | The super user, root can do EVERYTHING |
| nobody | `nobody` is meant to represent the user with the least permissions on the system |
| cupsys | User of the printing service CUPS |
| www-data | User of the Apache webserver |

The user file can be found in the `/etc/passwd` file and their passwords in `/etc/shadow`.

The super user doesn't have a passowrd and can't be used to login, to execute commands as root use `sudo [YOUR COMMAND]`.

Who can access this user is defined in the `/etc/sudoers` file and the `/etc/sudoers.d` directory.

######## Groups
Every user is assigned to a main group, but can also be part of other groups. If a user wants to access Services or Hardware he needs to be part of their respective group. For example if a user want' to produce sound via the soundcard he needs to be part of the `audio` group.

The groups are listed in the `/etc/group` file.

####### Home directory

Their Home directory is the place where a user has full read and write privileges, here he can store his files.
In the home directory are also the user specific setting files like `.bashrc` and `.ssh`, the config files usually start with a dot.

The home directory is always at `/home/[USERNAME]/` or for short `~/`.

In the `/etc/profile.d` folder are the settings for all users, not just the current user.

####### Filesystem
A filesystem is used to organize and structure the filed files.
Besides data organization a filesystem can do a lot more like:
 - create directories and subdirectories
 - store Metadata
 - use long filenames
 - be Case sensitive (differentiate between upper and lower case)
 - allow special characters for filenames
 - Rights management of files and folders
 - logging of every action

Unix filesystems like Linux store data in a virtual filesystem (VFS). Every file has a unique Inode, which has properties like:
- Filetype
- Access rights
- Size
- Timestamps
- Reference to file content

Access rights control, which user or groupe can read, write and or execute which files/directories. 
For example:
```shell
ls -ldh ./panter

drwxr-xr-x 1 panter panter 4.0K Jun  8 16:38 ./panter
```
The first character tells us if it's a directory `d` or a file `-`.

The access rights as separated into 3 sections:
| Section | Entity |
|-:|-|
| rwx | Rights of the owner |
| r-x | Rights of the group |
| r-x | Rights of everybody else |

The characters mean the following:
| Character | Meaning |
|:-:|-|
| r | Read (Filenames and their contents) |
| w | Write, allows for modification, deletion and creation of the specified directory and all subdirectories. |
| x | Execute, allows execution of files like bash scripts and listing of additional file attributes. |
| s | SUID-Bit, is used to specify that a file is only run by the owner. (This doesn't apply to folders) |
| S | SGID-Bit, is used to specify that a file is only run by the file group |
| t | Sticky-Bit, is used to restrict access to files and folders, so only the owner can remove or rename them. For example in `/tmp` |

The following commands can change rights:
| Command | Function |
|-:|-|
| `chmod` | Set file access |
| `chown` | Change owner |
| `chgrp` | Change group |

###### SSH
SSH originally comes from mid 1990, when computers still communicated via telephone. Getting someones password was trivial, which is why Tatu Ylönen decided to create a programme suite consisting of Server- Client- and helper programmes, he named it Secure Shell.

Later he commercialized it with ssh.com but OpenBSD forked the original version and continued to create OpenSSH.

The success came through the following major points:
- Authentication of the communication partner, no longer was it easily possible to talk to the wrong partner.
- Encryption of the messages, eavesdropping was no longer easily possible.
- Data integrity, manipulation of the messages was no longer easily possible.

Some of the most important commands are the following:

Connect to a remote system:
```shell
ssh srv001             #without specifying the user
ssh ubuntu@srv001      #with specifying the user
```
Run command on a remote system:
```shell
ssh srv001 ls -l
```
Create backup via ssh:
```shell
ssh root@srv001 "cd /etc; tar czvf - network/" | cat > etc_network_backup.tar.gz 
```
Copying files from one system to the other:
```shell
scp <FILE> <SERVER>:<FILE>  
scp <SERVER>:<FILE> <FILE>
```
Additional Commands:
- sftp  | File Transfer (encrypted)
- sshfs | Mount remote filesystem

####### Public Key procedure
If the Authentication procedure via a encrypted password still isn't enough (because someone could guess the password) then you can use the Public Key procedure. Which utilizes asynchronous encryption to authenticate the user.

The public key(s) of the user are usually stored at `~/.ssh/authorized_keys` of the destination system and the private key in a file (usually called `id_rsa` in the `~/.ssh` directory) of the local system which is protected with a user defined "Pass Phrase".

When the user want's to authenticate with a SSH server via the Public Key procedure, he sends a random challenge encrypted with the private key (for which the "Pass Phrase" is required). When the server receives the cypher and can decrypt it with the public key the authentication of the user is achieved.

######## Commands
To start with the procedure you first need to create a key pair by using a tool calles `ssh-keygen`:
```shell
vagrant ssh web
sudo su - admin

ssh-keygen -t rsa -b 4096  # this is the actual generation
```

Alternatively if the root user needs to generate the key pair use:
```shell
su - admin -c "mkdir .ssh && chmod 700 .ssh && ssh-keygen -t rsa -f .ssh/id_rsa -b 4096 -C admin@company.local -P ''"
```

Now the the key (with the ending `.pub`) has to be trancfered to the target system. For this we use a tool called `ssh-copy-id` (at this point Authentication via password still has to be enables `PasswordAuthentication yes`)
```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub admin@db 
```

If `ssh-copy-id` doesn't work you can copy the key any otherway to the target system. For example:
```shell
cat id_rsa.pub | ssh db 'cat>> ~/.ssh/authorized_keys' 
```

After that you can authenticate without a password:
```shell
ssh admin@db 
```

####### SSH Tunnel
In a network tunneling means converting and transmitting of a communication protocol, which is transported embedded in another protocol.

Before and after the the Tunnelpartner the original protocol is spoken but between the Tunnelpartners the other protocol is spoken.

For this a Tunneling Software on both sides is necessary, which packages the information and unpacks it on the other side and hands it over.

**The communication in the tunnel has to be encrypted!**

######## Commands
Forwarding Port 8000 of local host (database/db) to the Webserver (192.168.7.101:80)
```shell
cd user
vagrant ssh database
sudo su - admin

ssh -L 8000:localhost:80 web -N &
netstat -tulpen
curl http://localhost:8000
```

Reversed, User on web/web can access the MySQL-Server on database/db via localhost:3307
```shell
vagrant ssh db
ssh -R 3307:localhost:3306 web -N &
ssh web

netstat -tulpen
curl http://localhost:3307
```
> The db server needs have the private key and the web server needs the public key. In addition ssh from `db` to `web` has to be done in advance, once.

###### Authentication and Authorization
**Authentication**

Authentication is the proof (verification) of a claimed property of an entity, which can be, for example, a person, a device, a document or information and which thereby carries out its authentication.

The associated verb is authenticate, which stands for proofing the authenticity of something. 
In IT, the substantiated word authentication is often used both for the authorization checking process and for the result of this check. 
In the German-speaking world, the term authentication is used to test authenticity and the term authentication to testify authenticity.

The authentication of an entity with respect to the claimed property of authenticity, which can be, for example, granting an "existing access authorization" or "authenticity", allows the authenticated entity further actions. The entity is then considered authentic.

The confirmation concluding an authentication is also referred to as authorization if it is restricted by certain permissible modes and / or in a certain context.

**Authorization**

Authorization is, in the broadest sense, consent, more specifically the granting of rights to interested parties, possibly for use by third parties. The authorization overcomes mechanisms of security against unauthorized persons. Authorization does not remove protection. Authorization may only apply to a limited extent in one context and / or mode. Authorization does not make sense without prior successful authentication.

In IT, authorization refers to the initial assignment and the repeated preliminary checking of access rights using special methods with regard to interested system users for data and services.

The two most common special cases are:

- Permitted access to so-called resources (e.g. directories or files) in a computer network
- Permission to install or use computer programs (software)

####### Secure Apache
HTTPS (Hypertext Transfer Protocol Secure) is a communication protocol for the internet, to transfer data without someone eavesdropping. It is a additional layer between HTTP and TCP.

The current version of Apache is already prepared for HTTPS, we just need to enable it:
```shell
# Activate default configuration in /etc/apache2/sites-available
sudo a2ensite default-ssl.conf

# Activate SSL module in Apache2
sudo a2enmod ssl

# Optional, deactivate HTTP
sudo a2dissite 000-default.conf 

# Edit /etc/apache2/ports.conf and comment out line 80
sudo nano /etc/apache2/ports.conf

# Restart Apache server
sudo service apache2 restart
```

To enable Username/Password authentication we have to:
```shell
# generate a .htpasswd file for a second user
sudo htpasswd -c /etc/apache2/.htpasswd guest

# edit /etc/apache2/sites-enabled/default-ssl.conf and past the following in front of </VirtualHost>
<Directory "/var/www/html">
        AuthType Basic
        AuthName "Restricted Content"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
</Directory>
```

####### LDAP
LDAP is based on the Client-Server-Model and is a Directory Service.
It defines the communication between the client and directory server.
From this directory service we can get object-related data, for example user data or configuration files. This communication is based on requests.

The directory could for example store a Address book of the employees.
A user could use his/her E-Mail client to search for `Frank H` and the E-Mail client would formulates a LDAP query to the directory, which stores the address information. Then the directory Service formulates a response and sends it to the client `frank.hofmann@company.com`.

In the meantime, it has become commonplace in administrative language to speak of an LDAP server. This means a directory server whose data structure corresponds to the LDAP specification and which can exchange data using the LDAPv3 protocol.

**Example**

In the ldap directory there is a vagrant file which installs OpenLDAP with UI (http://localhost:8081/phpldapadmin) on the master VM.

Login via:
- Login DN: cn=admin,dc=nodomain
- Password: admin

After that we can add LDIF formatted entries like:

Posix-Group
```yaml
dn: cn=apache2,dc=nodomain
cn: apache2
gidnumber: 500
objectclass: posixGroup
objectclass: top
```
Posix-Account
```yaml
dn: cn=Muster,cn=apache2,dc=nodomain
cn:  Muster
gidnumber: 500
homedirectory: /home/users/Muster
loginshell: /bin/sh
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
sn: Muster
uid: muster
uidnumber: 1000
userpassword: {MD5}9WGq9u8L8U1CCLtGpMyzrQ==
```

After that the Apache Server has to be configured to get username/password from the LDAP Server.
For that we need to extend the `/etc/apache2/apache2.conf` file:
```xml
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    #Require all granted
    Order deny,allow
    Deny from All
    AuthName "Company.com Intranet"
    AuthType Basic
    AuthBasicProvider ldap
    #AuthzLDAPAuthoritative off
    AuthLDAPUrl ldap://localhost/dc=nodomain?uid
    Require valid-user
    Satisfy any
</Directory>
```
After we restart the apache Server `service apache2 restart` we can see a login at http://localhost:8081 where we can login with username `muster` and password `xxx`

######## Commands
Get Server info:
```shell
slapcat
```
Get all entires in LDAP Server:
```shell
ldapsearch -x -LLL -H ldap:/// -b dc=nodomain dn
```

####### Identity management
Identity management (IdM) refers to the targeted and conscious handling of identity, anonymity and pseudo-anonymity. The ID card is an example of a form of identification prescribed by the state.

Through the Internet, the question of conscious anonymity or conscious handling of parts of one's own identity has reached a new level of complexity never seen before.

The internet regularly plays with (partial) identities. But there are also serious processes and questions of anonymity and identifiability on the Internet. In many ways, identity management systems can be problematic if it is not clear what happens to the data, which can lead to further unwanted identification.

There are various forms of identity management in both the real and the digital world. According to ISO / IEC JTC 1 / SC 27 / WG 5 "A framework for IdM" IdM includes:

- The identification process of a unit (including optional authentication)
- The information associated with the identification of an entity within a particular context
- Secure identity management

**But why Identity management?**

One of the reasons why companies deal with identity management is the requirement to keep personal data consistent, constantly available and reliably. Services such as a mail system or personnel accounting are dependent on this data. Without it, no individualized operation would be possible.

*Example*

An employee has a mail account that is only assigned to him. For this he needs an individual email address, a so-called account with the associated password. This data is only intended for him and not for the general public.

*Counterexample*

A company presentation is uniform for all employees and does not require individualization.

**Identity management of companies**

The larger a company is, the more identities and authorizations need to be managed. So-called identity management architectures are used for this. These are software components that manage the identities and their access rights.

The term identity management in the software environment does not include a precisely defined range of functions. For example, simple systems focus exclusively on the synchronization of personal data, while more comprehensive architectures, include workflow processes that contain a hierarchical approval model to implement data changes.

An identity management architecture should have a provisioning module that allows users to be automatically granted individual authorizations based on their respective roles (and tasks) in the organization. However, the question already arises as to how far identity management should integrate application functionalities beyond the exclusive management of personal data (e.g. the "quota" on a mail server is not a personal data, but application information).

Identity management in a company often has interfaces to the so-called access management system, which fro example manages access rights for portals, enables single sign-on (SSO) or manages security policies. For the combination of identity management and access management, the term "Identity and Access Management" (IAM or IdAM) has been coined in IT.

### Reflection
#### General
I was already familiar with Git, GitHub, VSCode, Python 3 and somewhat with Linux.

But before this project I hadn't even heard of Vagrant, so everything was new to me.
At first this was quite overwhelming, but after a couple of sessions I got the hang of if quite quickly.
I started to use `vagrant reload xxxx` instead of destroying and creating a new VM for every change my self and wrote down the command I had used inside the vagrant VM, so I could trace back what I did and put the commands into my Vagrantfile.
I also learned how to use Python as a backend (something which I have always wanted to do!) and how to setup a Reverse Proxy. I made the mistake of first going through all of the Theory and doing+writing down everything I did, instead of going through the Theory during the project, as a "side-task".


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
- [ ] User and Rights distribution is setup
- [X] Access via SSH tunnel is secured
- [X] Security measures are documented
- [x] Project documented with MarkDown
### K5 | Misc criteria
- [X] Creativity
- [X] Complexity
- [ ] Scope
- [ ] Cloud-Integration
- [ ] AuthO & AuthN via LDAP
- [x] Contribute to the original Documentation
  - Extend the Firewall & Proxy theory with my documentation?
  - Autocorrect error? (Applikations-Funktionalitäten integrieren soll (z.B. ist die "Quota" auf einem Mailserver keine `personenbezogenes Datum`, sondern eine Applikations-Information).)
- [X] Comparison prior vs increased knowledge
- [X] Reflection