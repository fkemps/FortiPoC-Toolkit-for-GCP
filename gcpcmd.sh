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
# 2019120501 Ferry Kemps, Added <custom name> for product/solution, arguments sorted alphabetic
GCPCMDVERSION="2019112901"

# Zones where to deploy. You can adjust if needed to deploy closest to your location
ASIA="asia-southeast1-b"
EUROPE="europe-west4-a"
#EUROPE="europe-west1-b"
AMERICA="us-central1-c"

# -----------------------------------------------
# ------ No editing needed below this line ------
# -----------------------------------------------

# Let's create uniq logfiles with date-time stamp
PARALLELOPT="--joblog logs/logfile-`date +%Y%m%d%H%M%S` -j 100 "

########################
# Functions
########################
function displayheader() {
clear
echo "---------------------------------------------------------------------"
echo "             FortiPoC Toolkit for Google Cloud Platform             "
echo "---------------------------------------------------------------------"
echo ""
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
     [[ ${ip[0]} -le 239 && ${ip[1]} -le 255 \
     && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
     stat=$?
  fi
  return $stat
}

# Function to add/remove workshop location Public IP-address to GCP ACL to allow access
function gcpaclupdate() {
   CMD=$1
# Obtain current public IP-address
   PUBLICIP=`dig TXT -4 +short o-o.myaddr.l.google.com @ns1.google.com | sed -e 's/"//g'`
   validateIP ${PUBLICIP}
   [ ! $? -eq 0 ] && (echo "Public IP not retreavable or not valid"; exit) 
   if [ ${CMD} == add ]; then
      echo "Adding public-ip ${PUBLICIP} to GCP ACL to allow access from this location"
      while read line
      do
         if [ -z ${SOURCERANGE} ]; then
            SOURCERANGE="$line"
         else
            SOURCERANGE="${SOURCERANGE},$line"
         fi
      done < <(gcloud compute firewall-rules list --filter="name=workshop-source-networks" --format=json|jq -r '.[] .sourceRanges[]')
      SOURCERANGE="${SOURCERANGE},${PUBLICIP}"
      gcloud compute firewall-rules update workshop-source-networks --source-ranges=${SOURCERANGE}
      echo "Current GCP ACL list"
      gcloud compute firewall-rules list --filter="name=workshop-source-networks" --format=json|jq -r '.[] .sourceRanges[]'
      echo ""
   else
      echo "Removing public-ip ${PUBLICIP} to GCP ACL to remove access from this location"
      while read line
      do
         if [ -z ${SOURCERANGE} ]; then
            [ ! $line == ${PUBLICIP} ] && SOURCERANGE="$line"
         else
            [ ! $line == ${PUBLICIP} ] && SOURCERANGE="${SOURCERANGE},$line"
         fi
      done < <(gcloud compute firewall-rules list --filter="name=workshop-source-networks" --format=json|jq -r '.[] .sourceRanges[]')
      gcloud compute firewall-rules update workshop-source-networks --source-ranges=${SOURCERANGE}
      echo "Current GCP ACL list"
      gcloud compute firewall-rules list --filter="name=workshop-source-networks" --format=json|jq -r '.[] .sourceRanges[]'
      echo ""
   fi
}

# Function to list all global instances
function gcplistglobal {
  OWNER=$1
  gcloud compute instances list --filter="labels.owner:${OWNER}"
}

# Function to build a FortiPoC instance on GCP
function gcpbuild {

  if [ "${CONFIGFILE}" == "" ]; then
     echo "Config file missing. Use -c option to specify or to generate fpoc-example.conf file"
     exit
  fi

  RANDOMSLEEP=$[($RANDOM % 10) + 1]s
  FPPREPEND=$1
  ZONE=$2
  PRODUCT=$3
  FPTITLE=$4
  INSTANCE=$5
  INSTANCENAME="fpoc-${FPPREPEND}-${PRODUCT}-${INSTANCE}"

  echo "==> Sleeping ${RANDOMSLEEP} seconds to avoid GCP DB locking"
  sleep ${RANDOMSLEEP}
  echo "==> Creating instance ${INSTANCENAME}"
  gcloud compute \
  instances create ${INSTANCENAME} \
  --project=${GCPPROJECT} \
  --verbosity=info \
  --zone=${ZONE} \
  --machine-type=${MACHINETYPE} \
  --subnet=default --network-tier=PREMIUM \
  --maintenance-policy=MIGRATE \
  --service-account=20168517356-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --min-cpu-platform=Intel\ Broadwell\
  --tags=fortipoc-http-https-redir,workshop-source-networks \
  --image=${FPIMAGE} \
  --image-project=${GCPPROJECT} \
  --boot-disk-size=200GB \
  --boot-disk-type=pd-standard \
  --boot-disk-device-name=${INSTANCENAME} \
  --labels=${LABELS}

  # Give Google 60 seconds to start the instance
  echo ""; echo "==> Sleeping 90 seconds to allow FortiPoC booting up"; sleep 90
  INSTANCEIP=`gcloud beta compute instances describe ${INSTANCENAME} --zone=${ZONE} | grep natIP | awk '{ print $2 }'`
  echo ${INSTANCENAME} "=" ${INSTANCEIP}
  curl -k -q --retry 1 --connect-timeout 10 https://${INSTANCEIP}/ && echo "FortiPoC ${INSTANCENAME} on ${INSTANCEIP} reachable"
  [ $? != 0 ] && echo "==> Something went wrong. The new instance is not reachable"

  # Now configure, load, prefetch and start PoC-definition
  [ "${FPTRAILKEY}" != "" ] && (echo "==> Registering FortiPoC"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "reg trial ${FPTRAILKEY}")
  [ "${FPTITLE}" != "" ] && (echo "==> Setting title"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set gui title \"${FPTITLE}\"")
  gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'set guest passwd guest'
  [ "${GCPREPO}" != "" ] && (echo "==> Adding repository"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "repo add gcp-${GCPREPO} https://gcp.repository.fortipoc.com/~#{GCPREPO}/ --unsigned")
  [ "${LICENSESERVER}" != "" ] && (echo "==> Setting licenseserver"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set license https://${LICENSESERVER}/")
  [ "${POCDEFINITION1}" != "" ] && (echo "==> Loading poc-definition 1"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION1}\" refresh")
  [ "${POCDEFINITION2}" != "" ] && (echo "==> Loading poc-definition 2"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION2}\" refresh")
  [ "${POCDEFINITION3}" != "" ] && (echo "==> Loading poc-definition 3"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION3}\" refresh")
  [ "${POCDEFINITION4}" != "" ] && (echo "==> Loading poc-definition 4"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION4}\" refresh")
  [ "${POCDEFINITION5}" != "" ] && (echo "==> Loading poc-definition 5"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION5}\" refresh")
  [ "${POCDEFINITION6}" != "" ] && (echo "==> Loading poc-definition 6"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION6}\" refresh")
  [ "${POCDEFINITION7}" != "" ] && (echo "==> Loading poc-definition 7"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION7}\" refresh")
  [ "${POCDEFINITION8}" != "" ] && (echo "==> Loading poc-definition 8"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION8}\" refresh")
  echo "==> Prefetching all images and documentation"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'poc prefetch all'
  [ "${POCLAUNCH}" != "" ] && (echo "==> Launching poc-definition"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc launch \"${POCLAUNCH}\"")
