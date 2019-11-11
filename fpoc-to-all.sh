#! /bin/bash
#
# 2019110701 : Ferry Kemps - Modified [-options] to -show, -run
# 2019110801 : Ferry Kemps - Addess -address option for CLI IP-address input
# 2019110802 : Ferry Kemps - Short and long option specification
FPOCSCRIPTVERSION="2019110802"
#
# This script is to manage running FortiPoCs and allows you to execute CLI commands on FortiPoC console.
# Idea is to:
#   Step 1) upload your ssh-key, validate SSH access with key
#   Step 2) lock admin account (pwd). From that point onwards management via SSH CLI commands
# See steps below and uncommand & run in that order.
# Uncomment/add "sshfpoc" or "sshfpocparallel" to execute commands sequential on FPoCs or in parallel.
# These command need to be configured inbetween "---- Start -----" and "----- End -----" section.
# Use examples provided for guidance.
#
# Provide the list of FortiPoC IP-addresses e.g. "1.1.1.1". Use "1.1.1.1 2.2.2.2 3.3.3.3" space delimited format for multiple FPs
#
# Single-IP
#IPADDRESS="35.198.220.112"
# Multiple-IP
#IPADDRESS="35.240.165.124 35.198.248.113 34.87.47.162 34.87.78.29 35.247.185.153 35.198.231.30 35.197.145.14 35.240.252.16 35.198.205.75 35.247.165.92 35.198.212.6 35.198.247.56 35.240.166.26 35.247.136.40 35.247.174.125"
# Workshop-IP
IPADDRESS="35.247.183.139 35.240.187.180 35.198.239.33"

# Parameters
USER="admin"
PWD="fpxfwb2019"
export USER PWD
COUNT=1

# Functions
function sshfpoc {
   CMD=$1
   ssh ${USER}@${HOST} $CMD
}

function sshfpocparallel {
   CMD=$1
   (ssh ${USER}@${HOST} $CMD) &
}

# Command and option handling
case $1 in
  -a | --address) echo "Using CLI provided IP-address(es)"
     IPADDRESS=$2;;
  -s | --show) echo "";echo "----------------- Executing commands on FortiPoCs --------------------------"
     grep "sshfpoc" $0 | egrep -v '^#|egrep|function'
     echo "----------------------------------------------------------------------------"
     exit;;
  -r | --run) echo "Okay here we go......";;
  *) echo "(Version: ${FPOCSCRIPTVERSION})"
     echo "Usage: $0 OPTION"
     echo ""
     echo "OPTION: -a    --address       IP-address FortiPoC 192.168.254.1 or multiple via \"192.168.254.2 192.168.254.3\" space delimitted"
     echo "        -h    --help          Show script usage and options"
     echo "        -r    --run           Execute commands on FortiPoC CLI"
     echo "        -s    --show          Show commands executed on FortiPoC CLI"
     echo ""
     echo "";exit;;
esac

STARTTIME=`date`
clear;echo -n "---------------- Start of actions on FortiPoC - $STARTTIME  ---------------------"; echo ""
for HOST in ${IPADDRESS}; do
  echo ""
  echo "======== FortiPoC on IP : ${HOST} ========= FPOC: ${COUNT}"

#
# Step 1) Install SSH keys
#
#echo "Adding SSK-keys"; sshfpoc 'set ssh authorize keys "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNJYNMdL9o1Xt3ADg1DCOBhp8Vvr6eX8KGOK9tpqYH8Q6yW6Y1ARzDwqytg2zacRqwwZdpelEQ2vc9Kd4xsYA2Ds/OvUhwxJ1mPr5AVaqy6UxmkSU4fIQaIwkBgfaVxxntND8WRQVbjvkvlfoVBel93yz4jYcUDG0wsBNawuMS2BYHXDWb+w5RtEtkWf1cGfzHVSQSrhmk1uFFXMhFY95t9b1mMgroZqYkYaYb1sxmOxnQTQwC1J5Hf8LajXAMPV9br523mCXpJ5aeD+1T1706XM8EikT9JHDhgnqyTLMf8FAdaetT2fju2FZ9WnmHM2V3wQnC0t0QIuoYgEnZlQND fkemps@Ferrys-MacBook-Pro.local"'
#echo "Adding SSK-keys"; sshfpoc 'set ssh authorize keys "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRB3XI5fX/nRfFLscaaAu4Nz0oNk6gzE9qo7sJ318me+y//i1qpjeS2jB6WjWaUgNeaUuolM4dWfZlkpziQD+oKZVz9ov/NS6QGar9KGcNlLoiuyozZcsZf1DULFKHhYwPm8RO/Xlfem8HVUk8tND2UiVGxStRlYK/dWikeEXdMpti3tWHz/00SXSRilS67uhnQ3VQhRmqforizwE+fhLero4kOxQi8ATSvSlgUe/+5SwvjwSi0poeqiZCVd2ljLmxoZck7dLBULFr3FQIHFyCYlmvI2BAn7j0T8OhonjeuM/7/kd2UckTiBa8wZj/9nPw3Ad9C3Lli5eh4O5tbMKD jameschoa@jamess-macbook-pro.local"'
#
# Step 2) Validate ssh access : login /logout check
#echo "Validating access"; sshfpoc 'exit'

