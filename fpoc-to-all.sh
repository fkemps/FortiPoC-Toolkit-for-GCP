#! /bin/bash
#
# 2019110701 : Ferry Kemps - Modified [-options] to -show, -run
# 2019110801 : Ferry Kemps - Addess -address option for CLI IP-address input
# 2019110802 : Ferry Kemps - Short and long option specification
# 2019111101 : Ferry Kemps - Some clean-up and comments
# 2019112501 : Ferry Kemps - Updated --address description
# 2020052501 : Ferry Kemps - General clean up, added banner more examples
# 2020070901 : Ferry Kemps - added STARTDELAY to relax parallel starting
# 2022031801 : Ferry Kemps - Password cleanup
FPOCSCRIPTVERSION="2022031801"

###############################################################################################################################################
# This script is to manage running FortiPoCs by executing CLI commands on FortiPoC console.                                                   #
# Idea is to:                                                                                                                                 #
#   Step 1) upload your ssh-key and validate SSH access via pub-key                                                                           #
#   Step 2) lock admin account (set pwd). From that point onwards management via SSH-only per CLI. Attendees use guest/guest for FP access.   #
#                                                                                                                                             #
# See steps below and uncommand & run in that order.                                                                                          #
# Uncomment/add "sshfpoc" or "sshfpocparallel" to execute commands sequential on FPoCs or in parallel.                                        #
# Command need to be located inbetween "---- Start -----" and "----- End -----" section.                                                      #
# Use provided examples for guidance.                                                                                                         #
#i#############################################################################################################################################

# List of FortiPoC IP-addresses e.g. "1.1.1.1" or use "1.1.1.1 2.2.2.2 3.3.3.3" space delimited format for multiple FPs.
# Use this script embedded method in case you don't want to use -a / --address command line option
#
# Single-IP or FQDN
#IPADDRESS="a.b.c.d"

# Multiple-IP's or FQDN's
#IPADDRESS="x.x.x.x y.y.y.y z.z.z.z host.domain.ext"

# Global Parameters
USER="admin"
PWD="password"
export USER PWD
COUNT=1
STARTDELAY=5

#######################
# Functions           #
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
# Option handling     #
#######################
case $1 in
  -a | --address) echo "Using CLI provided IP-address(es)"
     IPADDRESS=$2;;
  -e | --execute) echo "Okay here we go......";;
  -r | --review)  echo "";echo "----------------- Executing commands on FortiPoCs --------------------------"
     grep "sshfpoc" $0 | egrep -v '^#|egrep|function'
     echo "----------------------------------------------------------------------------"
     exit;;

  *) echo '  __                       _                    _ _'
     echo ' / _|_ __   ___   ___     | |_ ___         __ _| | |'
     echo '| |_|  _ \ / _ \ / __|____| __/ _ \ _____ / _` | | |'
     echo '|  _| |_) | (_) | (_|_____| || (_) |_____| (_| | | |'
     echo '|_| | .__/ \___/ \___|     \__\___/       \__,_|_|_|'
     echo '    |_|'
     echo ""
     echo "(Version: ${FPOCSCRIPTVERSION})"
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
# FortiPoC management #
#######################
STARTTIME=`date`
clear;echo -n "---------------- Start of actions on FortiPoC - ${STARTTIME}  ---------------------"; echo ""
echo "Executing on targets ${IPADDRESS}"; echo ""
for HOST in ${IPADDRESS}; do
sleep ${STARTDELAY}
echo "======== FortiPoC on IP : ${HOST} ========= FPOC: ${COUNT}"

