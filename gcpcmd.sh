#! /bin/bash

# This script is to perform Google Cloud Platform (GCP) actions for creating, starting, stopping, deleting FortiPoC's
# 2018113001 Ferry Kemps, Initial release
# 2018120401 Ferry Kemps, added --zone argument to override default zone
# 2019011601 Ferry Kemps, added variables, conditional gcloud cmd executions
# 2019020401 Ferry Kemps, added simple menu enable/disable setting
# 2019031301 Ferry Kemps, added config file option
# 2019033001 Ferry Kemps, added gcp repo option to load images and poc-definitions
# 2019033002 Ferry Kemps, added sme as product to facilitate sme-event combos
# 2019050201 Ferry Kemps, increased amount of PoC-definitions to load
# 2019060301 Ferry Kemps, updated FPIMAGE to 1-5-49
# 2019062501 Ferry Kemps, added xa as product to facilitate NSE Xperts Academy events
# 2019070101 Ferry Kemps, increased poc definitions to 6
# 2019081401 Ferry Kemps, added test as product to facilitate temp installs
# 2019081501 Ferry Kemps, changed example config file name to be diff from gcpcmd command
# 2019083001 Ferry Kemps, expanded poc definitions to 8
# 2019100701 Ferry Kemps, added FPPREPEND to custom label instances names.
# 2019101001 Ferry Kemps, added config file check on action build
# 2019101101 Ferry Kemps, added listpubip option to retrieve pub IPs (concatenated for other script)
# 2019101802 Ferry Kemps, added FSW, FSA, appsec as a products/solutions
# 2019102301 Ferry Kemps, Updated the help info
# 2019110101 Ferry Kemps, Commented out simple menu option. Some screen output cleanup
# 2019110441 Ferry Kemps, Adding random sleep time to avoid GCP DB lock error
# 2019110501 Ferry Kemps, Little output corrections
# 2019110601 Ferry Kemps, Moved logfiles to logs directory
# 2019111101 Ferry Kemps, Added automatic defaults per ~/.fpoc/gcpcmd.conf
# 2019111102 Ferry Kemps, Expanded user defaults
# 2019111401 Ferry Kemps, Added add/remove IP-address to GCP ACL
# 2019111501 Ferry Kemps, Added instance clone function
# 2019111502 Ferry Kemps, Changed number generator, added comments
# 2019112201 Ferry Kemps, Fixed license server inquiry
# 2019112202 Ferry Kemps, Added conf dir creation and seq fix
# 2019112501 Ferry Kemps, Clarified GCP billing project ID
# 2019112502 Ferry Kemps, Changed GCP instance labling to list owner
# 2019112503 Ferry Kemps, Changed moment of conf and log dir creation
# 2019112601 Ferry Kemps, Added global list based on owner label
# 2019112801 Ferry Kemps, Empty license server fix
# 2019112901 Ferry Kemps, Cloning now supports labeling
# 2019120501 Ferry Kemps, Added <custom-name> for product/solution, arguments sorted alphabetic
# 2020011001 Ferry Kemps, Added [IP-address] option to --ip-address-add|remove and --ip-address-list
# 2020012701 Ferry Kemps, Use fortipoc-1.7.7 by default, add disclaimer, declare PoC-definitions, introduced group-management
# 2020012703 Ferry Kemps, Corrected CONFFILE check
# 2020012704 Ferry Kemps, Code clean-up, group management
# 2020012705 Ferry Kemps, Added --initials option for group management
# 2020013101 Ferry Kemps, Fixed -d option, added group function for cloning
# 2020022001 Ferry Kemps, Cleared GCPREPO example
# 2020052501 Ferry Kemps, Modified banner
# 2020060201 Ferry Kemps, Added option to change machine-type
# 2020072201 Ferry Kemps, Improved WARNING message on missing software packages.
# 2020081301 Ferry Kemps, Replaced gcloud beta command
# 2020081302 Ferry Kemps, Changed GCP license server input request
# 2020082601 Ferry Kemps, Pre-populated ProjectId and Service Account preferences
# 2020082701 Ferry Kemps, Added -p|--preferences option, renamed -c|--config file to -b|--build-file, improved preference questions.
# 2020110301 Ferry Kemps, Changed standard machine-types to 5 options, added SSH-key option, choice for snapshot on cloning
# 2020110401 Ferry Kemps, Added online new version checking
# 2021040601 Ferry Kemps, Rewrite of cloning from snapshot to machine-image to avoid clone limits
# 2021050401 Ferry Kemps, Added fortipoc-deny-default tag to close default GCP open ports
# 2021050501 Ferry Kemps, Little typo fixes
# 2021050502 Ferry Kemps, Fixed SSHKEY check, added dig command tool check
# 2021061601 Ferry Kemps, Sanity check on multiple retrieved Service Accounts.
# 2021071501 Ferry Kemps, Added automatic firewall-rules creation, updated instance tagging and option to toggle tags for controlling access.
# 2021071501 Ferry Kemps, Expanded global access listing, by default global access disabled on instance create/clone
# 2021071901 Ferry Kemps, Added globallist action to list ACL per user selection
# 2021071902 Ferry Kemps, Added -z|--zone override option
# 2021082401 Ferry Kemps, Fixed global access list reversed issue
# 2021090701 Ferry Kemps, Code restructed, improved formatting, better Global Access messaging, firewall-rule fix on build
# 2021091401 Ferry Kemps, Added update command
# 2021111701 Ferry Kemps, Renamed global/globallist to globalaccess/globalaccesslist
# 2022011001 Ferry Kemps, Textual updates on help page
# 2022080401 Ferry Kemps, Changed parallel option -j0 to supress warning
# 2022080501 Ferry Kemps, Added option to move instances to other zone
# 2022110401 Ferry Kemps, Updated help for --initials option to override 
# 2023070301 Ferry Kemps, Added gcloud beta instance rename optopn
# 2023071001 Ferry Kemps, Remove debug and text correction on rename option
# 2023113001 Ferry Kemps, Added labellist action to list labels, add/remove labels, updated instance fortipoc label
# 2023121201 Ferry Kemps, Added label replace option
# 2024053001 Ferry Kemps, Added -lr | --list-running option to list RUNNING instances
# 2024072901 Ferry Kemps, Added creation of "default" VPC and Networks if missing, optimized the gcloud validation delay
# 2024080101 Ferry Kemps, Major update to support multi-project function
# 2024080102 Ferry Kemps, Updated onboarding project selection, clone max text
# 2024080103 Ferry Kemps, Corrected labelmodify bug with numbering
# 2024080104 Ferry Kemps, Added note for Compute Engine API, added Type name override option 
# 2024080105 Ferry Kemps, Added network tag add/remove/replace with action accesslist, accessmodify. Removed globalaccesslist action
# 2024080201 Ferry Kemps, Added quit option during project sign-up to exit
# 2024080202 Ferry Kemps, Added machinetype e2-medium for allways-on small instances
# 2024080501 Ferry Kemps, Corrected global command creation
# 2024080601 Ferry Kemps, Updated OWNER label definition, updated the fpoc-example.conf directory
# 2024080602 Ferry Kemps, Improved the upload image feature
# 2024080701 Ferry Kemps, Removed obsolete fortipoc-http-https-redir network tag, fixed VPN/FIREWALLRULE in preference file
# 2024081401 Ferry Kemps, Shell code syntax checked and corrected
GCPCMDVERSION="2024081401"

# Disclaimer: This tool comes without warranty of any kind.
#             Use it at your own risk. We assume no liability for the accuracy, group-management
#             correctness, completeness, or usefulness of any information
#             provided nor for any sort of damages using this tool may cause.

# default zones where to deploy per region. You can adjust to deploy closest to your location
ASIA="asia-southeast1-b"
EUROPE="europe-west4-a"
AMERICA="us-central1-c"

# ------------------------------------------------
# ------ No editing needed beyond this point -----
# ------------------------------------------------

# Let's create uniq logfiles with date-time stamp
PARALLELOPT="--joblog logs/logfile-$(date +%Y%m%d%H%M%S) -j 100 "
# Firewall-rules for instance tagging
WORKSHOPVPC="default"
WORKSHOPSOURCENETWORKS="workshop-source-networks"
WORKSHOPSOURCEANY="workshop-source-any"
DSTTCPPORTS="tcp:22,tcp:80,tcp:443,tcp:8000,tcp:8080,tcp:8888,tcp:10000-20000,tcp:20808,tcp:20909,tcp:22222"
DSTUDPPORTS="udp:53,udp:514,udp:1812,udp:1813"
TYPE="fpoc"
# Clear POC-definitions
POCDEFINITION1=""
POCDEFINITION2=""
POCDEFINITION3=""
POCDEFINITION4=""
POCDEFINITION5=""
POCDEFINITION6=""
POCDEFINITION7=""
POCDEFINITION8=""

