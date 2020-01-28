#!/bin/bash
#doit être lancé en root

curl -s http://$(grep ^server /etc/ocsinventory/ocsinventory-agent.cfg | sed -e 's/.*=//') > /dev/null
if [ $? -eq 0 ]; then
	ocsinventory-agent 2>&1 | grep -v '^\[info\]' | mail -Es "$(hostname) ocsinventory-agent" -a "From: cedric@daneel.net" c.girard@epiconcept.fr
fi