# Uncomment the "echo" rules for step 1, 2 and 3. Comment them again once done.
#############################################################################
# Step 1) Install SSH keys 2) Validate ssh access 3) Change admin password  #
#############################################################################
#echo "[*] Adding SSK-keys"; sshfpoc 'set ssh authorize keys "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNJYNMdL9o1Xt3ADg1DCOBhp8Vvr6eX8KGOK9tpqYH8Q6yW6Y1ARzDwqytg2zacRqwwZdpelEQ2vc9Kd4xsYA2Ds/OvUhwxJ1mPr5AVaqy6UxmkSU4fIQaIwkBgfaVxxntND8WRQVbjvkvlfoVBel93yz4jYcUDG0wsBNawuMS2BYHXDWb+w5RtEtkWf1cGfzHVSQSrhmk1uFFXMhFY95t9b1mMgroZqYkYaYb1sxmOxnQTQwC1J5Hf8LajXAMPV9br523mCXpJ5aeD+1T1706XM8EikT9JHDhgnqyTLMf8FAdaetT2fju2FZ9WnmHM2V3wQnC0t0QIuoYgEnZlQND fkemps@Ferrys-MacBook-Pro.local"'
#echo "[*] Validating access"; sshfpoc 'exit'
#echo "[*] Changing admin pwd"; sshfpoc 'set passwd YOURADMINPASSWORD'





# ------------------ put your FortiPoC CLI commands to execute below this line ---------------------
#
# FortiPoC: Title settings
#
#echo "[*] Setting GUI tile"; sshfpoc 'set gui title "Xperts Summit 2020 - FPOC#" '

# Remove admin pwd
# ----------------------
#echo "[*] Remove admin pwd"; sshfpoc 'unset passwd YOURPASSWORD'

# Removing SSH keys
# ----------------------
# echo "[*] Removing ssh-key"; sshfpoc 'unset ssh authorized keys 1'

# FortiPoC: set timezone
# ----------------------
# Obtain timezones with "get timezone"
#echo "[*] Setting timezone"; sshfpoc 'set timezone Europe/Amsterdam'
#echo "[*] Setting timezone"; sshfpoc 'set timezone Asia/Singapore'

# FortiPoC: Launch a PoC-definition
# ----------------------
#echo "[*] Launching PoC-definition"; sshfpocparallel 'poc launch "FortiProxy Workshop"'

# FortiPoC: Eject a PoC-definition
# ----------------------
#echo "[*] Ejecting PoC-definition"; sshfpocparallel 'poc eject'

# FortiPoC: Get FP task list
# ----------------------
#echo "[*] Tasklist "; sshfpoc 'get task list'

# FortiPoC: Purge files
# ----------------------
#echo "[*] Purge files "; sshfpoc 'execute purge files'

# FortiPoC: Get loaded poc-definitions
# ----------------------
#echo "[*] Populated POC-definitions"; sshfpoc 'poc list'

# FortiPoC: Prefetch all POC-definitions and documentation
# ----------------------
#echo "[*] Prefetching all POC-definitions"; sshfpoc "poc prefetch all"

#
# FortiPoC: Set Simple Menu
#
#echo "Enable simple menu"; sshfpoc 'set gui simple enable'

#
# FortiPoC: random example collection delete, sync repo, load poc-definitions
# ----------------------
#echo "[*] Synchronising repositories" ; sshfpoc 'repo sync'
#echo "[*] Synchronising repository gcp-fkemps"; sshfpoc 'repo sync gcp-fkemps'
#echo "[*] Delete POC-definition"; echo "y" | sshfpoc 'poc delete "FortiWeb Basic Solutions"' ; echo ""
#echo "[*] Delete POC-definition"; echo "y" | sshfpoc 'poc delete "FortiADC WAF"' ; echo ""
#echo "[*] Delete POC-definition"; echo "y" | sshfpoc 'poc delete "FortiWeb Advanced Solutions v2.7"' ; echo ""
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/ferry/FortiWeb-Docker-v0.2.2.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.1.2.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.2.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'repo define "poc/FAD-FWB-WCCP-v1.0-SME.fpoc" refresh'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/rgracioli/FAD-FWB-WCCP-v5.4.0.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define ""poc/FortiWeb-MachineLearning-v0.9.9.fpoc'
#echo "[*] Launching POC-definition"; sshfpoc 'launch "FADFWB-CM_SF"'

#-------------------------------------
# Some examples used for summit 2020
#-------------------------------------