#
# 3) step Change admin pwd
#
#echo "Changing admin pwd"; sshfpoc 'set passwd fad2019'

#
# FortiPoC: Title settings
#
#echo "Setting tile"
#sshfpoc 'set gui title "FortiProxy and FortiWeb Workshop - FPOC" '

#
# Remove admin pwd
#
#echo "Remove admin pwd"; sshfpoc 'unset passwd fpxfwb2019'

#
# Removing SSH keys
#
#sshfpoc 'unset ssh authorized keys 1'

#
# FortiPoC: Sync Ropositories and load POC-definition
#
#ssh admin@${HOST} "repo sync"
#ssh admin@${HOST} << EOF
#repo delete 1
#y
#EOF
#ssh admin@${HOST} "poc repo define poc/ferry/FortiWeb-Advanced-Solutions-Workshop-v2.5.fpoc refresh"

#
# FortiPoC: show loaded POC-definitions
#
#ssh admin@${HOST} "poc list"
#ssh admin@${HOST} 'poc launch "FortiWeb Basic solutions"'
#ssh admin@${HOST} 'poc launch "FortiWeb Advanced Solutions"'

#
# FortiPoC: set timezone
#
# Obtain timezones with "get timezone"
#sshfpoc 'set timezone Europe/Lisbon'
#sshfpoc 'set timezone Asia/Singapore'

#
# FortiPoC: delete, sync repo, load poc-definitions
#
#------- Start of sequence1 -----
#sshfpoc 'repo sync'
#sshfpoc 'repo sync gcp-fkemps'
#sleep 4
#sshfpoc 'poc delete \"FortiADC Gbl App Deliv 5.3.1 Att\"'
#sleep 4
#sshfpoc 'poc delete \"FortiADC WAF\"'
#sleep 4
#sshfpoc 'poc repo define "poc/FortiADC-Global-App-Delivery-5.3.1-Attendee-PortugalQ32019.fpoc"'
#sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.1.2.fpoc"'
#---- end of sequence1 -------
##sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.2.fpoc"'
##sshfpoc 'poc delete "FortiWeb-Docker"'
##sshfpoc 'poc delete "FortiWeb-SME-MachineLearning"'
##sshfpoc 'poc delete "FAD-FWB-WCCP-v1.0"'
##echo "y" | sshfpoc 'poc delete "FortiWeb Advanced Solutions v2.7"'
##sshfpocpoc 'repo define "poc/FAD-FWB-WCCP-v1.0-SME.fpoc" refresh'
##sshfpocpoc 'repo define "poc/ADC+WAF_SME_v0.1.fpoc" refresh'
##sshfpocpoc 'repo define "poc/FADFWB-CM_SF-v0.3.13.fpoc" refresh'
##sshfpocpoc 'launch "FADFWB-CM_SF"'
##sshfpocpoc 'delete all'
##sshfpocpoc 'repo define "poc/FortiWeb-Advanced-Solutions-Workshop-v2.7.fpoc" refresh'
##sshfpocpoc 'repo define "poc/rvoong/FortiWeb-Basic-solution-workshop-v2.3.fpoc" refresh'
##sshfpocpoc 'repo define "poc/FortiWeb-Docker-v0.1.0.fpoc" refresh'
#sshfpoc 'poc prefetch all'
##sshfpocset 'gui title "Ultimate FortiADC Workshop"'

#
# FortiPoC: Launch a PoC-definition
#
#echo "Launching PoC-definition"; sshfpocparallel 'poc launch "FortiADC WAF"'

#
# FortiPoC: Eject a PoC-definition
#
#echo "Ejecting PoC-definition"; sshfpocparallel 'poc eject'

#
# FortiPoC: Get FP task list
#
echo "Tasklist ";sshfpoc 'get task list'

#
# FortiPoC: Purge files
#
#echo "Purge files ";sshfpoc 'execute purge files'

#
# FortiPoC: Get loaded poc-definitions
#
#echo "Loaded POC-definitions";sshfpoc 'poc list'

#
# FortiPoC: Prefetch all POC-definitions and documentation
#
#sshfpoc "poc prefetch all"

#
# FPX: format 2nd disk
#ssh -p 10103 admin@${HOST} << EOF
#execute disk format 32
#y
#EOF
#

#
# FWB: set port MTU 1460
#
#ssh -p 10102 admin@${HOST} << EOF
#config system interface
#edit port1
#set mtu 1460
#end
#EOF

#
# FAD GLB: request VS configures
#
#echo "Cannes"
#ssh -p 10102 admin@${HOST} << EOF
#config vdom
#edit cannes-prod
#show load-balance virtual-server
#end
#EOF
#echo "Sunnyvale"
#ssh -p 10104 admin@${HOST} << EOF
#config vdom
#edit sunnyvale-prod
#show load-balance virtual-server
#end
#EOF

# end of loop
  let COUNT++
done
ENDTIME=`date`
echo"";echo -n "---------------- End of actions on FortiPoC - $ENDTIME  ---------------------";echo ""