# Color code definitions
BLACK='\033[0;30m'       ; DARKGRAY='\033[1;30m'
RED='\033[0;31m'         ; LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'       ; LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'      ; export YELLOW='\033[1;33m'
BLUE='\033[0;34m'        ; LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'      ; LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'        ; LIGHTCYAN='\033[1;36m'
LIGHTGRAY='\033[0;37m'   ; WHITE='\033[1;37m'
REDREVERSED='\033[0;41m' ; GREENREVERSED='\033[0;42m'
REDREVERSEDNEW='\033[1;41m' ; GREENREVERSEDNEW='\033[1;42m'
GREENNEW='\033[1;32m'
NOCOLOR='\033[0m'

###############################
#   Functions
###############################
function checkdefaultnetwork() {
   if [ "${VPC}" != "validated" ]; then
      if (! gcloud compute networks describe ${WORKSHOPVPC} --format=none > /dev/null 2>&1); then
         echo "Default VPC networks not found, creating it"
         gcloud compute networks create ${WORKSHOPVPC} \
            --description="Default VPC network for FortiPoC" \
            --mtu=1460
         # Add VPC check to personal preferences file
      fi
      sed -i '' "s/GCPCMD_VPC\[${DEFAULTPROJECT}\].*/GCPCMD_VPC\[${DEFAULTPROJECT}\]=\"validated\"/" "${GCPCMDCONF}"
   fi
}

function checkfirewallrules() {
   #check if firewall-rules exist else create them
   if [ "${FIREWALLRULES}" != "validated" ]; then
      if (! gcloud compute firewall-rules describe ${WORKSHOPSOURCENETWORKS} --format=none >/dev/null 2>&1); then
         echo "Firewall-rule ${WORKSHOPSOURCENETWORKS} not found, creating it"
         gcloud compute firewall-rules create ${WORKSHOPSOURCENETWORKS} \
            --allow=${DSTTCPPORTS},${DSTUDPPORTS} \
            --description="Allow access from temporary workshop networks" \
            --direction=INGRESS \
            --priority=300 \
            --source-ranges=10.10.10.10 \
            --target-tags=${WORKSHOPSOURCENETWORKS} \
            --no-user-output-enabled
      fi
      if (! gcloud compute firewall-rules describe ${WORKSHOPSOURCEANY} --format=none >/dev/null 2>&1); then
         echo "Firewall-rule ${WORKSHOPSOURCEANY} not found, creating it (disabled by default)"
         gcloud compute firewall-rules create ${WORKSHOPSOURCEANY} \
            --allow=${DSTTCPPORTS},${DSTUDPPORTS} \
            --description="Allow access from temporary workshop networks" \
            --direction=INGRESS \
            --priority=300 \
            --source-ranges=0.0.0.0/0 \
            --target-tags=${WORKSHOPSOURCEANY} \
            --disabled \
            --no-user-output-enabled
         # Add Firewallrules check to personal preferences file
      fi
      #echo "GCPCMD_FIREWALLRULES[${DEFAULTPROJECT}]=\"validated\"" >> ${GCPCMDCONF}
      sed -i '' "s/GCPCMD_FIREWALLRULES\[${DEFAULTPROJECT}\].*/GCPCMD_FIREWALLRULES[${DEFAULTPROJECT}]=\"validated\"/" "${GCPCMDCONF}"
   fi
}

function togglefirewallruleany() {
   if [ "${1}" = "disable" ]; then
      gcloud compute firewall-rules update ${WORKSHOPSOURCEANY} --disabled --no-user-output-enabled
      echo "Global access to instances => Disabled"
   elif [ "${1}" = "enable" ]; then
      gcloud compute firewall-rules update ${WORKSHOPSOURCEANY} --no-disabled --no-user-output-enabled
      echo "Global access to instances => Enabled"
   elif [ "${1}" = "status" ]; then
      GLOBALACCESSSTATUS=$(gcloud compute firewall-rules describe ${WORKSHOPSOURCEANY} --format=json | jq -r '.disabled')
      [ "${GLOBALACCESSSTATUS}" = "false" ] && GLOBALACCESSSTATUS="Enabled" || GLOBALACCESSSTATUS="Disabled"
      echo "Global access status: ${GLOBALACCESSSTATUS}"
   else
      echo "Unknown global access request"
      exit
   fi
   echo ""
}

function instancefirewallrules() {
   echo ""
   echo "Instancename     : firewall-rules attached"
   echo "---------------------------------------------------------------------------------"
   # Get all instance-names from default zone
   INSTANCEARRAY=($(gcloud compute instances list --filter="(labels.owner:${OWNER} OR labels.group:${FPGROUP})" | awk '{ print $1"_"$2 }' | grep -v NAME))
   for FPINSTANCE in ${INSTANCEARRAY[*]}; do
      FPINSTANCENAME="$(echo "${FPINSTANCE}" | awk -F "_" '{ print $1 }')"
      FPINSTANCEZONE="$(echo "${FPINSTANCE}" | awk -F "_" '{ print $2 }')"
      TAGS=($(gcloud compute instances describe "${FPINSTANCENAME}" --zone="${FPINSTANCEZONE}" --format=json | jq -r '.tags .items[]'))
      echo "${FPINSTANCENAME} : ${TAGS[*]}"
   done
}

function instancelabels() {
   echo ""
   echo "Instancename     : labels"
   echo "---------------------------------------------------------------------------------"
   # Get all instance-names from default zone
   INSTANCEARRAY=($(gcloud compute instances list --filter="(labels.owner:${OWNER} OR labels.group:${FPGROUP})" | awk '{ print $1"_"$2 }' | grep -v NAME))
   for FPINSTANCE in ${INSTANCEARRAY[*]}; do
      FPINSTANCENAME="$(echo "${FPINSTANCE}" | awk -F "_" '{ print $1 }')"
      FPINSTANCEZONE="$(echo "${FPINSTANCE}" | awk -F "_" '{ print $2 }')"
      LABELS=($(gcloud compute instances describe "${FPINSTANCENAME}" --zone="${FPINSTANCEZONE}" --format=json | jq -c '.labels' | sed 's/{//;s/}//;s/:/=/g;s/"//g'))
      echo "${FPINSTANCENAME} : ${LABELS[*]}"
   done
}

function displayheader() {
   clear
   echo "---------------------------------------------------------------------"
   echo "             FortiPoC Toolkit for Google Cloud Platform             "
   echo "---------------------------------------------------------------------"
   echo ""
}

# Function to display personal config preferences
function displaypreferences() {
   local CONFFILE=$1
   echo "Your personal configuration preferences"
   echo ""
   cat "${CONFFILE}"
}

