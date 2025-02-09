#!/bin/sh

# Load the configuration from /etc/config/redsocks
. /lib/functions.sh
config_load "redsocks"

# Initialize variables from the configuration file
config_get enabled main enabled
config_get host main host
config_get port main port
config_get authentication main authentication
config_get username main username
config_get password main password

# Path to the redsocks configuration file
REDSOCKS_CONF="/etc/redsocks.conf"

# Create or clear the existing redsocks.conf
echo "" > $REDSOCKS_CONF

# Base configuration
cat <<EOL >> $REDSOCKS_CONF
base {
        log_debug = off;
        log_info = on;
        log = "syslog:local7";
        daemon = on;
        redirector = iptables;
}

EOL

# Redsocks configuration
cat <<EOL >> $REDSOCKS_CONF
redsocks {
        local_ip = 0.0.0.0;
        local_port = 1337;
        ip = $host;
        port = $port;
        type = socks5;
EOL

# If authentication is enabled, add username and password
if [ "$authentication" -eq 1 ]; then
    echo "        login = \"$username\";" >> $REDSOCKS_CONF
    echo "        password = \"$password\";" >> $REDSOCKS_CONF
fi

# Close the redsocks configuration block
echo "}" >> $REDSOCKS_CONF
