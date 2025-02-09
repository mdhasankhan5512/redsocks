cd /tmp
opkg update
sleep 2
opkg install redsocks iptables-nft iptables-mod-nat-extra
sleep 2
rm /etc/init.d/redsocks
rm /etc/redsocks.conf
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/refs/heads/main/redsocks
sleep 2
# mv exlcudetiktok redsocks
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/main/redsocks.conf
mv redsocks /etc/init.d/
chmod +x /etc/init.d/redsocks
mv redsocks.conf /etc/
sleep 2
cat <<EOF > /etc/config/redsocks
config redsocks 'main'
	option enabled '1'
	option host '127.0.0.1'
	option port '1080'
	option authentication '1'
	option username 'test'
	option password 'test'
EOF
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/refs/heads/main/redsocks.lua
sleep 1
mv redsocks.lua /usr/lib/lua/luci/model/cbi/
sleep 1
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/refs/heads/main/controllar.lua
sleep 1
mv controllar.lua /usr/lib/lua/luci/controller/redsocks.lua 
sleep 1
wget https://raw.githubusercontent.com/mdhasankhan5512/redsocks/refs/heads/main/update_redsocks.sh
mv update_redsocks.sh /root/
chmod +x /root/redsocks.sh
/etc/init.d/rpcd restart
echo "after saving and applying proxy details don't forget to click Update Redsocks Config"
# Display the text in green
GREEN='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GREEN}powered by md hasan khan${NC}"
sleep 5
cd /
rm -- "$0"