# Function to validate IP-address format
function validateIP() {
   local ip=$1
   local stat=1
   if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      OIFS=$IFS
      IFS='.'
      ip=($ip)
      IFS=$OIFS
      [[ ${ip[0]} -le 239 && ${ip[1]} -le 255 && \
      ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
      stat=$?
   fi
   return $stat
}

# Function to add/remove workshop location Public IP-address to GCP ACL to allow access
function gcpaclupdate() {
   CMD=$1
   PUBLICIP=$2
   if [ -z "${PUBLICIP}" ]; then
      # Obtain current public IP-address
      PUBLICIP=$(dig TXT -4 +short o-o.myaddr.l.google.com @ns1.google.com | sed -e 's/"//g')
   fi
   validateIP "${PUBLICIP}"
   [ ! $? -eq 0 ] && (
      echo "Public IP not retreavable or not valid"
      exit
   )
   if [ "${CMD}" == add ]; then
      echo "Adding public-ip ${PUBLICIP} to GCP ACL to allow access from this location"
      while read line; do
         if [ -z ${SOURCERANGE} ]; then
            SOURCERANGE="$line"
         else
            SOURCERANGE="${SOURCERANGE},$line"
         fi
      done < <(gcloud compute firewall-rules list --filter="name=${WORKSHOPSOURCENETWORKS}" --format=json | jq -r '.[] .sourceRanges[]')
      SOURCERANGE="${SOURCERANGE},${PUBLICIP}"
      gcloud compute firewall-rules update ${WORKSHOPSOURCENETWORKS} --source-ranges=${SOURCERANGE}
      echo "Current GCP ACL list"
      gcloud compute firewall-rules list --filter="name=${WORKSHOPSOURCENETWORKS}" --format=json | jq -r '.[] .sourceRanges[]'
      echo ""
   elif [ "${CMD}" == "remove" ]; then
      echo "Removing public-ip ${PUBLICIP} to GCP ACL to remove access from this location"
      while read line; do
         if [ -z ${SOURCERANGE} ]; then
            [ ! $line == ${PUBLICIP} ] && SOURCERANGE="$line"
         else
            [ ! $line == ${PUBLICIP} ] && SOURCERANGE="${SOURCERANGE},$line"
         fi
      done < <(gcloud compute firewall-rules list --filter="name=${WORKSHOPSOURCENETWORKS}" --format=json | jq -r '.[] .sourceRanges[]')
      gcloud compute firewall-rules update ${WORKSHOPSOURCENETWORKS} --source-ranges=${SOURCERANGE}
      echo "Current GCP ACL list"
      gcloud compute firewall-rules list --filter="name=${WORKSHOPSOURCENETWORKS}" --format=json | jq -r '.[] .sourceRanges[]'
      echo ""
   else
      echo "Listing public-ip addresses on GCP ACL"
      gcloud compute firewall-rules list --filter="name=${WORKSHOPSOURCENETWORKS}" --format=json | jq -r '.[] .sourceRanges[]'
      echo ""
   fi
}

# Function to list all globalaccess instances
function gcplistglobal {
   OWNER=$1
   FPGROUP=$2
   WILDCARD=$3
   if [ -z ${FPGROUP} ]; then
      gcloud compute instances list --filter="labels.owner:${OWNER}"
   else
      if [ "${WILDCARD}" == "all" ]; then
        gcloud compute instances list
      else
        gcloud compute instances list --filter="(labels.owner:${OWNER} OR labels.group:${FPGROUP})"
      fi
   fi
}

# Function to list all global RUNNING instances
function gcplistrunning {
   OWNER=$1
   FPGROUP=$2
   STATUS="RUNNING"
   if [ -z ${FPGROUP} ]; then
      gcloud compute instances list --filter="labels.owner:${OWNER} AND status:${STATUS}"
   else
      gcloud compute instances list --filter="(labels.owner:${OWNER} OR labels.group:${FPGROUP}) AND status:${STATUS}"
   fi
}

# Function to build a FortiPoC instance on GCP
function gcpbuild {

   if [ "${CONFIGFILE}" == "" ]; then
      echo "Build file missing. Use -b option to specify or to generate fpoc-example.conf file"
      exit
   fi

   RANDOMSLEEP=$((($RANDOM % 10) + 1))s
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   FPTITLE=$4
   INSTANCE=$5
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"

   echo "==> Sleeping ${RANDOMSLEEP} seconds to avoid GCP DB locking"
   sleep ${RANDOMSLEEP}
   echo "==> Creating instance ${INSTANCENAME}"
   gcloud compute \
      instances create ${INSTANCENAME} \
      --project=${GCPPROJECT} \
      --service-account=${GCPSERVICEACCOUNT} \
      --verbosity=info \
      --zone=${ZONE} \
      --machine-type=${MACHINETYPE} \
      --subnet=default --network-tier=PREMIUM \
      --maintenance-policy=MIGRATE \
      --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
      --min-cpu-platform=Intel\ Broadwell --tags=fortipoc-deny-default,${WORKSHOPSOURCENETWORKS} \
      --image=${FPIMAGE} \
      --image-project=${GCPPROJECT} \
      --boot-disk-size=350GB \
      --boot-disk-type=pd-standard \
      --boot-disk-device-name=${INSTANCENAME} \
      --labels=${LABELS}

   # Give Google 60 seconds to start the instance
   echo ""
   echo "==> Sleeping 90 seconds to allow FortiPoC booting up"
   sleep 90
   INSTANCEIP=$(gcloud compute instances describe ${INSTANCENAME} --zone=${ZONE} | grep natIP | awk '{ print $2 }')
   echo ${INSTANCENAME} "=" ${INSTANCEIP}
   curl -k -q --retry 1 --connect-timeout 10 https://${INSTANCEIP}/ && echo "FortiPoC ${INSTANCENAME} on ${INSTANCEIP} reachable"
   [ $? != 0 ] && echo "==> Something went wrong. The new instance is not reachable"

   # Now configure, load, prefetch and start PoC-definition
   [ "${FPTRAILKEY}" != "" ] && (
      echo "==> Registering FortiPoC"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "reg trial ${FPTRAILKEY}"
   )
   [ "${FPTITLE}" != "" ] && (
      echo "==> Setting title"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set gui title \"${FPTITLE}\""
   )
   gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'set guest passwd guest'
   [ "${GCPREPO}" != "" ] && (
      echo "==> Adding repository"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "repo add gcp-${GCPREPO} https://gcp.repository.fortipoc.com/~#{GCPREPO}/ --unsigned"
   )
   [ ! -z ${LICENSESERVER} ] && (
      echo "==> Setting licenseserver"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set license https://${LICENSESERVER}/"
   )
   [ ! -z ${POCDEFINITION1} ] && (
      echo "==> Loading poc-definition 1"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION1}\" refresh"
   )
   [ ! -z ${POCDEFINITION2} ] && (
      echo "==> Loading poc-definition 2"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION2}\" refresh"
   )
   [ ! -z ${POCDEFINITION3} ] && (
      echo "==> Loading poc-definition 3"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION3}\" refresh"
   )
   [ ! -z ${POCDEFINITION4} ] && (
      echo "==> Loading poc-definition 4"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION4}\" refresh"
   )
   [ ! -z ${POCDEFINITION5} ] && (
      echo "==> Loading poc-definition 5"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION5}\" refresh"
   )
   [ ! -z ${POCDEFINITION6} ] && (
      echo "==> Loading poc-definition 6"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION6}\" refresh"
   )
   [ ! -z ${POCDEFINITION7} ] && (
      echo "==> Loading poc-definition 7"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION7}\" refresh"
   )
   [ ! -z ${POCDEFINITION8} ] && (
      echo "==> Loading poc-definition 8"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION8}\" refresh"
   )
   echo "==> Prefetching all images and documentation"
   gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'poc prefetch all'
   [ "${POCLAUNCH}" != "" ] && (
      echo "==> Launching poc-definition"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc launch \"${POCLAUNCH}\""
   )
   [ "${SSHKEYPERSONAL}" != "" ] && (
      echo "==> Adding personal SSH key"
      gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set ssh authorized keys \"${SSHKEYPERSONAL}\""
   )
   #  [ "${FPSIMPLEMENU}" != "" ] && (echo "==> Setting GUI-mode to simple"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set gui simple ${FPSIMPLEMENU}")
   echo "==> End of Build phase <=="
   echo ""
}

# Function to clone a FortiPoC instance on GCP
function gcpclone {
   RANDOMSLEEP=$((($RANDOM % 10) + 1))s
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   FPNUMBERTOCLONE=$4
   INSTANCE=$5
   CLONESOURCE="${TYPE}-${FPPREPEND}-${PRODUCT}-${FPNUMBERTOCLONE}"
   CLONEMACHINEIMAGE="${TYPE}-${FPPREPEND}-${PRODUCT}"
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"

   echo "==> Sleeping ${RANDOMSLEEP} seconds to avoid GCP DB locking"
   sleep ${RANDOMSLEEP}
   echo "==> Create instance ${INSTANCENAME}"
   #  gcloud compute instances create ${INSTANCENAME} \
   #  --project=${GCPPROJECT} \
   #  --service-account=${GCPSERVICEACCOUNT} \
   #  --verbosity=info \
   #  --zone=${ZONE} \
   #  --machine-type=n1-standard-4 \
   #  --subnet=default --network-tier=PREMIUM \
   #  --maintenance-policy=MIGRATE \
   #  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
   #  --min-cpu-platform=Intel\ Broadwell \
   #  --tags=${WORKSHOPSOURCENETWORKS} \
   #  --disk "name=${INSTANCENAME},device-name=${INSTANCENAME},mode=rw,boot=yes,auto-delete=yes" \
   #  --labels=${LABELS}
   gcloud beta compute instances create ${INSTANCENAME} \
      --project=${GCPPROJECT} \
      --zone=${ZONE} \
      --source-machine-image ${CLONEMACHINEIMAGE}
}

# Function to start FortiPoC instance
function gcpstart {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   INSTANCE=$4
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   echo "==> Starting instance ${INSTANCENAME}"
   gcloud compute instances start ${INSTANCENAME} --zone=${ZONE}
}

# Function to stop FortiPoC instance
function gcpstop {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   INSTANCE=$4
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   echo "==> Stopping instance ${INSTANCENAME}"
   #  gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'poc eject' # not working if admin pwd is set
   gcloud compute instances stop ${INSTANCENAME} --zone=${ZONE}
}

# Function to delete FortiPoC instance
function gcpdelete {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   INSTANCE=$4
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   echo "==> Deleting instance ${INSTANCENAME}"
   echo yes | gcloud compute instances delete ${INSTANCENAME} --zone=${ZONE}
}

# Function to change FortiPoC instance machinetype
function gcpmachinetype {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   MACHINETYPE=$4
   INSTANCE=$5
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   echo "==> Changing machine-type of ${INSTANCENAME}"
   gcloud compute instances set-machine-type ${INSTANCENAME} --machine-type=${MACHINETYPE} --zone=${ZONE}
}

