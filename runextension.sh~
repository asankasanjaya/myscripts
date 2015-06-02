
#buiuld and run gce-extension
cd

cd 
cd stratos-source/extensions/load-balancer/gce-extension/
mvn clean install

cd
rm -R gce-extension/*
cp /home/sanjaya/stratos-source/extensions/load-balancer/gce-extension/target/org.apache.stratos.gce.extension-4.1.0-SNAPSHOT.zip gce-extension/

cd gce-extention/

unzip org.apache.stratos.gce.extension-4.1.0-SNAPSHOT.zip
cd org.apache.stratos.gce.extension-4.1.0-SNAPSHOT/bin
sudo ./gce-extension.sh

