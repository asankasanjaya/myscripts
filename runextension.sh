cd
rm -R gce-extention/*
cp /home/sanjaya/stratos-source/extensions/load-balancer/gce-extension/target/org.apache.stratos.gce.extension-4.1.0-SNAPSHOT.zip gce-extention/

cd gce-extention/

unzip org.apache.stratos.gce.extension-4.1.0-SNAPSHOT.zip
cd org.apache.stratos.gce.extension-4.1.0-SNAPSHOT/bin
sudo ./gce-extension.sh

