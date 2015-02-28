#/bin/bash

source .harmony.config

PYTHONPATH=. python harmony --email $HARMONY_EMAIL --password $HARMONY_PASSWORD --harmony_ip  $HARMONY_IP --harmony_port 5222 --loglevel INFO show_config

