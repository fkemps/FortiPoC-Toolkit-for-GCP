# FortiPoC-mgt-GCP
Manage and configure FortiPoC instances on Google Cloud Platform (GCP).
These scripts allow you to manage the workload of creating, configuring and deleting FortiPoc's in a consitent and easy way.

The scripts will allow you to:

* **Handle GCP instances**: Build, Start, Stop, Delete, list (gcpcmd.sh)
* **Tweak FortiPoC**: config changes available per FortiPoC CLI (fpoc-to-all.sh)

## Prerequisites

You will need to arrange GCP account and prepare your local environment

* Active GCP account
* Subscription to your private or company project (billing)
* Computer system capable of running bash shell e.g. Linux, MacOs or Windows + Cygwin/Bash-on-Windows10
* Locally installed `GCP SDK` ([Installing Google Cloud SDK](https://cloud.google.com/sdk/install))
* Locally installed program `parallel` ([Install parallel on Mac OSX](http://macappstore.org/parallel/))

## Obtaining Scripts

You can obtain the latest scripts versions from Gitbub.

## Install

No package installation is needed besides those listed in prerequisites section.
Pull the environment from git or unzip in your prefered working directory.

## Configure

Configuration is embeded in gcpcmd.sh and will happen on first execution, or after gcpcmd.sh -d | --delete-config.   
User default settings will be stored in ~/.fpoc/gcpcmd.conf

To create an example config file you can issue ./gcpcmd.sh -c. This will create a fpoc-example.conf template file which can be use to create workload specific config files. Copy fpoc-example.conf to conf directory with an descriptive name for your workload. You will need this file for the Build option via -c conf/fpoc-fwb-workshop.conf as an example.

```
# Uncomment and speficy to override user defaults
#GCPPROJECT="cse-projects-xxxxxx"
#FPPREPEND="fl"
#LABELS="fortipoc=,flastname="
#LICENSESERVER="10.1.1.1"

# --- edits below this line ---
# Specify FortiPoC instance details.
MACHINETYPE="n1-standard-4"
FPIMAGE="fortipoc-1-7-2-clear"
#FPSIMPLEMENU="enable"
FPTRAILKEY='ES-xamadrid-201907:765eb11f6523382c10513b66a8a4daf5'
#GCPREPO="flastname"
POCDEFINITION1="poc/ferry/FortiWeb-Basic-solution-workshop-v2.2.fpoc"
#POCDEFINITION2="poc/ferry/FortiWeb-Advanced-Solutions-Workshop-v2.5.fpoc"
#POCDEFINITION3=""
#POCDEFINITION4=""
#POCDEFINITION5=""
#POCDEFINITION6=""
#POCDEFINITION7=""
#POCDEFINITION8=""
#POCLAUNCH="FortiWeb Basic solutions"
```

## Directory and file

The directory structure and file explained

```
 0 drwxr-xr-x  15 fkemps  staff   480B Nov  1 16:22 conf                   << Directory holding fpoc-xxxxx.conf files
 8 -rw-r--r--   1 fkemps  staff   587B Nov  1 16:41 fpoc-example.conf      << Config example created by -c option
16 -rwxr-xr-x   1 fkemps  staff   5.2K Nov  1 16:10 fpoc-to-all.sh         << FortiPoC config tweaking script
32 -rwxr-xr-x   1 fkemps  staff    12K Nov  1 16:40 gcpcmd.sh              << Handling instances on GCP
 0 drwxr-xr-x  30 fkemps  staff   960B Nov  1 21:29 logs                   << Directory holding build log files
```
## Managing FortiPoC instances

To control the FortiPoC instances you can use the `gcpcmd.sh` script. This allows you to Build, Start, Stop, Delete and list FortiPoC instances.

Building will be fully automatic per provided config file and FortiPoC will be running with PoC-definitions loaded and VMimages prefetched including the documentation.

```
(Version: 2019111101)
Default deployment region: europe-west4-a
Personal instance identification: fk
Default product: test

Usage: ./gcpcmd.sh [-c configfile] <region> <product> <action>
       ./gcpcmd.sh [-c configfile] [region] [product] list
       ./gcpcmd.sh [-c configfile] [region] [product] listpubip
OPTIONS:
        -d    --delete-config     Delete default user config settings
ARGUMENTS:
       region  : asia, europe, america
       product : fwb, fad, fpx, fsw, fsa, sme, xa, appsec, test
       action  : build, start, stop, delete, list, listpubip

[UNKNOWN REGION] Specify: asia, europe  or america
```

**Disclaimer**   
*Nothing contained in this article is intended to teach or encourage the use of security tools or methodologies for illegal or unethical purposes. Always act in a responsible manner. Make sure you have written permission from the proper individuals before you use any of the tools or techniques described here outside this environment.*