# Function to move FortiPoC instance to other zone
function gcpmove {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   DESTINATIONZONE=$4
   INSTANCE=$5
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   echo "==> Move instance ${INSTANCENAME} from zone ${ZONE} to ${DESTINATIONZONE}"
   #gcloud compute instances move INSTANCE_NAME --destination-zone=DESTINATION_ZONE [--async] [--zone=ZONE] [GCLOUD_WIDE_FLAG …]
   gcloud compute instances move ${INSTANCENAME} --zone=${ZONE} --destination-zone=${DESTINATIONZONE}
}

# Function to rename FortiPoC instance
function gcprename {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   NEWPRODUCT=$4
   INSTANCE=$5
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   NEWINSTANCENAME="${TYPE}-${FPPREPEND}-${NEWPRODUCT}-${INSTANCE}"
   echo "==> Renaming instance ${INSTANCENAME} to ${NEWINSTANCENAME}"
   gcloud beta compute instances set-name ${INSTANCENAME} --new-name=${NEWINSTANCENAME} --zone=${ZONE}
}

# Function to change FortiPoC instance firewall-rules
function gcpglobalaccess {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   GLOBALACCESS=$4
   INSTANCE=$5
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   if [ ${GLOBALACCESS} = "enable" ]; then
      echo "==> Enabling global access firewall-rule of ${INSTANCENAME}"
      gcloud compute instances add-tags ${INSTANCENAME} --tags=${WORKSHOPSOURCEANY} --zone=${ZONE} --no-user-output-enabled
   else
      echo "==> Disabling global access firewall-rule of ${INSTANCENAME}"
      gcloud compute instances remove-tags ${INSTANCENAME} --tags=${WORKSHOPSOURCEANY} --zone=${ZONE} --no-user-output-enabled
   fi
}

# Function to add/remove/replace FortiPoC instance labels
function gcplabelmodify {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   LABELACTION=$4
   LABEL=$5
   NEWLABEL=$6
   INSTANCE=$7
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   if [ ${LABELACTION} = "add" ]; then
      echo "==> Adding label ${LABEL} to instance ${INSTANCENAME}"
      gcloud compute instances add-labels ${INSTANCENAME} --labels=${LABEL} --zone=${ZONE} --no-user-output-enabled
   elif [ ${LABELACTION} = "remove" ]; then
      echo "==> Removing label ${LABEL} from instance ${INSTANCENAME}"
      gcloud compute instances remove-labels ${INSTANCENAME} --labels=${LABEL} --zone=${ZONE} --no-user-output-enabled
   else
      echo "==> Replacibg label ${LABEL} with ${NEWLABEL} on instance ${INSTANCENAME}"
      gcloud compute instances remove-labels ${INSTANCENAME} --labels=${LABEL} --zone=${ZONE} --no-user-output-enabled
      gcloud compute instances add-labels ${INSTANCENAME} --labels=${NEWLABEL} --zone=${ZONE} --no-user-output-enabled
   fi
}

# Function to add/remove/replace FortiPoC instance network tags
function gcpaccessmodify {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   TAGACTION=$4
   TAG=$5
   NEWTAG=$6
   INSTANCE=$7
   INSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
   if [ ${TAGACTION} = "add" ]; then
      echo "==> Adding network tag ${TAG} to instance ${INSTANCENAME}"
      gcloud compute instances add-tags ${INSTANCENAME} --tags=${TAG} --zone=${ZONE} --no-user-output-enabled
   elif [ ${TAGACTION} = "remove" ]; then
      echo "==> Removing network tag ${TAG} from instance ${INSTANCENAME}"
      gcloud compute instances remove-tags ${INSTANCENAME} --tags=${TAG} --zone=${ZONE} --no-user-output-enabled
   else
      echo "==> Replacibg network tag ${TAG} with ${NEWTAG} on instance ${INSTANCENAME}"
      gcloud compute instances remove-tags ${INSTANCENAME} --tags=${TAG} --zone=${ZONE} --no-user-output-enabled
      gcloud compute instances add-tags ${INSTANCENAME} --tags=${NEWTAG} --zone=${ZONE} --no-user-output-enabled
   fi
}

# Function to list FortiPoC instance firewall-rules
function gcpaccesslist {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   INSTANCESTART=$(expr $4)
   INSTANCEEND=$(expr $5)
   echo "Listing network tags (firewall-rules) of selected instances"
   echo ""
   echo "Instancename     : network tags"
   echo "---------------------------------------------------------------------------------"
   for ((COUNT = $INSTANCESTART; $COUNT <= $INSTANCEEND; COUNT++)); do
      INSTANCENUMBER=$(printf "%03d" $COUNT)
      FPINSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCENUMBER}"
      #gcloud compute instances describe ${INSTANCENAME} --zone=${ZONE} | jq -r '.tags .items[]'
      TAGS=($(gcloud compute instances describe ${FPINSTANCENAME} --zone=${ZONE} --format=json | jq -r '.tags .items[]'))
      echo "${FPINSTANCENAME} : ${TAGS[*]}"
   done
}

# Function to list FortiPoC instance labels
function labellist {
   FPPREPEND=$1
   ZONE=$2
   PRODUCT=$3
   INSTANCESTART=$(expr $4)
   INSTANCEEND=$(expr $5)
   echo "Listing labels of selected instances"
   echo ""
   echo "Instancename     : labels"
   echo "---------------------------------------------------------------------------------"
   for ((COUNT = $INSTANCESTART; $COUNT <= $INSTANCEEND; COUNT++)); do
      INSTANCENUMBER=$(printf "%03d" $COUNT)
      FPINSTANCENAME="${TYPE}-${FPPREPEND}-${PRODUCT}-${INSTANCENUMBER}"
      #gcloud compute instances describe ${INSTANCENAME} --zone=${ZONE} | jq -r '.tags .items[]'
      LABELS=($(gcloud compute instances describe ${FPINSTANCENAME} --zone=${ZONE} --format=json | jq -c '.labels'| sed 's/{//;s/}//;s/:/=/g;s/"//g'))
      echo "${FPINSTANCENAME} : ${LABELS[*]}"
   done
}

# Function to display the help
function displayhelp {
   echo ' _____          _   _ ____              _____           _ _    _ _      __               ____  ____ ____'
   echo '|  ___|__  _ __| |_(_)  _ \ ___   ___  |_   _|__   ___ | | | _(_) |_   / _| ___  _ __   / ___|/ ___|  _ \'
   echo '| |_ / _ \|  __| __| | |_) / _ \ / __|   | |/ _ \ / _ \| | |/ / | __| | |_ / _ \|  __| | |  _| |   | |_) |'
   echo '|  _| (_) | |  | |_| |  __/ (_) | (__    | | (_) | (_) | |   <| | |_  |  _| (_) | |    | |_| | |___|  __/'
   echo '|_|  \___/|_|   \__|_|_|   \___/ \___|   |_|\___/ \___/|_|_|\_\_|\__| |_|  \___/|_|     \____|\____|_|'
   echo "(Version: ${GCPCMDVERSION})"
   echo ""
   echo "Selected project : ${GCPPROJECT}"
   echo "Default deployment region: ${ZONE}"
   echo "Personal instance identification: ${FPPREPEND}"
   echo "Default product: ${PRODUCT}"
   echo ""
   echo "Usage: $0 [OPTIONS] [ARGUMENTS]"
   echo "       $0 [OPTIONS] <region> <product> <action>"
   echo "       $0 [OPTIONS] <-b configfile> <region> <product> build"
   echo "       $0 [OPTIONS] [region] [product] list"
   echo "       $0 [OPTIONS] [region] [product] listpubip"
   echo "OPTIONS:"
   echo "        -b    --build-file                     File for building instances. Leave blank to generate example"
   echo "        -d    --delete-config                  Delete default user config settings"
   echo "        -g    --group                          Group name for shared instances"
   echo "        -ge   --global-access-enable           Enable glocal access to instances"
   echo "        -gd   --global-access-disable          Disable glocal access to instances"
   echo "        -gl   --global-access-list             List global access to instances (network tags)"
   echo "        -gs   --global-access-status           Status glocal access to instances"
   echo "        -i    --initials <initials>            Override intials on instance name for group management"
   echo "        -ia   --ip-address-add [IP-address]    Add current public IP-address to GCP ACL"
   echo "        -ir   --ip-address-remove [IP-address] Remove current public IP-address from GCP ACL"
   echo "        -il   --ip-address-list                List current public IP-address on GCP ACL"
   echo "        -lg   --list-global                    List all your instances globally"
   echo "        -ll   --list-labels                    List all your instances and labels"
   echo "        -lr   --list-running                   List all your instances in RUNNING state"
   echo "        -p    --preferences                    Show personal config preferences"
   echo "        -pa   --project-add                    Add GCP project to preferences"
   echo "        -ps   --project-select                 Select project on GCP"
   echo "        -t    --type                           Override default type name (fpoc)"
   echo "        -ui   --upload-image                   Upload image to build an instance"
   echo "        -z    --zone                           Override default region zone"
   echo "ARGUMENTS:"
   echo "       region  : america, asia, europe"
   echo "       product : appsec, fad, fpx, fsa, fsw, fwb, sme, test, xa or <custom-name>"
   echo "       action  : accesslist, accessmodify, build*, clone, delete, globalaccess, labellist, labelmodify"
   echo "                 list, listpubip, machinetype, move, rename, start, stop"
   echo ""
   echo "                *action build needs -b <conf/configfile>. Use ./gcpcmd.sh -b to generate fpoc-example.conf file"
   echo ""
   [ "${NEWVERSION}" = "true" ] && echo "***** Newer version ${ONLINEVERSION} is available online on GitHub (use 'git pull' to update) *****"
   echo ""
}

