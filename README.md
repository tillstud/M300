# M300 aka. Cross-platform services in a network

In this Document you can read the steps I did when going through the theoretical part of the different Workteams in [Modul 300](https://github.com/mc-b/M300).

My Learning Assessments:
- [LB2](./LB2/README.md)
- [LB3](./LB3/README.md)

---

Table of Contents
- [M300 aka. Cross-platform services in a network](#m300-aka-cross-platform-services-in-a-network)
  - [## 10 | Tools](#h2-id10--tools-86710--toolsh2)
    - [markdown](#markdown)
    - [Git](#git)
    - [VM](#vm)
      - [Create the VM](#create-the-vm)
      - [Setup the VM](#setup-the-vm)
    - [Vagrant](#vagrant)
      - [Create basic Vagrant VM](#create-basic-vagrant-vm)
      - [Create Vagrant VM from file](#create-vagrant-vm-from-file)
    - [VS Code](#vs-code)
  - [## 20 | Infrastructure automation](#h2-id20--infrastructure-automation-86720--infrastructure-automationh2)
    - [Theory (Infrastructure as Code)](#theory-infrastructure-as-code)
      - [Goals](#goals)
      - [Tools](#tools)
    - [Packer](#packer)
      - [Installation](#installation)
    - [AWS](#aws)
      - [Theory](#theory)
      - [AWS & Vagrant example](#aws--vagrant-example)
  - [## 25 | Infrastructure Security](#h2-id25--infrastructure-security-86725--infrastructure-securityh2)
    - [Theory](#theory-1)
      - [Firewall](#firewall)
      - [Reverse Proxy](#reverse-proxy)
    - [Practice](#practice)
      - [UFW](#ufw)
      - [Reverse Proxy](#reverse-proxy-1)
      - [User & rights management](#user--rights-management)
        - [Users](#users)
          - [Groups](#groups)
        - [Home directory](#home-directory)
  - [## 30 | Container](#h2-id30--container-86730--containerh2)
  - [## 35 | Container Security](#h2-id35--container-security-86735--container-securityh2)
  - [## 40 | Kubernetes](#h2-id40--kubernetes-86740--kubernetesh2)
  - [## 80 | Misc](#h2-id80--misc-86780--misch2)

## 10 | Tools
---
### markdown

Guide for Markdown: https://gist.github.com/jonschlinkert/5854601

### Git
1. create a Repo on GitHub
2. `git clone` of the repo

Because I want to use a private email for my commits I need to change my 
local git config:

3. `git config --global user.email "{id}+{username}@users.noreply.github.com"`
4. `git config user.email "{id}+{username}@users.noreply.github.com"`
5. `git commit --amend --reset-author`
6. `git push`

Guide for git: https://rogerdudler.github.io/git-guide/

### VM
> This Step is NOT necessary, if you already know how to create a VM skip to the section "Vagrant" 
#### Create the VM

1. Download the newest Ubuntu Long-Term-Support ISO (https://ubuntu.com/#download)
2. Create VM with the following settings, leave anything else default:
   - Use: `ubuntu-20.04-desktop-amd64.iso`
   - Name: `M300_Ubuntu_20.04_Desktop`
   - Storage: `40GB`
   - RAM: `2048MB`
3. Power-On the VM


#### Setup the VM
1. Enter your credentials and login
2. Under "Region & Language" change the keyboard layout
3. Install the updates & upgrades: `sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade`
4. Reboot: `sudo reboot`
5. Create a snapshot
6. Install the Synaptic Package Manager: `sudo apt-get install synaptic`
7. Reboot: `sudo reboot`
8. Start `Synaptic Package Manager`
9. Search for `apache2` and select it for installation
10. Click on `Apply`
11. Check if apache works, by opening `http://127.0.0.01:80` in your browser.
    It works if you see the Apache2 Default Page.
12. Create a snapshot

### Vagrant
[Docs](https://www.vagrantup.com/docs/cli/)
[Boxes](https://app.vagrantup.com/boxes/search)
#### Create basic Vagrant VM
1. [Download](https://www.vagrantup.com/downloads.html) & Install Vagrant
2. Create a new folder for your VM:

```shell
cd c:/where/you/store/your/vms
mkdir myVagrantVM
cd myVagrantVM
```

3. Create a new Vagrant VM:

```shell
vagrant init ubuntu/xenial64
vagrant up --provider virtualbox 
```

4. SSH into the VM, where you can execute any Linux command as you usually would:

```shell
cd ./myVagrantVM
vagrant ssh
```

5. Open the VM via the VirtualBox GUI (username=`vagrant` password=`vagrant`)

#### Create Vagrant VM from file
1. Download my vagrant file (./assets/vagrant/web/Vagrantfile)
2. `cd` to that file
3. Start it up: `vagrant up`
4. Test if you can access `http://127.0.0.01:80` in your browser
5. Test if you can change the `index.html` file which was created in the folder where the Vagrantfile lies.
6. Destroy the VM `vagrant destroy -f`

### VS Code
1. If you don't have Visual Studio Code already, [download](https://code.visualstudio.com/) & install it
2. Recommended Extensions are:
   - Markdown All in One (Yu Zhang)
   - Vagrant (Marco Stanzi)
   - vscode-pdf (tomiko1207)
3. Open the Settings (`Ctrl` + `,`) and modify the global settigns to exclude .git / .svn / .hg / .vagrant / .DS_store files

```
 // Exclude .git / .svn / .hg / .vagrant / .DS_store files
 "files.exclude": {
   "**/.git": true,
   "**/.svn": true,
   "**/.hg": true,
   "**/.vagrant": true,
   "**/.DS_Store": true
 },
```

1. Save and exit
> Tipp: You can open a VScode terminal by grabbing the edge of the bottom most row and drag upwards.
> Here you can use any commands you usually would in a Powershell/CMD windows (like git commands)

## 20 | Infrastructure automation
---
### Theory (Infrastructure as Code)
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

#### Goals
- IT Infrastructure supports and allows change
- Change is routine and doesn't cause any headache
- Repeating tasks should be automated
- Business users create and use the resources they need
- Recovery should be quick and easy
- Improvements happen continuously. **NO** risky and expensive "Big Bang" projects
- Problems are solved through implementation, tests and monitoring

#### Tools
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

### Packer
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

#### Installation
1. [Download](https://www.packer.io/downloads/) Packer
2. Create a `packer` folder in your %USERPROFILE%
3. unzip the downloaded zip to that folder
4. add the folder to your $PATH environment variable
   1. Search for `Edit environment variables for your account`
   2. edit `Path`
   3. select `New` and type in `C:\Users\[YOUR USERNAME]\packer`
5. Test it by opening a new shell and type `packer`

### AWS
#### Theory
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

#### AWS & Vagrant example
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


## 25 | Infrastructure Security
---
### Theory
#### Firewall
A Firewall blocks or allows connections based on predefined Rules.

But there are multiple variations by what it can filter on:
- Packet filter
  - Inspects the IP Header for Source and Destination Address as well as Port.
- Stateful Packet Inspection (SPI)
  - Works on OSI Layer 3 and inspects based on Connection status.
- Application Layer Firewall (ALF)
  - Works on OSI Layer 7 (Application Layer) an can also filter based on file content.

#### Reverse Proxy
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

### Practice

#### UFW 
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

#### Reverse Proxy
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
#### User & rights management
##### Users
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

###### Groups
Every user is assigned to a main group, but can also be part of other groups. If a user wants to access Services or Hardware he needs to be part of their respective group. For example if a user want' to produce sound via the soundcard he needs to be part of the `audio` group.

The groups are listed in the `/etc/group` file.

##### Home directory



## 30 | Container
---


## 35 | Container Security
---


## 40 | Kubernetes
---


## 80 | Misc
---
