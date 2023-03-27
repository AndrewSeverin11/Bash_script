#!/bin/bash
#apt-get purge openjdk-\* icedtea-\* icedtea6-\*&&
rm -rf /usr/lib/jvm&&
cd /usr/'local'&&
apt install wget -y&&
wget http://jupiter8.ru/java/jre-8u201-linux-x64.tar.gz -O jre-linux.tar.gz&&
tar xvfz jre-linux.tar.gz&&
mkdir /usr/lib/jvm&&
mv jre1.* /usr/lib/jvm/jre&&
rm -f jre-linux.tar.gz&&
sudo update-alternatives --remove-all java
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jre/bin/java 1&&
java -version
echo 'Установка Java успешно завершена!'
