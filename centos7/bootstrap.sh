#!/bin/bash
TELEGRAF_VERSION=telegraf-1.3.5-1.x86_64.rpm
INFLUX_VERSION=influxdb-1.3.1.x86_64.rpm
CHRONO_VERSION=chronograf-1.3.5.0.x86_64.rpm
KAPACITOR_VERSION=kapacitor-1.3.1.x86_64.rpm

cat <<EOT >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOT
sysctl -p

systemctl restart network.service
yum -y install epel-release
yum repolist
yum update -y
yum install -y wget nano

# Install Influx DB
wget -nv -O $INFLUX_VERSION https://dl.influxdata.com/influxdb/releases/$INFLUX_VERSION
yum localinstall -y $INFLUX_VERSION
systemctl start influxdb

# Install Telegraf
wget -nv -O $TELEGRAF_VERSION https://dl.influxdata.com/telegraf/releases/$TELEGRAF_VERSION
yum localinstall -y $TELEGRAF_VERSION
if [ ! -f /vagrant/telegraf/telegraf.conf ]; then
    echo "Found telegraf.conf.  Installing."
	mv /vagrant/telegraf/telegraf.conf /etc/telegraf
fi
systemctl start telegraf

# Install Kapacitor
wget -nv -O $KAPACITOR_VERSION https://dl.influxdata.com/kapacitor/releases/$KAPACITOR_VERSION
yum localinstall -y $KAPACITOR_VERSION
systemctl start kapacitor

# Install Chronograf
wget -nv -O $CHRONO_VERSION https://dl.influxdata.com/chronograf/releases/$CHRONO_VERSION
yum localinstall -y $CHRONO_VERSION
systemctl start chronograf

# Install NodeJS
curl --silent --location https://rpm.nodesource.com/setup_7.x | bash -
yum -y install nodejs
