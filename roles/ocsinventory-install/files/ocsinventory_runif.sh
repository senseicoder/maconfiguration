#!/bin/bash
#doit être lancé en root

curl -s http://$(grep ^server /etc/ocsinventory/ocsinventory-agent.cfg | sed -e 's/.*=//') > /dev/null
if [ $? -eq 0 ]; then
	ocsinventory-agent
fi
