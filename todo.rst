TODO
####

* todo

  * droits sur les shells de ~/bin et ~/bin/public (via csync ?)
  * conf ansible (no retry notamment)
  * d'abord créer la clef ssh, et si elle a été créée, l'afficher (publique) en précisant qu'il faut la saisir dans github avant de déployer les repos (bon, ça marche si on déploie depuis un autre poste déjà configuré, mais faut que ça marche sans aussi)
  * ansible
  * apt keepassx light-locker
  * non duplication dans kwown_hosts
  * se connecter en "ubuntu via xorg", wayland n'est pas encore tout à fait stable
  * récupérer trousseau.kdb
  * firefox, auth compte central (confirmation par email)
  * rescuetime, installer l'application et activer l'extension ff ensuite
  * connexion compte google, double facteur via le portable
  * pushbullet, connexion via compte google
  * svn ls https://svn.epiconcept.fr/outils_internes #pour l'auth
  * svn ls https://svn.epiconcept.fr/LIB_PARTAGEE
  * passer au nouveau format keepass ou installer vieux keepassx ? compat client anddroid?
  * auth SVN sur divers dossiers svn Epiconcept dont dépend ~/www
  * tâches changed à chaque tour::

	TASK [auth-init : clef serveur CSoft] ****************************************************************************************************************
	changed: [192.168.1.233] => (item=|1|a5H/JMcejN/5u0GbU9XIDhCxLjg=|NhSK2kIEKQB+/67T5cMHnWscGW4= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAx6joxZShbTzYijkjnJEDtutf7jx3gkP6soNW5R+yRAnyby0ZMMnODZl5lsr//FFZ+WhrLRzAor3LmV4pi2nBaXSbyHb/KxMuGGFBYe6484NuvsD/CiHS92V1zJAaLaq0Qgz0jfigPg/QV5g0sthERWl8a72u+hkY2v8K97w+X3M=
	|1|o865NcsYG1SJD0DL5pCl5O7hyVQ=|/AflhBiZzeoNJuIF7VpvSl5y9Gg= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFDT00K1beztD/NR5dxtRx/JYCRckRenEADs95Abfamxhc+czUS2qqeWsfig5V2Rl+JwPy4YyaT+niFawYNNFus=                                                                               
	|1|HHwtwGKhmDYyMpEZ/Na3xIvnpJc=|zhQCC9b1FtwhVFoWPSXIQRGqtYo= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFDT00K1beztD/NR5dxtRx/JYCRckRenEADs95Abfamxhc+czUS2qqeWsfig5V2Rl+JwPy4YyaT+niFawYNNFus=)                                                                              

	TASK [git-install : clef serveur Github] *************************************************************************************************************
	changed: [192.168.1.233] => (item=|1|SpOrlIU+xLEE0AMLX7krhGoc5/A=|BHPayCIH8dByRQFl7kmIgO+O5vo= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
	|1|XxLZLb13mFFIKObXG9kyO+iVEgA=|ouipOIumEBiVv9kvdYGrtHbLAfM= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==)

  * https://www.sublimetext.com/docs/3/linux_repositories.html#apt 
  * cd ~/bin && composer up
  * export des /etc en mercurial
  * update-apt-xapian-index à virer
  * vim, tree
  * apt install mediainfo
  * keepassx2 sous ubuntu 14.04::

	sudo apt-get install build-essential cmake qtbase5-dev libqt5x11extras5-dev qttools5-dev qttools5-dev-tools libgcrypt20-dev zlib1g-dev libxi-dev libxtst-dev
	git clone https://github.com/keepassx/keepassx.git
	cd keepassx/
	mkdir build
	cd build
	cmake ..
	make -j4
	src/keepassx (copier pour avancer)

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
