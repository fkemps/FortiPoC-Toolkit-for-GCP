#! /bin/bash
#
# 2019110701 : Ferry Kemps - Modified [-options] to -show, -run
# 2019110801 : Ferry Kemps - Addess -address option for CLI IP-address input
# 2019110802 : Ferry Kemps - Short and long option specification
# 2019111101 : Ferry Kemps - Some clean-up and comments
# 2019112501 : Ferry Kemps - Updated --address description
FPOCSCRIPTVERSION="2019112501"
#
# This script is to manage running FortiPoCs by executing CLI commands on FortiPoC console.
# Idea is to:
#   Step 1) upload your ssh-key and validate SSH access via pub-key
#   Step 2) lock admin account (set pwd). From that point onwards management via SSH-only per CLI. Attendees use guest/guest for FP access.
#
# See steps below and uncommand & run in that order.
# Uncomment/add "sshfpoc" or "sshfpocparallel" to execute commands sequential on FPoCs or in parallel.
# Command need to be located inbetween "---- Start -----" and "----- End -----" section.
# Use provided examples for guidance.
#
# List of FortiPoC IP-addresses e.g. "1.1.1.1" or use "1.1.1.1 2.2.2.2 3.3.3.3" space delimited format for multiple FPs.
# Use this script embedded method in case you don't want to use -a / --address command line option
#
# Single-IP
#IPADDRESS="a.b.c.d"
# Multiple-IP's
#IPADDRESS="x.x.x.x y.y.y.y z.z.z.z"

# Parameters
USER="admin"
PWD="F0rt1n3t2019"
export USER PWD
COUNT=1

#######################
# Functions
#######################
function sshfpoc {
   CMD=$1
   ssh -o StrictHostKeyChecking=no ${USER}@${HOST} $CMD
}

function sshfpocparallel {
   CMD=$1
   (ssh -o StrictHostKeyChecking=no ${USER}@${HOST} $CMD) &
}

#######################
# Option handling
#######################
case $1 in
  -a | --address) echo "Using CLI provided IP-address(es)"
     IPADDRESS=$2;;
  -e | --execute) echo "Okay here we go......";;
  -r | --review)  echo "";echo "----------------- Executing commands on FortiPoCs --------------------------"
     grep "sshfpoc" $0 | egrep -v '^#|egrep|function'
     echo "----------------------------------------------------------------------------"
     exit;;

  *) echo "(Version: ${FPOCSCRIPTVERSION})"
     echo "Usage: $0 OPTION"
     echo ""
     echo "OPTION: -a    --address       Execute commands on IP-address FortiPoC 192.168.254.1 or \"192.168.254.2 192.168.254.3\" space delimitted"
     echo "        -h    --help          Show script usage and options"
     echo "        -e    --execute       Execute commands on FortiPoC CLI"
     echo "        -r    --review        Review commands to be executed on FortiPoC CLI"
     echo ""
     echo "";exit;;
esac


#######################
# FortiPoC management
#######################
STARTTIME=`date`
clear;echo -n "---------------- Start of actions on FortiPoC - ${STARTTIME}  ---------------------"; echo ""
echo "Executing on targets ${IPADDRESS}"; echo ""
for HOST in ${IPADDRESS}; do
  echo "======== FortiPoC on IP : ${HOST} ========= FPOC: ${COUNT}"

# Uncomment the "echo" rules for step 1, 2 and 3. Comment them again once done.
##########################################################################
# Step 1) Install SSH keys 2) Validate ssh access 3) Change admin password
##########################################################################
#echo "Adding SSK-keys"; sshfpoc 'set ssh authorize keys "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNJYNMdL9o1Xt3ADg1DCOBhp8Vvr6eX8KGOK9tpqYH8Q6yW6Y1ARzDwqytg2zacRqwwZdpelEQ2vc9Kd4xsYA2Ds/OvUhwxJ1mPr5AVaqy6UxmkSU4fIQaIwkBgfaVxxntND8WRQVbjvkvlfoVBel93yz4jYcUDG0wsBNawuMS2BYHXDWb+w5RtEtkWf1cGfzHVSQSrhmk1uFFXMhFY95t9b1mMgroZqYkYaYb1sxmOxnQTQwC1J5Hf8LajXAMPV9br523mCXpJ5aeD+1T1706XM8EikT9JHDhgnqyTLMf8FAdaetT2fju2FZ9WnmHM2V3wQnC0t0QIuoYgEnZlQND fkemps@Ferrys-MacBook-Pro.local"'
#echo "Validating access"; sshfpoc 'exit'
#echo "Changing admin pwd"; sshfpoc 'set passwd fortinet2020'

