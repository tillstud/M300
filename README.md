# M300 aka. Cross-platform services in a network

In this document you can read the steps I did when going through the theoretical part of the different Workteams in [Modul 300](https://github.com/mc-b/M300).

My Learning Assessments:
- [LB2](./LB2/)
- [LB3](./LB3/)

---

Table of Contents
- [M300 aka. Cross-platform services in a network](#m300-aka-cross-platform-services-in-a-network)
  - [Tools](#tools)
    - [markdown](#markdown)
    - [Git](#git)
    - [VM](#vm)
      - [Create the VM](#create-the-vm)
      - [Setup the VM](#setup-the-vm)
    - [Vagrant](#vagrant)
      - [Create basic Vagrant VM](#create-basic-vagrant-vm)
      - [Create Vagrant VM from file](#create-vagrant-vm-from-file)
    - [VS Code](#vs-code)

## Tools

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
