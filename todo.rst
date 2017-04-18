TODO
####

* todo

  * go https://tecadmin.net/install-go-on-ubuntu/
  * apt shellcheck
  * https://doc.ubuntu-fr.org/wakeonlan
  * ~/Sync/infra-notes.wiki
  * alias::

	alias antidote='/opt/Druide/Antidote8/Programmes64/Antidote8'
	
	alias kpec="kp -d ~/Sync/Central/trousseau.kdb getpwd 'Keepass enqu' | kp -d /home/epiconcept/globe/Technique/divers/epi/EnqVOO2.kdb.kdb --stdin"
	alias kpadm="kp -d ~/Sync/Central/trousseau.kdb getpwd 'Keepass Admin' | kp -d /home/epiconcept/globe/Technique/divers/epi/Admin.kdb --stdin"
	
	alias presspap="xclip -selection clipboard"

  * xclip
  * install rlwrap pour prj
  * affichage formats raw : https://doc.ubuntu-fr.org/raw
  * ajout ~/bin/myscripts sur mes postes, et le mettre dans le PATH
  * Csync lance Maj maconfiguration
  * Export CDPATH=
  * Kpcli from mon fork
  * Pas de /home en dur
  * Docker de test, voir la 15.10
  * Installer certains trucs que sur certains machines
  * Séparer dev du reste 
  * Appel qui joue tout
  * Shell sur oxalide, Sophie,,, 
  * Les SVN à deployer
  * Supershell sur faranth, conf m5
  * Conf thunderbird et ff
  * Conf yakuake
  * Clefs ssh
  * SVN, git... 
  * Partagés Syncthing
  * Pidgin 
  * Conf de chacun 
  * Sleepyhead, liens libs m5, historique apt, revoir script original ansible
  * Tester sur un vieux portable

* qarte::

	sudo add-apt-repository ppa:vincent-vandevyvre/vvv
	sudo apt-get update
	sudo apt-get install qarte

* virer aptitude search apt-xapian-index
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
