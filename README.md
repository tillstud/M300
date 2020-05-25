# M300
Cross-platform services in a network
=======================================================

In this Document you can read my steps I did when going through the theoretical part of the different Workteams in [Modul 300](https://github.com/mc-b/M300).

My Learning Assessments:
- [LB2](./LB2/README.md)
- [LB3](./LB3/README.md)

=======================================================

Table of Contents
- [M300](#m300)
- [Cross-platform services in a network](#cross-platform-services-in-a-network)
  - [10 | Tools](#10--tools)
    - [Git](#git)
    - [VM](#vm)
      - [Create the VM](#create-the-vm)
      - [Setup the VM](#setup-the-vm)
    - [Vagrant](#vagrant)
      - [Create basic Vagrant VM](#create-basic-vagrant-vm)
      - [Create Vagrant VM from file](#create-vagrant-vm-from-file)
    - [VS Code](#vs-code)
  - [20 | Infrastructure automation](#20--infrastructure-automation)
    - [Theory (Infrastructure as Code)](#theory-infrastructure-as-code)
      - [Goals](#goals)
      - [Tools](#tools)
    - [Packer](#packer)
      - [Installation](#installation)
    - [AWS](#aws)
      - [Theory](#theory)
      - [AWS & Vagrant example](#aws--vagrant-example)
  - [25 | Infrastructure Security](#25--infrastructure-security)
  - [30 | Container](#30--container)
  - [35 | Container Security](#35--container-security)
  - [40 | Kubernetes](#40--kubernetes)
  - [80 | Misc](#80--misc)

=======================================================

## 10 | Tools
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

```
cd c:/where/you/store/your/vms
mkdir myVagrantVM
cd myVagrantVM
```

3. Create a new Vagrant VM:

```
vagrant init ubuntu/xenial64
vagrant up --provider virtualbox 
```

4. SSH into the VM, where you can execute any Linux command as you usually would:

```
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

4. Save and exit
> Tipp: You can open a VScode terminal by grabbing the edge of the bottom most row and drag upwards.
> Here you can use any commands you usually would in a Powershell/CMD windows (like git commands)

## 20 | Infrastructure automation
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
1. Install AWS Vagrant plugin `vagrant plugin install vagrant-aws`

> When I tried this I got an error that a `libxml2` package was missing. TO resolve this follow this [StackOverFlow article](https://stackoverflow.com/a/52613723/13419962).

2. Download a dummy VM `vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box`

1. Create a [AWS](https://aws.amazon.com/) account (don't worry its free for a while, but you need a CreditCard and Phone Nr.)
2. Go to [IAM](https://console.aws.amazon.com/iam/home)
3. Under `Users` select `Add user`
4. Under Access type select `Programmatic access`
5. Give the user `AmazonEC2FullAccess` permissions
6. Open the  `EC2` console
7. ......................


## 25 | Infrastructure Security


## 30 | Container


## 35 | Container Security


## 40 | Kubernetes


## 80 | Misc
