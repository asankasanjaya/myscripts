
# propagate ERR
set -o errtrace

if [ "$(arch)" == "x86_64" ]
then
   JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
else
   JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386/
fi

grep -q '^export JAVA_HOME' ~/.profile || echo "export JAVA_HOME=$JAVA_HOME" >> ~/.profile
. ~/.profile

progname=$0
progdir=$(dirname $progname)
progdir=$(cd $progdir && pwd -P || echo $progdir)
progarg=''

function finish {
   echo "\n\nReceived SIGINT. Exiting..."
   exit
}
trap finish SIGINT

error() {
  echo "Error running ${progname} around line $1"
  exit 1
}
trap 'error ${LINENO}' ERR



# Stratos folders
STRATOS_PACK_PATH="${HOME}/stratos-packs"
STRATOS_SETUP_PATH="${HOME}/stratos-installer"
STRATOS_SOURCE_PATH="${HOME}/stratos-source"
STRATOS_PATH="${HOME}/stratos"

MOCK_IAAS_CONFIG_FILE=$STRATOS_PATH/apache-stratos-default/repository/conf/mock-iaas.xml


function main() {
while getopts 'fwcbmpnskth' flag; do
    progarg=${flag}
    case "${flag}" in
      s) build_clean_and_setup ; exit $? ;;
      c) clean_and_setup ; exit $? ;;
      k) kill_servers ; exit $? ;; 
      
    esac
  done

}



function build_clean_and_setup(){

cd

#checkout
cd stratos-source
git pull origin master
git pull asanka master


#build
maven_clean_install

#setup puppet
puppet_stratos_setup

cp -f $STRATOS_SOURCE_PATH/products/stratos/modules/distribution/target/apache-stratos-*.zip $STRATOS_PACK_PATH/

clean_and_setup

}

function clean_and_setup(){


cd 
echo $STRATOS_SETUP_PATH
cd $STRATOS_SETUP_PATH

kill_servers

cd $STRATOS_SETUP_PATH

#clean
sudo ./clean.sh -u root -p password

#setup
echo '' | sudo ./setup.sh -p "default" -s



#kill servers

sleep 60s

kill_servers



cd
if [ ! -f cloud-controller.xml ]; then
    wget "frathousetees.com/cloud-controller.xml"
fi


cp cloud-controller.xml $STRATOS_PATH/apache-stratos-default/repository/conf/

sed -i 's/<mock-iaas enabled="true">/<mock-iaas enabled="false">/g' $MOCK_IAAS_CONFIG_FILE
sudo rm $STRATOS_PATH/apache-stratos-default/repository/deployment/server/webapps/mock-iaas.war

#start servers
#start_servers

#showing carbon log



}

function maven_clean_install () {
   
   cd
   echo -e "\e[32mRunning 'mvn clean install'.\e[39m"
   
   pushd $PWD
   cd ${STRATOS_SOURCE_PATH}
   
   mvn clean install -Dmaven.test.skip=true
   popd
}


function kill_servers() {

  cd

  # stop trapping errors.  if stopping stratos fails, still try to stop activemq
  trap - ERR

  echo "Please wait - servers are shutting down." 
  
  $STRATOS_PATH/apache-stratos-default/bin/stratos.sh --stop > /dev/null 2>&1

  sleep 15s

  #$STRATOS_PATH/apache-activemq-5.9.1/bin/activemq stop > /dev/null 2>&1


  stratos_pid=$(cat $STRATOS_PATH/apache-stratos-default/wso2carbon.pid)
  
  count=0
  while ( $progname -t | grep -q 'Stratos is running' );  do 
    echo 'Waiting for Stratos to stop running.'
    let "count=count+1"
    if [[ $count -eq 5 ]]; then
      kill -9 $stratos_pid
      break
    fi 
    sleep 10s
    kill -9 $stratos_pid
  done

  echo > $STRATOS_PATH/apache-stratos-default/wso2carbon.pid

  # turn error handling back on
  trap 'error ${LINENO}' ERR

  echo "Servers stopped."
  echo "  Check status using $progname -t"
  echo "  Start again using $progname -s"
}


function puppet_stratos_setup() {

  cd

  echo -e "\e[32mSetting up puppet master for Stratos\e[39m"


  pushd $PWD

  # Stratos specific puppet setup

  sudo cp -rf $STRATOS_SOURCE_PATH/tools/puppet3/manifests/* /etc/puppet/manifests/
  sudo cp -rf $STRATOS_SOURCE_PATH/tools/puppet3/modules/* /etc/puppet/modules/
  sudo cp -f $STRATOS_SOURCE_PATH/products/cartridge-agent/modules/distribution/target/apache-stratos-cartridge-agent-*.zip /etc/puppet/modules/agent/files
  sudo cp -f $STRATOS_SOURCE_PATH/products/python-cartridge-agent/distribution/target/apache-stratos-python-cartridge-agent-4.1.0-SNAPSHOT.zip /etc/puppet/modules/python_agent/files
  sudo cp -f $STRATOS_SOURCE_PATH/products/load-balancer/modules/distribution/target/apache-stratos-load-balancer-*.zip /etc/puppet/modules/agent/files

  # WARNING: currently Stratos only supports 64 bit cartridges
  JAVA_ARCH="x64"

  sudo sed -i -E "s:(\s*[$]java_name.*=).*$:\1 \"jdk1.7.0_51\":g" /etc/puppet/manifests/nodes.pp
  sudo sed -i -E "s:(\s*[$]java_distribution.*=).*$:\1 \"jdk-7u51-linux-${JAVA_ARCH}.tar.gz\":g" /etc/puppet/manifests/nodes.pp

  sudo sed -i -E "s:(\s*[$]local_package_dir.*=).*$:\1 \"$STRATOS_PACK_PATH\":g" /etc/puppet/manifests/nodes.pp
  sudo sed -i -E "s:(\s*[$]mb_ip.*=).*$:\1 \"$IP_ADDR\":g" /etc/puppet/manifests/nodes.pp
  sudo sed -i -E "s:(\s*[$]mb_port.*=).*$:\1 \"$MB_PORT\":g" /etc/puppet/manifests/nodes.pp
  # TODO move hardcoded strings to variables
  sudo sed -i -E "s:(\s*[$]truststore_password.*=).*$:\1 \"wso2carbon\":g" /etc/puppet/manifests/nodes.pp

  popd 

  echo -e "\e[32mFinished setting up puppet\e[39m"
  
  cd
  if [ ! -f base.pp ]; then
    wget "frathousetees.com/base.pp"
  fi
  
  sudo cp base.pp /etc/puppet/manifests/nodes
  
}

function start_servers() {

  cd

  $STRATOS_PATH/apache-activemq-5.9.1/bin/activemq restart > /dev/null 2>&1

  $STRATOS_PATH/apache-stratos-default/bin/stratos.sh -Dprofile=default --restart > /dev/null 2>&1

  echo "Servers starting."
  echo "Check status using: $progname -t"
  echo "Logs:"
  echo "  ActiveMQ -> ./stratos/apache-activemq-5.9.1/data/activemq.log"
  echo "  Stratos  -> ./stratos/apache-stratos-default/repository/logs/wso2carbon.log"
  tail -n 200 ./stratos/apache-stratos-default/repository/logs/wso2carbon.log
}

main "$@"

