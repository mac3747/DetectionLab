#! /bin/bash

failure(){
    time=date
    echo "$time - $1 failed"
    if $2; then
        exit 0
    fi 
}

if [[ $EUID -ne 0 ]]; then 
    echo "Must be root to install"
    exit 1
else
    echo "Updating APT"
    apt-get update >> /dev/null
    apt-get install git -y>>/dev/null || failure 'git install' true

    echo "Updating Python"
    apt-get install python3-pip -y || failure 'python3-pip' true
    apt-get install python3-dev -y  || failure 'python3-dev' true
    pip3 install --upgrade setuptools  || failure 'pip3 setuptools' true

    echo "Cloning Caldera"
    cd /home/vagrant
    git clone -q https://github.com/mitre/caldera.git || failure 'cloning caldera' true
    
    echo "Installing PIP Requirements"
    pip3 install -r /home/vagrant/caldera/caldera/requirements.txt|| failure 'Caldera PIP requirements' true


    echo "Installing MONGODB"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 || failure 'Adding APT KEY' true   
    echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
    sudo apt-get update || failure 'Updating APT' false
    sudo apt-get install -y mongodb-org || failure 'MONGODB Install' true 
    # systemctl enable mongodb >>/dev/null|| failure 'Enable MONGODB on startup' false
    systemctl start mongod || failure 'Start MONGODB' false
    
    echo "Configuring Mongo"
    cp /vagrant/resources/caldera/mongod.conf /etc/

    echo "Configuring Caldera"
    cd /home/vagrant/caldera/
    mkdir -p dep/crater/crater || failure 'failed to create directory for crater' false
    cp /vagrant/resources/caldera/CraterMain.exe dep/crater/crater/ || failure 'failed to move CraterMain.exe' false
    cp /vagrant/resources/caldera/settings.yaml /home/vagrant/caldera/caldera/conf/
    chown vagrant:vagrant -R /home/vagrant/caldera/
    
    echo "Starting Caldera"
    #python3 /home/vagrant/caldera/caldera/caldera.py &  
fi