# Monday - FPX Ultimate Playground
#echo "[*] Changing guest password to YOURPASSWORD"; sshfpoc 'set guest passwd YOURPASSWORD'
#echo "[*] Ejecting PoC-definition"; sshfpoc 'poc eject'
#echo "[*] Synchronise repositories"; sshfpoc 'repo sync'
#echo "[*] Removing all previous POC-definitions"; echo "y" | sshfpoc 'poc delete all'; echo ""
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/xpertsummit2020/FortiProxy-Ultimate-Playground-X.fpoc"'
#echo "[*] Prefetching all POC-definitions"; sshfpocparallel "poc prefetch all"

# Tuesday - FAD
#echo "[*] Changing guest password to YOURPASSWORD"; sshfpoc 'set guest passwd YOURPASSWORD'
#echo "[*] Ejecting PoC-definition"; sshfpoc 'poc eject'
#echo "[*] Synchronise repositories"; sshfpoc 'repo sync'
#echo "[*] Removing all previous POC-definitions"; echo "y" | sshfpoc 'poc delete all'; echo ""
#echo "[*] Removing previous Database POC-definition"; echo "y"| sshfpoc 'poc delete "FortiADC Database"'
#echo "[*] Removing previous Database POC-definition"; echo "y"| sshfpoc 'poc delete "FortiADC WAF"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/FortiADC-Database-v0.3.0.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/FortiADC-Database-v0.3.1.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/secops/FortiADC-Global-App-Delivery-5.4.1-Attendee.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/secops/FortiADC-DataCenter-v5.4.1.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/FortiADC-Cert-Verification-v0.2.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/rgracioli/FortiADC-WAF-v1.5.fpoc"'
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/FortiADC-WAF-v0.1.6.fpoc"'
#echo "[*] Prefetching all POC-definitions"; sshfpocparallel "poc prefetch all"

# Wednesday - FIS
#echo "[*] Changing guest password to YOURPASSWORD"; sshfpoc 'set guest passwd YOURPASSWORD'
#echo "[*] Ejecting PoC-definition"; sshfpoc 'poc eject'
#echo "[*] Synchronise repositories"; sshfpoc 'repo sync'
#echo "[*] Removing all previous POC-definitions"; echo "y" | sshfpoc 'poc delete all'; echo ""
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/xpertsummit2020/FortiIsolator-Workshop-Xperts.fpoc"'
#echo "[*] Prefetching all POC-definitions"; sshfpocparallel "poc prefetch all"
#echo "[*] Launching POC-definition"; sshfpocparallel 'poc launch "FortiIsolator Workshop Xperts"'

# Thursday - FWB
#echo "[*] Changing guest password to YOURPASSWORD"; sshfpoc 'set guest passwd YOURPASSWORD'
#echo "[*] Ejecting PoC-definition"; sshfpocparallel 'poc eject'
#echo "[*] Synchronise repositories"; sshfpoc 'repo sync'
#echo "[*] Removing all previous POC-definitions"; echo "y" | sshfpoc 'poc delete all'; echo ""
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/xpertsummit2020/FortiWeb-Machine-Learning-Xperts.fpoc"'
#echo "[*] Prefetching all POC-definitions"; sshfpoc "poc prefetch all"
#echo "[*] Launching POC-definition"; sshfpoc 'poc launch "FortiWeb Machine Learning Xperts"'
#echo "[*] Launching POC-definition"; sshfpocparallel 'poc launch "FortiWeb Machine Learning Xperts"'

# Friday - FPX
#echo "[*] Changing guest password to YOURPASSWORD"; sshfpoc 'set guest passwd YOURPASSWORD'
#echo "[*] Ejecting PoC-definition"; sshfpoc 'poc eject'
#echo "[*] Ejecting PoC-definition"; sshfpocparallel 'poc eject'
#echo "[*] Synchronise repositories"; sshfpoc 'repo sync'
#echo "[*] Removing all previous POC-definitions"; echo "y" | sshfpoc 'poc delete all'; echo ""
#echo "[*] Adding POC-definition"; sshfpoc 'poc repo define "poc/xpertsummit2020/FortiProxy-Workshop-Xperts.fpoc"'
#echo "[*] Prefetching all POC-definitions"; sshfpoc "poc prefetch all"
#echo "[*] Launching POC-definition"; sshfpocparallel 'poc launch "FortiProxy Workshop Xperts"'



######################################
# Managing FortiPoC VM configuration #
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