#  [ "${FPSIMPLEMENU}" != "" ] && (echo "==> Setting GUI-mode to simple"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set gui simple ${FPSIMPLEMENU}")
  echo "==> End of Build phase <=="; echo ""
}

# Function to clone a FortiPoC instance on GCP
function gcpclone {
  RANDOMSLEEP=$[($RANDOM % 10) + 1]s
  FPPREPEND=$1
  ZONE=$2
  PRODUCT=$3
  FPNUMBERTOCLONE=$4
  INSTANCE=$5
  CLONESOURCE="fpoc-${FPPREPEND}-${PRODUCT}-${FPNUMBERTOCLONE}"
  CLONESNAPSHOT="fpoc-${FPPREPEND}-${PRODUCT}"
  INSTANCENAME="fpoc-${FPPREPEND}-${PRODUCT}-${INSTANCE}"

  echo "==> Sleeping ${RANDOMSLEEP} seconds to avoid GCP DB locking"
  sleep ${RANDOMSLEEP}
  echo "==> Cloning instance ${CLONESOURCE} to ${INSTANCENAME}"
  echo "==> Creating disk for ${INSTANCENAME}"
  gcloud compute disks create ${INSTANCENAME} \
  --zone=${ZONE} \
  --source-snapshot ${CLONESNAPSHOT} \
  --type "pd-standard" \
  --size=200
  echo "==> Create instance ${INSTANCENAME}"
  gcloud compute instances create ${INSTANCENAME} \
  --project=${GCPPROJECT} \
  --verbosity=info \
  --zone=${ZONE} \
  --machine-type=n1-standard-4 \
  --subnet=default --network-tier=PREMIUM \
  --maintenance-policy=MIGRATE \
  --service-account=20168517356-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --min-cpu-platform=Intel\ Broadwell \
  --tags=fortipoc-http-https-redir,workshop-source-networks \
  --disk "name=${INSTANCENAME},device-name=${INSTANCENAME},mode=rw,boot=yes,auto-delete=yes" \
  --labels=${LABELS}
}

