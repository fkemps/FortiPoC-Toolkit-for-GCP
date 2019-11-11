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
GCPCMDVERSION="2019111101"

# Zones where to deploy
ASIA="asia-southeast1-b"
EUROPE="europe-west4-a"
#EUROPE="europe-west1-b"
AMERICA="us-central1-c"

# -----------------------------------------------
# ------ No editing needed below this line ------
# -----------------------------------------------

PARALLELOPT="--joblog logs/logfile-`date +%Y%m%d%H%M%S` -j 100 "

########################
# Functions
########################
function gcpbuild {

  if [ "$CONFIGFILE" == "" ]; then
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

  echo "==> Sleeping $RANDOMSLEEP seconds to avoid GCP DB locking"
  sleep $RANDOMSLEEP
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
  [ "${FPTRAILKEY}" != "" ] && echo "==> Registering FortiPoC"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "reg trial ${FPTRAILKEY}"
  [ "${FPTITLE}" != "" ] && echo "==> Setting title"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set gui title \"${FPTITLE}\""
  gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'set guest passwd guest'
  [ "${GCPREPO}" != "" ] && echo "==> Adding repository"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "repo add gcp-${GCPREPO} https://gcp.repository.fortipoc.com/~#{GCPREPO}/ --unsigned"
  [ "${LICENSESERVER}" != "" ] && echo "==> Setting licenseserver"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set license https://${LICENSESERVER}/"
  [ "${POCDEFINITION1}" != "" ] && echo "==> Loading poc-definition 1"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION1}\" refresh"
  [ "${POCDEFINITION2}" != "" ] && echo "==> Loading poc-definition 2"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION2}\" refresh"
  [ "${POCDEFINITION3}" != "" ] && echo "==> Loading poc-definition 3"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION3}\" refresh"
  [ "${POCDEFINITION4}" != "" ] && echo "==> Loading poc-definition 4"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION4}\" refresh"
  [ "${POCDEFINITION5}" != "" ] && echo "==> Loading poc-definition 5"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION5}\" refresh"
  [ "${POCDEFINITION6}" != "" ] && echo "==> Loading poc-definition 6"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION6}\" refresh"
  [ "${POCDEFINITION7}" != "" ] && echo "==> Loading poc-definition 7"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION7}\" refresh"
  [ "${POCDEFINITION8}" != "" ] && echo "==> Loading poc-definition 8"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc repo define \"${POCDEFINITION8}\" refresh"
  echo "==> Prefetching all images and documentation"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command 'poc prefetch all'
  [ "${POCLAUNCH}" != "" ] && echo "==> Launching poc-definition"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "poc launch \"${POCLAUNCH}\""
#  [ "${FPSIMPLEMENU}" != "" ] && echo "==> Setting GUI-mode to simple"; gcloud compute ssh admin@${INSTANCENAME} --zone ${ZONE} --command "set gui simple ${FPSIMPLEMENU}"
  echo "==> End of Build phase <=="; echo ""
}

function gcpstart {
  FPPREPEND=$1
  ZONE=$2
  PRODUCT=$3
  INSTANCE=$4
  INSTANCENAME="fpoc-${FPPREPEND}-${PRODUCT}-${INSTANCE}"
  echo "==> Starting instance ${INSTANCENAME}"
  gcloud compute instances start ${INSTANCENAME} --zone=${ZONE}
}

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
type parallel > /dev/null 2>&1 || (echo "parallel command not installed";exit)
echo ""

# Check on first run and user specific defaults
# Chech if .fpoc directory exists, contains conf-file else create
[ ! -d ~/.fpoc/ ] && mkdir ~/.fpoc
eval GCPCMDCONF="~/.fpoc/gcpcmd.conf"
if [ ! -f $GCPCMDCONF ]; then
   echo "Welcome to Google Cloud Platform Command tool"
   echo "Looks like your first run or no defaults available. Let's set them!" 
   read -p "Provide your initials : " CONFINITIALS
   until [ ! -z $CONFREGION ]; do
      read -p "Provide your region 1) Asia, 2) Europe, 3) America : " CONFREGIONANSWER
      case $CONFREGIONANSWER in
         1) CONFREGION="asia-southeast1-b";;
         2) CONFREGION="europe-west4-a";;
         3) CONFREGION="us-central1-c";;
      esac
   done
   read -p "Provide GCP instance label F(irst)LASTNAME e.g. jdoe : " CONFGCPLABEL
   cat << EOF > $GCPCMDCONF
FPPREPEND="$CONFINITIALS"
ZONE="$CONFREGION"
LABELS="fortipoc=,$CONFGCPLABEL="
PRODUCT="test"
EOF
   echo ""
fi
source $GCPCMDCONF

# Check if build config file is provided
case $1 in
  -c)
    CONFIGFILE=$2
    if [ -e $CONFIGFILE ] && [ "$CONFIGFILE" != "" ]; then
      source $CONFIGFILE
    else
      echo "Config file not found. Example file written as fpoc-example.conf"
      cat << EOF > fpoc-example.conf
