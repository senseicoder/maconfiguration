# maconfiguration
configuration for my Ubuntu workstations

The goal is to deploy all useful packages and configuration files to help me to work ASAP with a new workstation (Linux Ubuntu, may work with Debian)

## todo

* conf awscli
* `~/bin` est gere par le role `bin-init` depuis le depot SVN `ScriptsBash`.
* mytop plus trouvé
* etckeeper remplace le controle historique de /etc par Mercurial
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