# Function to start FortiPoC instance
function gcpstart {
  FPPREPEND=$1
  ZONE=$2
  PRODUCT=$3
  INSTANCE=$4
  INSTANCENAME="fpoc-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
  echo "==> Starting instance ${INSTANCENAME}"
  gcloud compute instances start ${INSTANCENAME} --zone=${ZONE}
}

# Function to stop FortiPoC instance
function gcpstop {
  FPPREPEND=$1
  ZONE=$2
  PRODUCT=$3
  INSTANCE=$4
  INSTANCENAME="fpoc-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
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
  INSTANCENAME="fpoc-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
  echo "==> Deleting instance ${INSTANCENAME}"
  echo yes | gcloud compute instances delete ${INSTANCENAME} --zone=${ZONE}
}

#########################
# start of program
#########################
# First check if required software is available
type gcloud > /dev/null 2>&1 || (echo "gcloud SDK not installed"; exit)
type parallel > /dev/null 2>&1 || (echo "parallel command not installed"; exit)
type jq > /dev/null 2>&1 || (echo "jq command not installed"; exit)
echo ""

# Check on first run and user specific defaults
# Chech if .fpoc directory exists, create if not exist to store peronal perferences
[ ! -d ~/.fpoc/ ] && mkdir ~/.fpoc
[ ! -d logs ] && mkdir logs
[ ! -d conf ] && mkdir conf

eval GCPCMDCONF="~/.fpoc/gcpcmd.conf"
if [ ! -f ${GCPCMDCONF} ]; then
   echo "Welcome to FortiPoc Toolkit for Google Cloud Platform"
   echo "Looks like your first run or no defaults available. Let's set them!" 
   read -p "Provide your initials : " CONFINITIALS
   read -p "Provide GCP instance label F(irst)LASTNAME e.g. jdoe : " CONFGCPLABEL
   until [ ! -z ${CONFREGION} ]; do
      read -p "Provide your region 1) Asia, 2) Europe, 3) America : " CONFREGIONANSWER
      case ${CONFREGIONANSWER} in
         1) CONFREGION="asia-southeast1-b";;
         2) CONFREGION="europe-west4-a";;
         3) CONFREGION="us-central1-c";;
      esac
   done
   read -p "Provide your GCP billing project ID : " CONFPROJECTNAME
   until [[ ${VALIDIP} -eq 1 ]]; do
      read -p "Provide GCP license server IP (Optional) : " CONFLICENSESERVER
      if [ -z ${CONFLICENSESERVER} ];then
         VALIDIP=1
      else
         validateIP ${CONFLICENSESERVER}
         VALIDIP=!$?
      fi
   done
   cat << EOF > ${GCPCMDCONF}
GCPPROJECT="${CONFPROJECTNAME}"
LICENSESERVER="${CONFLICENSESERVER}"
FPPREPEND="${CONFINITIALS}"
ZONE="${CONFREGION}"
LABELS="fortipoc=,owner=${CONFGCPLABEL}"
PRODUCT="test"
EOF
   echo ""
fi
source ${GCPCMDCONF}

case $1 in
  -c)
#   Check if build config file is provided
    CONFIGFILE=$2
    if [ -e ${CONFIGFILE} ] && [ "${CONFIGFILE}" != "" ]; then
      source ${CONFIGFILE}
    else
      echo "Config file not found. Example file written as fpoc-example.conf"
      cat << EOF > fpoc-example.conf
# Uncomment and speficy to override user defaults
#GCPPROJECT="${GCPPROJECT}"
#FPPREPEND="${FPPREPEND}"
#LABELS="${LABELS}"
#LICENSESERVER="${LICENSESERVER}"