GCPPROJECT="cse-projects-202906"
MACHINETYPE="n1-standard-4"
FPIMAGE="fortipoc-1-7-2-clear"
LICENSESERVER="10.132.0.78"
LABELS="$LABELS"
FPSIMPLEMENU="enable"
# --- edits below this line ---
FPPREPEND="$FPPREPEND"
FPTRAILKEY='ES-xamadrid-201907:765eb11f6523382c10513b66a8a4daf5'
GCPREPO="fkemps"
POCDEFINITION1="poc/ferry/FortiWeb-Basic-solution-workshop-v2.2.fpoc"
POCDEFINITION2="poc/ferry/FortiWeb-Advanced-Solutions-Workshop-v2.5.fpoc"
POCDEFINITION3=""
POCDEFINITION4=""
POCDEFINITION5=""
POCDEFINITION6=""
POCDEFINITION7=""
POCDEFINITION8=""
POCLAUNCH="FortiWeb Basic solutions"
EOF
      exit
    fi
    shift; shift
    ;;
  -d | --delete-defaults) echo "Delete default user settings"
     rm $GCPCMDCONF
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
      echo "ARGUMENTS:"
      echo "       region  : asia, europe, america"
      echo "       product : fwb, fad, fpx, fsw, fsa, sme, xa, appsec, test"
      echo "       action  : build, start, stop, delete, list, listpubip"
      echo ""
   fi
   ;;
esac

# Populate given arguments
ARGUMENT1=$1
ARGUMENT2=$2
ARGUMENT3=$3

# Validate given arguments
case $ARGUMENT1 in
  europe) ZONE=${EUROPE};;
  asia) ZONE=${ASIA};;
  america) ZONE=${AMERICA};;
  list) echo "Using default settings"; ARGUMENT2=${PRODUCT}; ARGUMENT3="list";;
  listpubip) echo "Using default settings"; ARGUMENT2=${PRODUCT}; ARGUMENT3="listpubip";;
  *) echo "[UNKNOWN REGION] Specify: asia, europe  or america"; echo ""; exit;;
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
  list) echo "Using default settings"; ARGUMENT3="list";;
  listpubip) echo "Using default settings"; ARGUMENT3="listpubip";;
  *) echo "[UNKNOWN PRODUCT] Specify: fpx, fwb, fad, fsa, fsw, sme, xa, appsec, test"; exit;;
esac

case ${ARGUMENT3} in
  build) ACTION="build";;
  start) ACTION="start";;
  stop) ACTION="stop";;
  delete) ACTION="delete";;
  list) ACTION="list";;
  listpubip) ACTION="listpubip";;
  *) echo "[UNKNOWN ACTION] Specify: build, start, stop, delete, list or listpubip"; exit;;
esac

# 
clear
echo "---------------------------------------------------------------------"
echo "             FortiPoC management on Google Cloud Platform            "
echo "---------------------------------------------------------------------"
echo ""
# Create log directory if not exist
[ ! -d logs ] && mkdir logs
if  [[ $ACTION != list  &&  $ACTION != listpubip ]]
then
  read -p " Enter amount of FortiPoC's : " FPCOUNT
  read -p " Enter start of numbered range : " FPNUMSTART
  let --FPCOUNT
  let FPNUMEND=FPNUMSTART+FPCOUNT
  FPNUMSTART=`seq -w -f%03g ${FPNUMSTART} ${FPNUMSTART}` > /dev/null 2>&1
  FPNUMEND=`seq -w -f%03g ${FPNUMEND} ${FPNUMEND}` > /dev/null 2>&1

  echo ""
  read -p "Okay to ${ACTION} fpoc-$FPPREPEND-$PRODUCT-$FPNUMSTART till fpoc-$FPPREPEND-$PRODUCT-$FPNUMEND in region ${ZONE}.   y/n? " choice
  [ "${choice}" != "y" ] && exit
fi

echo "==> Lets go...using Zone=${ZONE}, Product=${PRODUCT}, Action=${ACTION}"; echo 

export -f gcpbuild gcpstart gcpstop gcpdelete
export CONFIGFILE GCPPROJECT FPIMAGE MACHINETYPE LABELS FPTRAILKEY FPPREPEND POCDEFINITION1 POCDEFINITION2 POCDEFINITION3 POCDEFINITION4 POCDEFINITION5 POCDEFINITION6 POCDEFINITION7 POCDEFINITION8 LICENSESERVER POCLAUNCH

case ${ACTION} in
  build)  parallel ${PARALLELOPT} gcpbuild  ${FPPREPEND} ${ZONE} ${PRODUCT} "${FPTITLE}" ::: `seq -w -f%03g ${FPNUMSTART} ${FPNUMEND}`;;
  start)  parallel ${PARALLELOPT} gcpstart  ${FPPREPEND} ${ZONE} ${PRODUCT} ::: `seq -w -f%03g ${FPNUMSTART} ${FPNUMEND}`;;
  stop)   parallel ${PARALLELOPT} gcpstop   ${FPPREPEND} ${ZONE} ${PRODUCT} ::: `seq -w -f%03g ${FPNUMSTART} ${FPNUMEND}`;;
  delete) parallel ${PARALLELOPT} gcpdelete ${FPPREPEND} ${ZONE} ${PRODUCT} ::: `seq -w -f%03g ${FPNUMSTART} ${FPNUMEND}`;;
  list) gcloud beta compute instances list --filter="name~fpoc-${FPPREPEND}-${PRODUCT}"| grep -e "NAME" -e "${ZONE}";;
  listpubip) gcloud beta compute instances list --filter="name~fpoc-${FPPREPEND}-${PRODUCT}"| grep -e "${ZONE}" | awk '{ printf $5 " " }';;
esac
