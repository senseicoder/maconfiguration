# maconfiguration
configuration for my Ubuntu workstations

The goal is to deploy all useful packages and configuration files to help me to work ASAP with a new workstation (Linux Ubuntu, may work with Debian)

## todo

* conf awscli
* svn co svn+ssh://cedricg@resin.csoft.net/home/cedricg/cedric/outilsDev/ScriptsBash /home/cedric/bin doit être fait à la main avant, l'automatique ne marche pas (auth par clef ne marche pas?)
* mytop plus trouvé
* passer à etckeeper
* basculer l'envoi mail local de `ssmtp` vers `msmtp`/`msmtp-mta` pour remplacer le MTA `sendmail` et corriger les erreurs SMTP des cron
* intégrer la configuration mail csoft avec expéditeur forcé `cedricg@cedricg.csoft.net` (`ssmtp.conf`/`revaliases`, puis équivalent `msmtp`) après validation avec csoft

## Contraintes particulières

* Ubuntu 18.04 : sudo apt install python

## Installation depuis un second poste avec accès SSH

* new=$ip/$hostname
* ssh-copy-id $new
* ansible-playbook -i "$new," run.yml --ask-become-pass

## Installation directe sur le nouveau poste

## Tronc commun
