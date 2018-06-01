#!/bin/bash
#pour tout ce qui est nécessaire à faire tourner les scripts

sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install ansible subversion -y
cpan #pour le configurer la première fois, prendre sudo et choose mirror

for i in https://svn.epiconcept.fr/LIB_PARTAGEE https://svn.epiconcept.fr/outils_internes; do 
	svn ls --username=cedric $i >/dev/null
done

sshagent routes direct