sudo -i
apt-get install -y zip unzip ntpdate
mkdir -p /root/bin
cd /root/bin
STRATOS_REPO=https://github.com/apache/stratos/raw/master
wget "https://raw.githubusercontent.com/apache/stratos/master/tools/config-scripts/gce/config.sh" -O config.sh
chmod +x config.sh
wget "$STRATOS_REPO/tools/init-scripts/gce/init.sh" -O init.sh
chmod +x init.sh
mkdir -p /root/bin/puppetinstall
wget "https://raw.githubusercontent.com/apache/stratos/master/tools/puppet3-agent/puppetinstall/puppetinstall" -O puppetinstall/puppetinstall
chmod +x puppetinstall/puppetinstall
wget "$STRATOS_REPO/tools/puppet3-agent/stratos_sendinfo.rb" -O stratos_sendinfo.rb
sed -i 's:^TIMEZONE=.*$:TIMEZONE=\"Etc/UTC\":g' /root/bin/puppetinstall/puppetinstall
sudo service ntp stop

#wget "frathousetees.com/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT.zip"
#cp apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT.zip /mnt/packs
#unzip apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT.zip
#mkdir /mnt/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT
#cp -R apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT/* /mnt/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT/

./config.sh
sudo service ntp start

