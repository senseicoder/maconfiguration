#!/bin/bash
#pour tout ce qui est nécessaire à faire tourner les scripts

sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install ansible -y

