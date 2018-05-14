# maconfiguration
configuration for my Ubuntu workstations

The goal is to deploy all useful packages and configuration files to help me to work ASAP with a new workstation (Linux Ubuntu, may work with Debian)

## Contraintes particulières

* Ubuntu 18.04 : sudo apt install python

## Installation depuis un second poste avec accès SSH

* new=$ip/$hostname
* ssh-copy-id $new
* ansible-playbook -i "$new," run.yml --ask-become-pass

## Installation directe sur le nouveau poste

## Tronc commun
