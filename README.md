# M300
Cross-platform services in a network
======
## Setup
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
1. Download Vagrant (https://www.vagrantup.com/downloads.html)
2. 