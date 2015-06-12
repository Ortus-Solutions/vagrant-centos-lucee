#!/bin/bash

echo "================= START FINAL-OUTPUT.SH $(date +"%r") ================="
echo " "
echo "Doing some last minute cleanup ..."

# some final housekeeping
yum update > /dev/null

sudo rm /root/*.run > /dev/null
sudo rm /root/lucee-options.txt > /dev/null
sudo rm /root/jcameron-key.asc > /dev/null

# Gid rid of firewalld
systemctl stop firewalld
systemctl disable firewalld

echo " "
echo "================= END FINAL-OUTPUT.SH $(date +"%r") ================="
echo " "
echo " "
echo "$1"
echo " "
echo "========================================================================"
echo " "
echo "http://$2 ($3)"
echo " "
echo "Lucee Server/Web Context Administrators"
echo " "
echo "http://$2:8888/lucee/admin/server.cfm"
echo "http://$2:8888/lucee/admin/web.cfm"
echo " "
echo " "
echo "Password (for each admin): password"
echo " "
echo " "
echo "Webmin"
echo " "
echo "https://$2:10000"
echo "User: root"
echo "Password: vagrant"
echo " "
echo "========================================================================"