# --- edits below this line ---
# Specify FortiPoC instance details.
MACHINETYPE="n1-standard-4"
FPIMAGE="fortipoc-1-7-2-clear"
#FPSIMPLEMENU="enable"
FPTRAILKEY='ES-xamadrid-201907:765eb11f6523382c10513b66a8a4daf5'
#GCPREPO="fkemps"
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
    shift; shift
    ;;
  -d | --delete-defaults) echo "Delete default user settings"
     rm ${GCPCMDCONF}
     exit
     ;;
  -ia | --ip-address-add)
     gcpaclupdate add
     exit
     ;;
  -ir | --ip-address-remove)
     gcpaclupdate remove
     exit
     ;;
  -lg | --list-global)
     OWNER=`echo ${LABELS} | grep owner | cut -d "=" -f 3`
     if [ -z ${OWNER} ]; then
        echo "Run ./gcpcmd.sh -d to set new preferences"
     else
       displayheader
       echo "Listing all global instances for ${OWNER}"
       echo ""
       gcplistglobal ${OWNER}
      fi
       exit
       ;;
  *)
   # Check command and options
   if [ $# -lt 2 ]; then
      echo "(Version: ${GCPCMDVERSION})"
      echo "Default deployment region: ${ZONE}"
      echo "Personal instance identification: ${FPPREPEND}"
      echo "Default product: ${PRODUCT}"
      echo ""
      echo "Usage: $0 [-c configfile] <region> <product> <action>"
      echo "       $0 [-c configfile] [region] [product] list"
      echo "       $0 [-c configfile] [region] [product] listpubip"
      echo "OPTIONS:"
      echo "        -d    --delete-config     Delete default user config settings"
      echo "        -ia   --ip-address-add    Add current public IP-address to GCP ACL"
      echo "        -ir   --ip-address-remove Remove current public IP-address from GCP ACL"
      echo "        -lg   --list-global       List all your instances globally"
      echo "ARGUMENTS:"
      echo "       region  : america, asia, europe"
      echo "       product : appsec, fad, fpx, fsa, fsw, fwb, sme, test, xa or <custom name>"
      echo "       action  : build, clone, delete, list, listpubip, start, stop"
      echo ""
   fi
   ;;
esac

# Populate given arguments
ARGUMENT1=$1
ARGUMENT2=$2
ARGUMENT3=$3

# Validate given arguments
case ${ARGUMENT1} in
  america) ZONE=${AMERICA};;
  asia) ZONE=${ASIA};;
  europe) ZONE=${EUROPE};;
  list) echo "Using your default settings"; ARGUMENT2=${PRODUCT}; ARGUMENT3="list";;
  listpubip) echo "Using your default settings"; ARGUMENT2=${PRODUCT}; ARGUMENT3="listpubip";;
  *) echo "[ERROR: REGION] Specify: america, asia or europe"; echo ""; exit;;
esac

case ${ARGUMENT2} in
  fpx) PRODUCT="fpx"; FPTITLE="FortiProxy\ Workshop";;
  fwb) PRODUCT="fwb"; FPTITLE="FortiWeb\ Workshop";;
  fad) PRODUCT="fad"; FPTITLE="FortiADC\ Workshop";;
  fsa) PRODUCT="fsa"; FPTITLE="FortiSandbox\ Workshop";;
  fsw) PRODUCT="fsw"; FPTITLE="FortiSwitch\ Workshop";;
  sme) PRODUCT="sme"; FPTITLE="SME-event\ Workshop";;
  xa)  PRODUCT="xa"; FPTITLE="Xperts\ Academy\ Workshop";;
  appsec)  PRODUCT="appsec"; FPTITLE="Application\ Security\ Workshop";;
  test)  PRODUCT="test"; FPTITLE="Test\ Instance";;
  list) echo "Using your default settings"; ARGUMENT3="list";;
  listpubip) echo "Using your default settings"; ARGUMENT3="listpubip";;
  *) PRODUCT="${ARGUMENT2}";  FPTITLE="${PRODUCT}\ Workshop";;
esac

case ${ARGUMENT3} in
  build) ACTION="build";;
  clone) ACTION="clone";;
  start) ACTION="start";;
  stop) ACTION="stop";;
  delete) ACTION="delete";;
  list) ACTION="list";;
  listpubip) ACTION="listpubip";;
  *) echo "[ERROR: ACTION] Specify: build, clone, delete, list, listpubip, start or stop"; exit;;
esac

