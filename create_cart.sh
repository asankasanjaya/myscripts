function main(){
while getopts 'fwcbmpnskth' flag; do
    progarg=${flag}
    case "${flag}" in
      s) setup ; exit $? ;;
      
    esac
  done
}

function setup(){
sudo -i
apt-get install -y zip unzip ntpdate
mkdir -p /root/bin
cd /root/bin
STRATOS_REPO=https://github.com/apache/stratos/raw/master
wget "https://raw.githubusercontent.com/asankasanjaya/myrepo/master/config.sh" -O config.sh
chmod +x config.sh
wget "$STRATOS_REPO/tools/init-scripts/gce/init.sh" -O init.sh
chmod +x init.sh
mkdir -p /root/bin/puppetinstall
wget "$STRATOS_REPO/tools/puppet3-agent/puppetinstall/puppetinstall" -O puppetinstall/puppetinstall


chmod +x puppetinstall/puppetinstall
wget "$STRATOS_REPO/tools/puppet3-agent/stratos_sendinfo.rb" -O stratos_sendinfo.rb

sed -i 's:^TIMEZONE=.*$:TIMEZONE=\"Etc/UTC\":g' /root/bin/puppetinstall/puppetinstall
sudo service ntp stop
wget "frathousetees.com/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT.zip"
unzip apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT.zip -d apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT
mkdir /mnt/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT
cp -R apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT/* /mnt/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT/

./config.sh
sudo service ntp start

}

