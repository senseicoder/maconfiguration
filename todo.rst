TODO
####

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