displayheader
if  [[ ${ACTION} == build  ||  ${ACTION} == start || ${ACTION} == stop || ${ACTION} == delete ]]
then
  read -p " Enter amount of FortiPoC's : " FPCOUNT
  read -p " Enter start of numbered range : " FPNUMSTART
  let --FPCOUNT
  let FPNUMEND=FPNUMSTART+FPCOUNT
  FPNUMSTART=$(printf "%03d" ${FPNUMSTART})
  FPNUMEND=$(printf "%03d" ${FPNUMEND})

  echo ""
  read -p "Okay to ${ACTION} fpoc-${FPPREPEND}-${PRODUCT}-${FPNUMSTART} till fpoc-${FPPREPEND}-${PRODUCT}-${FPNUMEND} in region ${ZONE}.   y/n? " choice
  [ "${choice}" != "y" ] && exit
fi

if  [[ ${ACTION} == clone ]]
then
  displayheader
  read -p " FortiPoC instance number to clone : " FPNUMBERTOCLONE
  read -p " Enter amount of FortiPoC's clones : " FPCOUNT
  read -p " Enter start of numbered range : " FPNUMSTART
  let --FPCOUNT
  let FPNUMEND=FPNUMSTART+FPCOUNT
  FPNUMSTART=$(printf "%03d" ${FPNUMSTART})
  FPNUMEND=$(printf "%03d" ${FPNUMEND})
  FPNUMBERTOCLONE=$(printf "%03d" ${FPNUMBERTOCLONE})
  CLONESOURCE="fpoc-${FPPREPEND}-${PRODUCT}-${FPNUMBERTOCLONE}"
  CLONESNAPSHOT="fpoc-${FPPREPEND}-${PRODUCT}"
  echo ""
  read -p "Okay to ${ACTION} ${CLONESOURCE} to fpoc-${FPPREPEND}-${PRODUCT}-${FPNUMSTART} till fpoc-${FPPREPEND}-${PRODUCT}-${FPNUMEND} in region ${ZONE}.   y/n? " choice
  [ "${choice}" != "y" ] && exit
# Delete any existing snapshots before creating new.There's no overwrite AFAIK and will allow fresh snapshot
  echo "y" |  gcloud compute snapshots delete ${CLONESNAPSHOT} > /dev/null 2>&1
  gcloud compute disks snapshot ${CLONESOURCE} \
  --zone=${ZONE} \
  --snapshot-names=${CLONESNAPSHOT}
fi

  echo "==> Lets go...using Zone=${ZONE}, Product=${PRODUCT}, Action=${ACTION}"; echo 

export -f gcpbuild gcpstart gcpstop gcpdelete gcpclone
export CONFIGFILE GCPPROJECT FPIMAGE MACHINETYPE LABELS FPTRAILKEY FPPREPEND POCDEFINITION1 POCDEFINITION2 POCDEFINITION3 POCDEFINITION4 POCDEFINITION5 POCDEFINITION6 POCDEFINITION7 POCDEFINITION8 LICENSESERVER POCLAUNCH

case ${ACTION} in
  build)  parallel ${PARALLELOPT} gcpbuild  ${FPPREPEND} ${ZONE} ${PRODUCT} "${FPTITLE}" ::: `seq -f%03g ${FPNUMSTART} ${FPNUMEND}`;;
  clone)  parallel ${PARALLELOPT} gcpclone  ${FPPREPEND} ${ZONE} ${PRODUCT} "${FPNUMBERTOCLONE}" ::: `seq -f%03g  ${FPNUMSTART} ${FPNUMEND}`;;
  start)  parallel ${PARALLELOPT} gcpstart  ${FPPREPEND} ${ZONE} ${PRODUCT} ::: `seq -f%03g  ${FPNUMSTART} ${FPNUMEND}`;;
  stop)   parallel ${PARALLELOPT} gcpstop   ${FPPREPEND} ${ZONE} ${PRODUCT} ::: `seq -f%03g  ${FPNUMSTART} ${FPNUMEND}`;;
  delete) parallel ${PARALLELOPT} gcpdelete ${FPPREPEND} ${ZONE} ${PRODUCT} ::: `seq -f%03g  ${FPNUMSTART} ${FPNUMEND}`;;
  list) gcloud beta compute instances list --filter="name~fpoc-${FPPREPEND}-${PRODUCT}"| grep -e "NAME" -e "${ZONE}";;
  listpubip) gcloud beta compute instances list --filter="name~fpoc-${FPPREPEND}-${PRODUCT}"| grep -e "${ZONE}" | awk '{ printf $5 " " }';;
esac
