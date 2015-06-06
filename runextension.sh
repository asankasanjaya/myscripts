
#buiuld and run gce-extension
cd

cd 
cd stratos-source/
git pull origin master
git pull asanka master
cd
cd stratos-source/extensions/load-balancer/gce-extension/
mvn clean install

cd
rm -R gce-extension/*
cp /home/sanjaya/stratos-source/extensions/load-balancer/gce-extension/target/org.apache.stratos.gce.extension-4.1.0-SNAPSHOT.zip gce-extension/


sudo cd gce-extension/

sudo unzip org.apache.stratos.gce.extension-4.1.0-SNAPSHOT.zip
sudo cd org.apache.stratos.gce.extension-4.1.0-SNAPSHOT/bin
sudo ./gce-extension.sh