# Function to select project on GCP from multi-project
function projectselect {
   echo ""
   echo "--------------------------------------------------------------------------"
   echo " Current project    : ${GCPCMD_PROJECT[${DEFAULTPROJECT}]}"
   echo " Number of projects : ${#GCPCMD_PROJECT[@]}"
   echo " All projects       : ${GCPCMD_PROJECT[*]}"
   echo "--------------------------------------------------------------------------"
   echo ""
   for ((i=1;i<=${#GCPCMD_PROJECT[@]};i++))
   do
     echo "  ${i}) : ${GCPCMD_PROJECT[${i}]}"
   done
   echo ""
   read -p " Select your GCP project : " SELECTEDPROJECT
   if [[ ${SELECTEDPROJECT} -lt 1 ]] || [[ ${SELECTEDPROJECT} -gt ${#GCPCMD_PROJECT[@]} ]]
   then
     echo""; echo " [ERROR] Invalid project number selected"
     exit 1
   else
     echo " Project \"${GCPCMD_PROJECT[${SELECTEDPROJECT}]}\" selected and made permanent"
     sed -i '' "s/DEFAULTPROJECT.*/DEFAULTPROJECT=\"${SELECTEDPROJECT}\"/" ${GCPCMDCONF}
     echo " Switching GCP-SDK to new selected project"
     gcloud config set project ${GCPCMD_PROJECT[${SELECTEDPROJECT}]}
   fi
}

# Function to upload a tar.gz file into GCP as image
function gcpuploadimage {
   echo " This option allows you to upload a tar.gz file as an image"
   read -p " What is the image filename (full path)? : " IMAGEFILENAME
   IMAGEFILE=$(basename ${IMAGEFILENAME})
   if [[ ! ${IMAGEFILE} =~ "tar.gz" ]]; then
     echo " Filename is not ending in tar.gz"
     exit
   fi
   read -p " Provide image filename for GCP (to build an instance)  : " IMAGENAME
   echo ""
   echo " Copying ${IMAGEFILE} to you bucket gs://images-${OWNER}/"
   gsutil ls gs://images-${OWNER} > /dev/null 2>&1
   if [ ! "$?" = "0" ]; then
     gcloud storage buckets create gs://images-${OWNER} --project=${GCPPROJECT} --location=$(echo ${ZONE}|awk -F "-" '{ print $1"-"$2}')
   fi
   gsutil cp ${IMAGEFILENAME} gs://images-${OWNER}/${IMAGEFILE}
   if [ "$?" = "0" ]; then 
      echo ""
      echo " Building your image file ${IMAGENAME}"
      gcloud compute images create ${IMAGENAME} \
       --project=${GCPPROJECT} \
       --source-uri gs://images-${OWNER}/${IMAGEFILE} \
       --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx" \
       --family fortipoc
   else
     echo""; echo " There was an error copying the file"
   fi
}

# Funtion to gatgher perferences
function gatherpreferences {
EXPAND="${1}"
if [ ! -f ${GCPCMDCONF} ]; then
   echo "-------------------------------------------------------"
   echo " Welcome to FortiPoc Toolkit for Google Cloud Platform"
   echo "-------------------------------------------------------"
   echo ""
   echo "This is your first time use of gcpcmd.sh and no preferences are set. Let's set them!"
   echo "NOTE: Make sure you have enabled the 'Compute Engine API' via the Google Cloud Console first!"
   sleep 3
   echo 'DEFAULTPROJECT="1"' > ${GCPCMDCONF}
   read -p "Would you like to have "gcpcmd" as a global command? y/n : " choice
   if [ -z "${choice}" ] || [ "${choice}" == "y" ]; then
      if [[ ${PATH} =~ "/usr/local/bin" ]]; then
        [ -d /usr/local/bin ] && sudo ln -s $(pwd)/gcpcmd.sh /usr/local/bin/gcpcmd
      fi
   fi
   echo "" >> ${GCPCMDCONF}
   EXPAND="new"
fi
if [ "${EXPAND}" = "new" ]; then
   let NEWPROJECTNUM=${#GCPCMD_PROJECT[@]}+1
   read -p "Your initials e.g. fl                       : " CONFINITIALS
   read -p "Your name to lable instanced e.g. flastname : " CONFGCPLABEL
   read -p "Groupname for shared instances (optional)   : " CONFGCPGROUP
   until [ ! -z ${CONFREGION} ]; do
      read -p "Your region 1) Asia, 2) Europe, 3) America  : " CONFREGIONANSWER
      case ${CONFREGIONANSWER} in
      1) CONFREGION="${ASIA}" ;;
      2) CONFREGION="${EUROPE}" ;;
      3) CONFREGION="${AMERICA}" ;;
      esac
   done

   # Request ProjectId from GCP and use that if no projectId is entered
   echo ""
   echo "You have access to the following GCP Projects"
   GCPPROJECTS=$(gcloud projects list --format json | jq '.[] .projectId')
   GCPPROJECTID=(${GCPPROJECTS})
   for ((i=0;i<${#GCPPROJECTID[@]};i++))
   do
     echo "  ${i}) : ${GCPPROJECTID[${i}]}"
   done
   echo ""
   echo "   q to quit"
   echo ""
   read -p " Select your GCP project : " SELECTEDPROJECT
   if [[ ${SELECTEDPROJECT} -lt 0 ]] || [[ ${SELECTEDPROJECT} -ge ${#GCPPROJECTID[@]} ]] && [ ! ${SELECTEDPROJECT} == "q" ]
   then
     echo""; echo " [ERROR] Invalid project selected"
     exit 1
   else
     if [ "${SELECTEDPROJECT}" = "q" ]; then exit
     else
       CONFPROJECTNAME=$(echo ${GCPPROJECTID[${SELECTEDPROJECT}]} | tr -d \")
     fi
   fi

   # Request default Compute Service Account and use that if no Service Account is entered
   GCPSRVACCOUNT=$(gcloud iam service-accounts list --filter=Compute --format=json | jq -r '.[] .email')
   until [[ ${ONEACCOUNT} -eq 1 ]]; do
      read -p "GCP service account (provide only one) [${GCPSRVACCOUNT}] : " CONFSERVICEACCOUNT
      [ -z "${CONFSERVICEACCOUNT}" ] && CONFSERVICEACCOUNT="${GCPSRVACCOUNT}"
      [[ ! ${CONFSERVICEACCOUNT} =~ \  ]] && ONEACCOUNT=1
   done

   until [[ ${VALIDIP} -eq 1 ]]; do
      read -p "IP-address of license-server (optional) : " CONFLICENSESERVER
      if [ -z ${CONFLICENSESERVER} ]; then
         VALIDIP=1
      else
         validateIP ${CONFLICENSESERVER}
         VALIDIP=!$?
      fi
   done

   # Obtain pesonal SSH-key for FortiPoC access
   SSHKEYPERSONAL="_no_key_found"
   if [ -f ~/.ssh/id_rsa.pub ]; then
      SSHKEYPERSONAL=$(head -1 ~/.ssh/id_rsa.pub)
   fi
   read -p "Your SSH public key for FortiPoC access (optional) [${SSHKEYPERSONAL}] : " CONFSSHKEYPERSONAL
   CONFSSHKEYPERSONAL="${SSHKEYPERSONAL}"

   cat <<EOF >>${GCPCMDCONF}

GCPCMD_PROJECT[${NEWPROJECTNUM}]="${CONFPROJECTNAME}"
GCPCMD_SERVICEACCOUNT[${NEWPROJECTNUM}]="${CONFSERVICEACCOUNT}"
GCPCMD_LICENSESERVER[${NEWPROJECTNUM}]="${CONFLICENSESERVER}"
GCPCMD_FPPREPEND[${NEWPROJECTNUM}]="${CONFINITIALS}"
GCPCMD_ZONE[${NEWPROJECTNUM}]="${CONFREGION}"
GCPCMD_LABELS[${NEWPROJECTNUM}]="expire=MM-DD-YYYY,group=${CONFGCPGROUP}, purpose=ReplaceMe,owner=${CONFGCPLABEL}"
GCPCMD_FPGROUP[${NEWPROJECTNUM}]="${CONFGCPGROUP}"
GCPCMD_PRODUCT[${NEWPROJECTNUM}]="test"
GCPCMD_SSHKEYPERSONAL[${NEWPROJECTNUM}]="${CONFSSHKEYPERSONAL}"
GCPCMD_VPC[${NEWPROJECTNUM}]=""
GCPCMD_FIREWALLRULES[${NEWPROJECTNUM}]=""
EOF
   echo ""
fi
}

###############################
#   start of program
###############################
# Check if required software is available and exit if missing
type gcloud >/dev/null 2>&1 || (
   echo ""
   echo "WARNING: gcloud SDK not installed"
   exit 1
)
[ $? -eq 1 ] && exit
type parallel >/dev/null 2>&1 || (
   echo ""
   echo "WARNING: parallel software not installed"
   exit 1
)
[ $? -eq 1 ] && exit
type jq >/dev/null 2>&1 || (
   echo""
   echo "WARNING: jq software not installed"
   exit 1
)
[ $? -eq 1 ] && exit
type dig >/dev/null 2>&1 || (
   echo ""
   echo "WARNING: dig software not installed (bind-tools)"
   exit 1
)
[ $? -eq 1 ] && exit
echo ""

# Check on first run and user specific defaults
# Chech if .fpoc logs and conf directories exists, create if it doesn't exist to store peronal perferences
[ ! -d ~/.fpoc/ ] && mkdir ~/.fpoc
[ ! -d logs ] && mkdir logs
[ ! -d conf ] && mkdir conf

eval GCPCMDCONF="~/.fpoc/gcpcmd.conf"
gatherpreferences
source ${GCPCMDCONF}

# Populate the internal (old) variables from the multi-project gcpcmd.conf preferences file
GCPPROJECT="${GCPCMD_PROJECT[${DEFAULTPROJECT}]}"
GCPSERVICEACCOUNT="${GCPCMD_SERVICEACCOUNT[${DEFAULTPROJECT}]}"
LICENSESERVER="${GCPCMD_LICENSESERVER[${DEFAULTPROJECT}]}"
FPPREPEND="${GCPCMD_FPPREPEND[${DEFAULTPROJECT}]}"
ZONE="${GCPCMD_ZONE[${DEFAULTPROJECT}]}"
LABELS="${GCPCMD_LABELS[${DEFAULTPROJECT}]}"
FPGROUP="${GCPCMD_FPGROUP[${DEFAULTPROJECT}]}"
PRODUCT="${GCPCMD_PRODUCT[${DEFAULTPROJECT}]}"
SSHKEYPERSONAL="${GCPCMD_SSHKEYPERSONAL[${DEFAULTPROJECT}]}"
VPC="${GCPCMD_VPC[${DEFAULTPROJECT}]}"
FIREWALLRULES="${GCPCMD_FIREWALLRULES[${DEFAULTPROJECT}]}"
#OWNER=$(echo ${LABELS} | grep owner | cut -d "=" -f 3)
OWNER=$(echo ${LABELS} | awk -F "owner=" '{ print $2}')

# Check online if there is a newer Version
ONLINEVERSION=$(curl --fail --silent --retry-max-time 1 --user-agent ${GCPCMDVERSION}-${GCPPROJECT}-${FPPREPEND} http://www.4xion.com/gcpcmdversion.txt)
[ ! -z "${ONLINEVERSION}" ] && [ ${ONLINEVERSION} -gt ${GCPCMDVERSION} ] && NEWVERSION="true"

# Verify if DEFAULTPROJECT is populated in prefences file. If not than gcpcmd.sh was updated to multi-project support..
if [ -z ${DEFAULTPROJECT} ] && [ ! "$1" == "-d" ]; then
   echo "Run ./gcpcmd.sh -d because your configured preferences are from older gcpcmd.sh version not supporting multi-projects."
   [ -f ${GCPCMDCONF} ] && displaypreferences ${GCPCMDCONF}
   exit
fi

# Verify if SSHKEY was populated from prefences file. If not than gcpcmd.sh was updated.
#if [ -z "${SSHKEYPERSONAL}" ] && [ ! "$1" == "-d" ]; then
#   echo "Run ./gcpcmd.sh -d because your configured preferences are from older gcpcmd.sh version."
#   [ -f ${GCPCMDCONF} ] && displaypreferences ${GCPCMDCONF}
#   exit
#fi

# Verify if group variable preference is set, else gcpcmd.sh was update
#if [ -z ${FPGROUP} ] && [ ! $(grep FPGROUP ${GCPCMDCONF}) ] && [ ! "$1" == "-d" ]; then
#   echo "Run ./gcpcmd.sh -d because your configured preferences are from older gcpcmd.sh version."
#   [ -f ${GCPCMDCONF} ] && displaypreferences ${GCPCMDCONF}
#   exit
#elif [ -z ${FPGROUP} ]; then
#   FPGROUP=${OWNER}
#fi

# Verify if Service Account preference is set, else append to personal preference file
#if [ ! $(grep GCPSERVICEACCOUNT ${GCPCMDCONF}) ]; then
#   GCPSRVACCOUNT=$(gcloud iam service-accounts list --filter=Compute --format=json | jq -r '.[] .email')
#   echo "Adding default Service Account to your personal preference file"
#   echo "GCPSERVICEACCOUNT=\"${GCPSRVACCOUNT}\"" >>${GCPCMDCONF}
#fi

# Check if GCP default VPC and Firewall rules exist
   checkdefaultnetwork
   checkfirewallrules

# Handling options given
while [[ "$1" =~ ^-.* ]]; do
   case $1 in
   -b | --build-file)
      #   Check if a build config file is provided
      CONFIGFILE=$2
      RUN_CONFIGFILE="true"
      shift
      ;;
   -d | --delete-defaults)
      echo "Delete default user settings"
      rm ${GCPCMDCONF}
      exit
      ;;
   -g | --group)
      FPGROUP=$2
      SET_FPGROUP="true"
      OVERRIDE_FPGROUP=${FPGROUP}
      shift
      ;;
   -ge | --global-access-enable)
      togglefirewallruleany enable
      exit
      ;;
   -gd | --global-access-disable)
      togglefirewallruleany disable
      exit
      ;;
   -gl | --global-access-list)
      instancefirewallrules
      exit
      ;;
   -gs | --global-access-status)
      togglefirewallruleany status
      exit
      ;;
   -i | --initials)
      FPPREPEND=$2
      SET_FPPREPEND="true"
      OVERRIDE_FPPREPEND=${FPPREPEND}
      shift
      ;;
   -ia | --ip-address-add)
      gcpaclupdate add $2
      exit
      ;;
   -ir | --ip-address-remove)
      gcpaclupdate remove $2
      exit
      ;;
   -il | --ip-address-list)
      gcpaclupdate list
      exit
      ;;
   -lg | --list-global)
      RUN_LISTGLOBAL=true
      ;;
   -ll | --list-labels)
      RUN_LISTLABELS=true
      ;;
   -lr | --list-running)
      RUN_LISTRUNNING=true
      ;;
   -p | --preferences)
      displayheader
      displaypreferences ${GCPCMDCONF}
      exit
      ;;
   -pa | --projectadd)
      gatherpreferences new
      exit
      ;;
   -ps | --projectselect)
      projectselect
      exit
      ;;
   -t | --type)
      TYPE=$2
      SET_TYPE="true"
      OVERRIDE_TYPE=${TYPE}
      shift
      ;;
   -ui | --upload-image)
      gcpuploadimage
      exit
      ;;
   -z | --zone)
      ZONE=$2
      SET_ZONE="true"
      OVERRIDE_ZONE=${ZONE}
      shift
      ;;
   -*)
      # Report invalid option
      echo ""; echo " [ERROR] Invalid option ${1}"
      echo ""
      ;;
   esac
   shift
