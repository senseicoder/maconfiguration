TODO
####

* urgent

  * syncthing démarre pas tout seul
  * installer des extensions GnomeShell depuis le site https://extensions.gnome.org

    * https://extensions.gnome.org/extension/906/sound-output-device-chooser/

  * guake, correction bug : https://github.com/Guake/guake/issues/551
  * ~/bin/public dans le path et exécutable
  * awscli
  * guake en autorun à tester
  * modules subl à installer
  * conf ansible (no retry notamment, et log)
  * d'abord créer la clef ssh, et si elle a été créée, l'afficher (publique) en précisant qu'il faut la saisir dans github avant de déployer les repos (bon, ça marche si on déploie depuis un autre poste déjà configuré, mais faut que ça marche sans aussi)
  * ~None à supprimer
  * /home/nas et /home/epiconcept (mais seulement pour les postes à la maison, introduire cette idée)
  * DNS 1.1.1.1 ? 
  * dropbox
  * ansible-deploy.sublime-workspace, conf SVN à gérer
  * ssmtp

* doc 

  * se connecter en "ubuntu via xorg", wayland n'est pas encore tout à fait stable
  * récupérer trousseau.kdb
  * firefox, auth compte central (confirmation par email)
  * connexion compte google, double facteur via le portable
  * pushbullet, connexion via compte google

* todo

  * https://www.tecmint.com/progress-monitor-check-progress-of-linux-commands/
  * https://www.in-nomine.org/2017/04/19/setting-up-sublimetext-3-for-ansible/
  * apt light-locker
  * rescuetime, installer l'application et activer l'extension ff ensuite
  * cd ~/bin && composer up
  * export des /etc en mercurial
  * update-apt-xapian-index à virer
  * apt install mediainfo
  * go https://tecadmin.net/install-go-on-ubuntu/
  * apt shellcheck
  * install rlwrap pour prj
  * affichage formats raw : https://doc.ubuntu-fr.org/raw
  * ajout ~/bin/myscripts sur mes postes, et le mettre dans le PATH
  * Csync lance Maj maconfiguration
  * Export CDPATH=
  * Pas de /home en dur
  * Docker de test, voir la 15.10
  * Installer certains trucs que sur certains machines
  * Séparer dev du reste 
  * Appel qui joue tout
  * Shell sur oxalide, Sophie,,, 
  * Supershell sur faranth, conf m5
  * Conf thunderbird et ff
  * Conf yakuake
  * Clefs ssh
  * Partagés Syncthing
  * Pidgin 
  * Conf de chacun 
  * Sleepyhead, liens libs m5, historique apt, revoir script original ansible
  * Tester sur un vieux portable

* qarte::

	sudo add-apt-repository ppa:vincent-vandevyvre/vvv
	sudo apt-get update
	sudo apt-get install qarte

* virer aptitude search apt-xapian-index : apt purge apt-xapian-index
* ~/bin/public sur https://github.com/senseicoder/myscripts.git
* conf git .gitconfig::

	[user]
	        name = Cédric Girard
	        email = cedric@daneel.net
	[push]
	        default = simple
	[credential]
	        helper = cache --timeout=360000

* http://repo2.charenton.tld/hg/patterns/4cgd/file/b510df81b072/apt-loop.yml::
	
	---
	
	- hosts: localhost
	  gather_facts: False
	  tasks:
	    - set_facts:
	        help: |
	          ansible-playbook apt-loop.yml --ask-become-pass -b
	    - name: install some tools
	      with_items: [ aptitude, pwgen, sshfs, colordiff, iotop, htop, mytop, sharutils, subversion ]
	      apt:
	        name: '{{ item }}'
	        update_cache: True
	        cache_valid_time: 300œ


- name: vieux gnome?
  apt: name=gnome-session-flashback state=present

Après
=====

* keepass2 en cli pour remplacer l'actuel kp
