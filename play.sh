#!/bin/bash

inventory=hosts
playbook=run.yml

if [ "$1" == "help" ]; then
	ansible-playbook -vvvv -i $inventory --list-hosts $playbook
	ansible-playbook -i $inventory --list-tags $playbook
else
	ansible-playbook -i $inventory --ask-become-pass $playbook $@
fi