done

if [ "${RUN_CONFIGFILE}" == "true" ]; then
   if [ ! -z ${CONFIGFILE} ] && [ -e ${CONFIGFILE} ]; then
      source ${CONFIGFILE}
      if [ ! -z ${SET_FPGROUP} ] && [ ${SET_FPGROUP} == "true" ]; then
         FPGROUP=${OVERRIDE_FPGROUP}
      fi
   else
      echo "Config file not found. Example file fpoc-example.conf in directory ./conf"
      cat <<EOF > ./conf/fpoc-example.conf
# Uncomment and speficy to override user defaults
#GCPPROJECT="${GCPPROJECT}"
#GCPSERVICEACCOUNT="${GCPSERVICEACCOUNT}"
#FPPREPEND="${FPPREPEND}"
#LABELS="${LABELS}"
#LICENSESERVER="${LICENSESERVER}"

# --- edits below this line ---
# Specify FortiPoC instance details.
MACHINETYPE="n1-standard-4"
FPIMAGE="fortipoc-1-9-11-cloud"
#FPSIMPLEMENU="enable"
FPTRAILKEY='ES-xamadrid-201907:765eb11f6523382c10513b66a8a4daf5'
#GCPREPO=""
#FPGROUP="${FPGROUP}"
POCDEFINITION1="poc/ferry/FortiWeb-Basic-solution-workshop-v2.2.fpoc"
#POCDEFINITION2="poc/ferry/FortiWeb-Advanced-Solutions-Workshop-v2.5.fpoc"
#POCDEFINITION3=""
#POCDEFINITION4=""
#POCDEFINITION5=""
#POCDEFINITION6=""
#POCDEFINITION7=""
#POCDEFINITION8=""
#POCLAUNCH="FortiWeb Basic solutions"
EOF
      exit
   fi
