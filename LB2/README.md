# LB1
- [LB1](#lb1)
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
  - [Grading criteria](#grading-criteria)
    - [K1 | Tool environment](#k1--tool-environment)
    - [K2 | Learning environment](#k2--learning-environment)
    - [K3 | Vagrant](#k3--vagrant)
    - [K4 | Security](#k4--security)
    - [K5 | Misc criteria](#k5--misc-criteria)

---
---

## Documentation
https://github.com/mc-b/M300/tree/master/vagrant/fwrp

### Idea
Create multiple machines and connect them together to create a Web portal where only members can write text, but that text is visible in read only mode to anybody visiting the Webpage.

For this I needed:
- Web service
- Database
- User and Rights distribution

### Overview
![A WebServer, ](/LB2/assets/architecture_diagram.xml)
- some visualization
- short description
### Test cases
- just a couple of cases
### Security
#### Firewall
#### Reverse-Proxy
#### User and Rights distribution
- LDAP
#### Access via SSH tunnel
### Reflection
- general mood reflection
- comparison prior vs increased knowledge


---
---

## Grading criteria
### K1 | Tool environment
- [x] VirtualBox
- [x] Vagrant
- [x] VS Code
- [x] Git Client
- [x] SSH Key for Client
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
- [] Setup VM from Vagrant Cloud
- [] Knows the Vagrant Commands
- [] Setup is documented
  - [] Environment Variables
  - [] Network diagram
  - [] Security aspects
- [] Functionality tested with Test cases
- [] second prebuilt VM from Vagrant setup
- [x] Project documented with MarkDown
### K4 | Security
- [] Firewall with Rules is setup
- [] Reverse-Proxy is setup
- [] User and Rights distribution is setup
- [] Access via SSH tunnel is secured
- [] Security measures are documented
- [x] Project documented with MarkDown
### K5 | Misc criteria
- [] Creativity
- [] Complexity
- [] Scope
- [] Cloud-Integration
- [] AuthO & AuthN via LDAP
- [x] Contribute to the original Documentation
  - Extend the Firewall & Proxy theory with my documentation?
  - Autocorrect error? (Applikations-Funktionalitäten integrieren soll (z.B. ist die "Quota" auf einem Mailserver keine `personenbezogenes Datum`, sondern eine Applikations-Information).)
- [] Comparison prior vs increased knowledge
- [] Reflection