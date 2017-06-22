# Influx Vagrant Sandbox

Vagrant boxes for a full TICK stack installation on centos7.

## Usage

```bash
vagrant up
```

Alternatively you can also use the up.sh and restore.sh scripts.  up.sh will start the vagrant box but will also take an initial snapshot.  If you want to restore your box to this initial state use the restore.sh script.

## Configuration
Currently there is only a configuration file for Telegraf which is in data/telegraf/telegraf.conf.  This will be moved to /etc/telegraf when Vagrant starts.
