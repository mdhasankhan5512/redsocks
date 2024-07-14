cd /tmp
opkg update
sleep 2
opkg install redsocks iptables-nft iptables-mod-nat-extra
sleep 2
rm /etc/init.d/redsocks
rm /etc/redsocks.conf
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/main/exlcudeytpsfb
sleep 2
mv exlcudeytpsfb redsocks
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/main/redsocks.conf
mv redsocks /etc/init.d/
chmod +x /etc/init.d/redsocks
mv redsocks.conf /etc/
echo "edit the redsocks.conf file of /etc/ directory and update the proxy details"
sleep 2
# Display the text in green
GREEN='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GREEN}powered by md hasan khan${NC}"
sleep 5
cd /
rm -- "$0"