# ------------------ put your FortiPoC CLI commands to execute below this line ---------------------
#
# FortiPoC: Title settings
#
#echo "Setting tile"
#sshfpoc 'set gui title "FortiProxy and FortiWeb Workshop - FPOC" '

# Remove admin pwd
# ----------------------
#echo "Remove admin pwd"; sshfpoc 'unset passwd F0rt1n3t2019'

# Removing SSH keys
# ----------------------
#sshfpoc 'unset ssh authorized keys 1'

# FortiPoC: set timezone
# ----------------------
# Obtain timezones with "get timezone"
#echo "Setting timezone"; sshfpoc 'set timezone Europe/Amsterdam'
#echo "Setting timezone"; sshfpoc 'set timezone Asia/Singapore'

# FortiPoC: Launch a PoC-definition
# ----------------------
#echo "Launching PoC-definition"; sshfpocparallel 'poc launch "FortiProxy Workshop"'

# FortiPoC: Eject a PoC-definition
# ----------------------
#echo "Ejecting PoC-definition"; sshfpocparallel 'poc eject'

# FortiPoC: Get FP task list
# ----------------------
echo "Tasklist ";sshfpoc 'get task list'

# FortiPoC: Purge files
# ----------------------
#echo "Purge files ";sshfpoc 'execute purge files'

# FortiPoC: Get loaded poc-definitions
# ----------------------
#echo "Loaded POC-definitions";sshfpoc 'poc list'

# FortiPoC: Prefetch all POC-definitions and documentation
# ----------------------
#sshfpoc "poc prefetch all"

# FortiPoC: Set FortiPoC GUI title
# ----------------------
#sshfpoc 'set gui title "Ultimate FortiADC Workshop"'

#
# FortiPoC: Set Simple Menu
#
#echo "Enable simple menu"; sshfpoc 'set gui simple enable'

#
# FortiPoC: random example collection delete, sync repo, load poc-definitions
# ----------------------
#sshfpoc 'repo sync'
#sshfpoc 'repo sync gcp-fkemps'
#sshfpoc 'poc delete \"FortiADC Gbl App Deliv 5.3.1 Att\"'
#sshfpoc 'poc delete \"FortiADC WAF\"'
#sshfpoc 'poc repo define "poc/ferry/FortiWeb-Docker-v0.2.2.fpoc"'
#sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.1.2.fpoc"'
#sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.2.fpoc"'
#sshfpoc 'poc delete "FortiWeb-Docker"'
#sshfpoc 'poc delete "FortiWeb-SME-MachineLearning"'
#sshfpoc 'poc delete "FAD-FWB-WCCP-v1.0"'
#echo "y" | sshfpoc 'poc delete "FortiWeb Advanced Solutions v2.7"'
#sshfpoc 'repo define "poc/FAD-FWB-WCCP-v1.0-SME.fpoc" refresh'
#sshfpoc 'repo define "poc/ADC+WAF_SME_v0.1.fpoc" refresh'
#sshfpoc 'repo define "poc/FADFWB-CM_SF-v0.3.13.fpoc" refresh'
#sshfpoc 'launch "FADFWB-CM_SF"'
#sshfpoc 'delete all'
#sshfpoc 'repo define "poc/FortiWeb-Advanced-Solutions-Workshop-v2.7.fpoc" refresh'
#sshfpoc 'repo define "poc/rvoong/FortiWeb-Basic-solution-workshop-v2.3.fpoc" refresh'
#sshfpoc 'repo define "poc/FortiWeb-Docker-v0.1.0.fpoc" refresh'

######################################
# Managing FortiPoC VM configuration
######################################
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
echo"";echo -n "---------------- End of actions on FortiPoC - ${ENDTIME}  ---------------------";echo ""