fi

if [ "${SET_FPPREPEND}" == "true" ]; then
   FPPREPEND=${OVERRIDE_FPPREPEND}
fi

if [ "${SET_TYPE}" == "true" ]; then
   TYPE=${OVERRIDE_TYPE}
fi

if [ "${RUN_LISTGLOBAL}" == "true" ]; then
   displayheader
   #echo "Listing all global instances for project: ${GREENREVERSED}${GCPPROJECT}${NOCOLOR} owner:${GREENREVERSED}${OWNER}${NOCOLOR} or group:${GREENREVERSED}${FPGROUP}${NOCOLOR}"
   echo "Listing all global instances for Project:${GCPPROJECT} Owner:${OWNER} or Group:${FPGROUP}"
   echo ""
   gcplistglobal ${OWNER} ${FPGROUP} ${1}
   exit
fi

if [ "${RUN_LISTLABELS}" == "true" ]; then
   displayheader
   echo "Listing all global instances and labels for Project:${GCPPROJECT} Owner:${OWNER} or Group:${FPGROUP}"
   echo ""
   instancelabels ${OWNER} ${FPGROUP}
   exit
fi

if [ "${RUN_LISTRUNNING}" == "true" ]; then
   displayheader
   echo "Listing all global RUNNING instances for Project:${GCPPROJECT} Owner:${OWNER} or Group:${FPGROUP}"
   echo ""
   gcplistrunning ${OWNER} ${FPGROUP}
   exit
fi

if [ $# -lt 1 ]; then
   displayhelp
   exit
fi

# Populate given arguments
LABELS="purpose=fortipoc,owner=${OWNER},group=${FPGROUP}"
ARGUMENT1=$1
ARGUMENT2=$2
ARGUMENT3=$3

# Validate given arguments
case ${ARGUMENT1} in
# Check if preference file contains the preferred zone, else take hardcoded
america)
   if [[ ! ${ZONE} =~ "us" ]]; then
    ZONE=${AMERICA}
   fi 
   ;;
asia)
   if [[ ! ${ZONE} =~ "asia" ]]; then
    ZONE=${ASIA}
   fi 
   ;;
europe)
   if [[ ! ${ZONE} =~ "europe" ]]; then
    ZONE=${EUROPE}
   fi 
   ;;
list)
   echo "Using your default settings"
   ARGUMENT2=${PRODUCT}
   ARGUMENT3="list"
   ;;
listpubip)
   echo "Using your default settings"
   ARGUMENT2=${PRODUCT}
   ARGUMENT3="listpubip"
   ;;
*)
   echo ""; echo " [ERROR: REGION] Specify: america, asia or europe"
   echo ""
   exit
   ;;
esac

if [ "${SET_ZONE}" == "true" ]; then
   ZONE=${OVERRIDE_ZONE}
fi

case ${ARGUMENT2} in
fpx)
   PRODUCT="fpx"
   FPTITLE="FortiProxy\ Workshop"
   ;;
fwb)
   PRODUCT="fwb"
   FPTITLE="FortiWeb\ Workshop"
   ;;
fad)
   PRODUCT="fad"
   FPTITLE="FortiADC\ Workshop"
   ;;
fsa)
   PRODUCT="fsa"
   FPTITLE="FortiSandbox\ Workshop"
   ;;
fsw)
   PRODUCT="fsw"
   FPTITLE="FortiSwitch\ Workshop"
   ;;
sme)
   PRODUCT="sme"
   FPTITLE="SME-event\ Workshop"
   ;;
xa)
   PRODUCT="xa"
   FPTITLE="Xperts\ Academy\ Workshop"
   ;;
appsec)
   PRODUCT="appsec"
   FPTITLE="Application\ Security\ Workshop"
   ;;
test)
   PRODUCT="test"
   FPTITLE="Test\ Instance"
   ;;
list)
   echo "Using your default settings"
   ARGUMENT3="list"
   ;;
listpubip)
   echo "Using your default settings"
   ARGUMENT3="listpubip"
   ;;
*)
   PRODUCT="${ARGUMENT2}"
   FPTITLE="${PRODUCT}\ Workshop"
   ;;
esac

case ${ARGUMENT3} in
accesslist) ACTION="accesslist" ;;
accessmodify) ACTION="accessmodify" ;;
build) ACTION="build" ;;
clone) ACTION="clone" ;;
delete) ACTION="delete" ;;
globalaccess) ACTION="globalaccess" ;;
globalaccesslist) ACTION="globalaccesslist" ;;
labellist) ACTION="labellist";;
labelmodify) ACTION="labelmodify";;
list) ACTION="list" ;;
listpubip) ACTION="listpubip" ;;
machinetype) ACTION="machinetype" ;;
move) ACTION="move" ;;
rename) ACTION="rename";;
start) ACTION="start" ;;
stop) ACTION="stop" ;;
*)
   echo ""; echo " [ERROR: ACTION] Specify: accesslist, accessmodify, build, clone, delete, globalaccess, globalaccesslist, labellist, labelmodify, list, listpubip, machinetype, move, rename, start or stop"
   exit
   ;;
esac

