#!/bin/bash

BASE_NAME=influxDignostic_$(hostname)_$(date +%Y%m%d-%H%M)
OUT_DIR=$BASE_NAME
INFLUXDB_USER="foo"
INFLUXDB_PASSWORD="bar"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -u|--username)
    $INFLUXDB_USER="$2"
    shift # past argument
    ;;
    -p|--password)
    $INFLUXDB_PASSWORD="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo "Setting Base Name to" $BASE_NAME
#echo USERNAME  = "${INFLUXDB_USER}"
#echo PASSWORD  = "${INFLUXDB_PASSWORD}"

if [ ! -f $OUT_DIR ];
then
	mkdir $OUT_DIR
fi

base() {
	echo "#######################"
	echo "OS and INFLUXDB VERSION"
	echo "#######################"

	if [ -f /etc/redhat-release ];
	then
		echo 'Detected RHEL or Centos'
		cat /etc/redhat-release
		rpm -qa | grep influx
	elif [ -f /etc/lsb-release ];
	then
		echo 'Detected Ubuntu or other Debian OS'
		cat /etc/lsb-release
		dpkg -l | grep influx
	else
		echo 'Detected other OS. This script only works on RHEL/CentOS or Ubuntu/Debian.'
		echo 'Exiting.'
		exit 1
	fi

	echo -e ""
	echo "################"
	echo "MEMORY and CPU"
	echo "################"
	free
	cat /proc/cpuinfo

	echo -e ""
	echo "################"
	echo "DISK"
	echo "################"
	df -hT
	mount
	fdisk -l

	if hash iostat 2>/dev/null; then
		iostat -xd 1 30
	else
		echo -e ""
		echo "iostat not installed. Skipping"
	fi
}

base > $OUT_DIR/$BASE_NAME.txt

cp /etc/influxdb/influxdb.conf $OUT_DIR
# look for a meta conf file
# Thsi should only exist for Enterprise Customers
if [ -f /etc/influxdb/influxdb-meta.conf ]; then
    echo "Found meta conf file"
    cp /etc/influxdb/influxdb-meta.conf .
fi

influx -username $INFLUXDB_USER -password $INFLUXDB_PASSWORD -execute "SHOW SHARDS;" > $OUT_DIR/show_shards.txt
influx -username $INFLUXDB_USER -password $INFLUXDB_PASSWORD -execute "SHOW STATS;" > $OUT_DIR/show_stats.txt
influx -username $INFLUXDB_USER -password $INFLUXDB_PASSWORD -execute "SHOW DIAGNOSTICS;" > $OUT_DIR/show_diagnostics.txt
for db in $(influx -execute 'show databases' -format csv | tr ',' ' ' | awk '/databases/ { print $2 }'); do 
	influx -username $INFLUXDB_USER -password $INFLUXDB_PASSWORD -execute "show retention policies on $db" >> $OUT_DIR/show_retention_policies.txt; 
done
influx -username $INFLUXDB_USER -password $INFLUXDB_PASSWORD -execute "SHOW CONTINUOUS QUERIES;" > $OUT_DIR/show_continuous_queries.txt

#ZIP it all up and send it
tar -czf ${BASE_NAME}.tar.gz $OUT_DIR

echo "Done!!"
echo "Please send the tar file to Influxdata support"