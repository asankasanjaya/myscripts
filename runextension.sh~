
#buiuld and run gce-extension
cd

cd 
cd stratos-source/
git pull origin master

cd
cd stratos-source/extensions/load-balancer/gce-extension/
mvn clean install

cd
rm -R gce-extension/*
cp /home/sanjaya/stratos-source/extensions/load-balancer/gce-extension/target/org.apache.stratos.gce.extension-4.1.1-SNAPSHOT.zip gce-extension/

cd gce-extension/

unzip org.apache.stratos.gce.extension-4.1.1-SNAPSHOT.zip

cd
if [ ! -f gsoc-980533dc26c3.p12 ]; then
   wget "http://codexpotech.com/gsoc-980533dc26c3.p12"
fi

cd gce-extension/org.apache.stratos.gce.extension-4.1.1-SNAPSHOT/conf

rm gce-configuration.xml
wget "http://codexpotech.com/gce-configuration.xml"

cd ..
cd bin

sudo ./gce-extension.sh