displayheader
if [[ ${ACTION} == accesslist || ${ACTION} == accessmodify || ${ACTION} == build || ${ACTION} == delete || ${ACTION} == globalaccess || ${ACTION} == globalaccesslist || ${ACTION} == "labellist" || ${ACTION} == "labelmodify" || ${ACTION} == machinetype || ${ACTION} == move || ${ACTION} == rename || ${ACTION} == start || ${ACTION} == stop ]]; then
   read -p " Enter amount of FortiPoC's : " FPCOUNT
   read -p " Enter start of numbered range : " FPNUMSTART
   if [ ${ACTION} == "machinetype" ]; then
      read -p " select machine-type : 0) e2-medium 1) n1-standard-1, 2) n1-standard-2, 3) n1-standard-4, 4) n1-standard-8, 5) n1-standard-16 : " NEWMACHINETYPE
      case ${NEWMACHINETYPE} in
      0) MACHINETYPE="e2-medium" ;;
      1) MACHINETYPE="n1-standard-1" ;;
      2) MACHINETYPE="n1-standard-2" ;;
      3) MACHINETYPE="n1-standard-4" ;;
      4) MACHINETYPE="n1-standard-8" ;;
      5) MACHINETYPE="n1-standard-16" ;;
      *)
         echo "Wrong machine type given"
         echo ""
         exit
         ;;
      esac
   elif [ ${ACTION} == "globalaccess" ]; then
      read -p " select world wide access : 1) Enable, 2) Disable : " NEWGLOBALACCESS
      case ${NEWGLOBALACCESS} in
      1) GLOBALACCESS="enable" ;;
      2) GLOBALACCESS="disable" ;;
      *)
         echo "Wrong input given"
         echo ""
         exit
         ;;
      esac
   elif [ ${ACTION} == "labelmodify" ]; then
      read -p " What label action would you like 1) Add, 2) Remove, 3) replace : " NEWLABELACTION
      case ${NEWLABELACTION} in
      1) LABELACTION="add" ;;
      2) LABELACTION="remove" ;;
      3) LABELACTION="replace" ;;
      *)
         echo "Wrong input given"
         echo ""
         exit
         ;;
      esac
      if [ ${LABELACTION} == "add" ]; then
         read -p " Provide the new label and value e.g. name=value : " LABEL
         NEWLABEL="dummy"
      elif [ ${LABELACTION} == "remove" ]; then
         read -p " Provide the label name to remove : " LABEL
         NEWLABEL="dummy"
      else
         read -p " Provide the label name to replace : " LABEL
         read -p " Provide the new label and value e.g. name=value : " NEWLABEL
      fi
    elif [ ${ACTION} == "accessmodify" ]; then
      read -p " What network tag (firewall-rule) action would you like 1) Add, 2) Remove, 3) replace : " NEWTAGACTION
      case ${NEWTAGACTION} in
      1) TAGACTION="add" ;;
      2) TAGACTION="remove" ;;
      3) TAGACTION="replace" ;;
      *)
         echo "Wrong input given"
         echo ""
         exit
         ;;
      esac
      if [ ${TAGACTION} == "add" ]; then
         read -p " Provide the new network tag and value e.g. default-deny-all : " NETWORKTAG
         NEWNETWORKTAG="dummy"
      elif [ ${TAGACTION} == "remove" ]; then
         read -p " Provide the network tag  name to remove : " NETWORKTAG
         NEWNETWORKTAG="dummy"
      else
         read -p " Provide the network tag name to replace : " NETWORKTAG
         read -p " Provide the new network tag and value e.g. allow-http-any : " NEWNETWORKTAG
      fi
   elif [ ${ACTION} == "move" ]; then
      while [[ "${ZONESTATUS}" != "UP" ]] ; do
      read -p " To which zone would you like to move the instance(s) : " DSTZONE
      echo " Checking destination zone availability"
      ZONESTATUS=`gcloud compute zones describe ${DSTZONE} --format=json | jq -r '.status'`
      if [ "${ZONESTATUS}" == "UP" ]; then
         read -p " Are the instances NOT RUNNING? y/n " choice
         [ "${choice}" != "y" ] && exit
      else
        echo " That destination zone is not available or UP"
      fi
      done
   elif [ ${ACTION} == "rename" ]; then
      read -p " What is the new instance PRODUCT name (${TYPE}-${FPPREPEND}-PRODUCT-nnn) : " NEWPRODUCTNAME
      read -p " Is this new instance name ${TYPE}-${FPPREPEND}-${NEWPRODUCTNAME}-nnn correct? y/n " choice 
         [ "${choice}" != "y" ] && exit
   fi
   let --FPCOUNT
   let FPNUMEND=FPNUMSTART+FPCOUNT
   FPNUMSTART=$(printf "%03d" ${FPNUMSTART})
   FPNUMEND=$(printf "%03d" ${FPNUMEND})

   echo ""
   read -p "Okay to ${ACTION} ${TYPE}-${FPPREPEND}-${PRODUCT}-${FPNUMSTART} till ${TYPE}-${FPPREPEND}-${PRODUCT}-${FPNUMEND}, Project=${GCPPROJECT}, region=${ZONE}.   y/n? " choice
   [ "${choice}" != "y" ] && exit
fi

if [[ ${ACTION} == clone ]]; then
   displayheader
   read -p " FortiPoC instance number to clone        : " FPNUMBERTOCLONE
   read -p " Enter amount of FortiPoC's clones (max 5): " FPCOUNT
   read -p " Enter start of numbered range            : " FPNUMSTART
   let --FPCOUNT
   let FPNUMEND=FPNUMSTART+FPCOUNT
   FPNUMSTART=$(printf "%03d" ${FPNUMSTART})
   FPNUMEND=$(printf "%03d" ${FPNUMEND})
   FPNUMBERTOCLONE=$(printf "%03d" ${FPNUMBERTOCLONE})
   CLONESOURCE="${TYPE}-${FPPREPEND}-${PRODUCT}-${FPNUMBERTOCLONE}"
   CLONEMACHINEIMAGE="${TYPE}-${FPPREPEND}-${PRODUCT}"
   if [ ! -z ${SET_FPGROUP} ] && [ ${SET_FPGROUP} == "true" ]; then
      FPGROUP=${OVERRIDE_FPGROUP}
   fi
   echo ""
   read -p "Okay to ${ACTION} ${CLONESOURCE} to ${TYPE}-${FPPREPEND}-${PRODUCT}-${FPNUMSTART} till ${TYPE}-${FPPREPEND}-${PRODUCT}-${FPNUMEND}, Project=${GCPPROJECT}, region=${ZONE}.   y/n? " choice
   [ "${choice}" != "y" ] && exit
   # Safest is to use fresh machine-image because it includes latest changes and there is not check if a machine-image exists
   # To speed up cloning you could skip machine-image creation and assume there's an machine-image available.
   read -p "Do you want to create a fresh machine-image? (No means the latest machine-image will be used, if available) y/n: " choice
   if [ ${choice} == "y" ]; then
      # Delete any existing machine-image before creating new.There's no overwrite AFAIK and will allow fresh snapshot
      echo "==> Preparing machine-image....be patienced, enjoy a quick espresso"
      echo "y" | gcloud beta compute machine-images delete ${CLONEMACHINEIMAGE} >/dev/null 2>&1
      gcloud beta compute machine-images create ${CLONEMACHINEIMAGE} \
         --source-instance ${CLONESOURCE} \
         --source-instance-zone=${ZONE} >/dev/null 2>&1
   fi
fi

echo "==> Lets go...using Owner=${OWNER} or Group=${FPGROUP}, Project=${GCPPROJECT}, Zone=${ZONE}, Product=${PRODUCT}, Action=${ACTION}"
echo

export -f gcpaccessmodify gcpbuild gcpstart gcpstop gcpdelete gcpclone gcpmachinetype gcpmove gcprename gcpglobalaccess gcplabelmodify
export CONFIGFILE GCPPROJECT FPIMAGE MACHINETYPE WORKSHOPSOURCEANY LABELS LABEL NEWLABEL NETWORKTAG NEWNETWORKTAG FPTRAILKEY FPPREPEND POCDEFINITION1 POCDEFINITION2 POCDEFINITION3 POCDEFINITION4 POCDEFINITION5 POCDEFINITION6 POCDEFINITION7 POCDEFINITION8 LICENSESERVER POCLAUNCH NEWMACHINETYPE GCPSERVICEACCOUNT SSHKEYPERSONAL WORKSHOPSOURCENETWORKS DSTZONE NEWPRODUCTNAME TYPE

case ${ACTION} in
accesslist) gcpaccesslist ${FPPREPEND} ${ZONE} ${PRODUCT} ${FPNUMSTART} ${FPNUMEND} ;;
build) parallel ${PARALLELOPT} -j0 gcpbuild ${FPPREPEND} ${ZONE} ${PRODUCT} "${FPTITLE}" ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
clone) parallel ${PARALLELOPT} -j0 gcpclone ${FPPREPEND} ${ZONE} ${PRODUCT} "${FPNUMBERTOCLONE}" ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
delete) parallel ${PARALLELOPT} -j0 gcpdelete ${FPPREPEND} ${ZONE} ${PRODUCT} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
globalaccess) parallel ${PARALLELOPT} -j0 gcpglobalaccess ${FPPREPEND} ${ZONE} ${PRODUCT} ${GLOBALACCESS} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
labellist) labellist ${FPPREPEND} ${ZONE} ${PRODUCT} ${FPNUMSTART} ${FPNUMEND} ;;
labelmodify) parallel ${PARALLELOPT} -j0 gcplabelmodify ${FPPREPEND} ${ZONE} ${PRODUCT} ${LABELACTION} ${LABEL} ${NEWLABEL} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
accessmodify) parallel ${PARALLELOPT} -j0 gcpaccessmodify ${FPPREPEND} ${ZONE} ${PRODUCT} ${TAGACTION} ${NETWORKTAG} ${NEWNETWORKTAG} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
list) gcloud compute instances list --filter="(labels.owner:${OWNER} OR labels.group:${FPGROUP}) AND zone~${ZONE}" | grep -e "NAME" -e ${PRODUCT} ;;
listpubip) gcloud compute instances list --filter="(labels.owner:${OWNER} OR labels.group:${FPGROUP}) AND zone~${ZONE}" | grep -e ${PRODUCT} | awk '{ printf $5 " " }' ;;
machinetype) parallel ${PARALLELOPT} -j0 gcpmachinetype ${FPPREPEND} ${ZONE} ${PRODUCT} ${MACHINETYPE} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
move) parallel ${PARALLELOPT} -j0 gcpmove ${FPPREPEND} ${ZONE} ${PRODUCT} ${DSTZONE} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
rename) parallel ${PARALLELOPT} -j0 gcprename ${FPPREPEND} ${ZONE} ${PRODUCT} ${NEWPRODUCTNAME} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
start) parallel ${PARALLELOPT} -j0 gcpstart ${FPPREPEND} ${ZONE} ${PRODUCT} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
stop) parallel ${PARALLELOPT} -j0 gcpstop ${FPPREPEND} ${ZONE} ${PRODUCT} ::: $(seq -f%03g ${FPNUMSTART} ${FPNUMEND}) ;;
esac
