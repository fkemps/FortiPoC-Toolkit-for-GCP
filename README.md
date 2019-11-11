# FortiPoC-mgt-GCP
Management of FortiPoC on Google Cloud Platform
To easily handle FortiPoC workload on Google Cloud Platform (GCP) you can use these tools (scripts).

This will allow you to:

* **Handle GCP instances**: Build, Start, Stop, Delete, list
* **Tweak FortiPoC**: config changes available per FortiPoC CLI

## Prerequisites

You will need to arrange GCP account and prepare your local environment

* Active GCP account
* Subscription to company project or your private project (billing)
* Locally installed `GCP SDK` ([Installing Google Cloud SDK](https://cloud.google.com/sdk/install))
* Locally installed program `parallel` ([Install parallel on Mac OSX](http://macappstore.org/parallel/))

###Obtaining Scripts

You can obtain the latest scripts from Gitbub via `command to pull`.

description

###Configure

Configuration description

###Directory and file

The directory structure and file explained

```
 0 drwxr-xr-x  15 fkemps  staff   480B Nov  1 16:22 conf                   << Directory holding fpoc-xxxxx.conf files
 8 -rw-r--r--   1 fkemps  staff   587B Nov  1 16:41 fpoc-example.conf      << Config example created by -c option
16 -rwxr-xr-x   1 fkemps  staff   5.2K Nov  1 16:10 fpoc-to-all.sh         << FortiPoC config tweaking script
32 -rwxr-xr-x   1 fkemps  staff    12K Nov  1 16:40 gcpcmd.sh              << Handling instances on GCP
 8 -rw-r--r--   1 fkemps  staff   160B Nov  1 14:24 logfile-20191030094853 << Put files from gcpcmd.sh
 8 -rw-r--r--   1 fkemps  staff   140B Nov  1 14:24 logfile-20191030145519 << Put files from gcpcmd.s
```


To control the FortiPoC instances you can use the `gcpcmd.sh` script. This allows you to Build, Start, Stop, Delete and list FortiPoC instances.

Building will be fully automatic per provided config file and FortiPoC will be running with PoC-definitions loaded and VMimages prefetched including the documentation.



```
$ ./gcpcmd.sh

(Version: 2019102301)
Default deployment region: europe-west4-a
Personal instance identification: fk
Default product: test

Usage: ./gcpcmd.sh [-c configfile] <region> <product> <action>
       ./gcpcmd.sh [-c configfile] [region] [product] list
       ./gcpcmd.sh [-c configfile] [region] [product] listpubip
Options:
       region  : asia, europe, america
       product : fwb, fad, fpx, fsw, fsa, sme, xa, appsec, test
       action  : build, start, stop, delete, list, listpubip

[UNKNOWN REGION] Specify: asia, europe  or america
```

### Creating config file

To generate the config template which you can tweak and copy issue the command `./gcpcmd.sh -c`. This will create in your current directory the template file called `fpoc-example.conf`.

Edit this file to your needs, supported parameters are:

```
GCPPROJECT="<your GCP project name>"
MACHINETYPE="<GCP machind type>"
FPIMAGE="<fortipoc-image>"
LICENSESERVER="<IP-address of license server on GCP"
LABELS="fortipoc=,<your-name>="
FPSIMPLEMENU="enable|disable"
# --- edits below this line ---
FPPREPEND="<your initials>"
FPTRAILKEY='<your FortiPoC trail license'
GCPREPO="<additional private repository>"
POCDEFINITION1="<reference to POC-definition>"
POCDEFINITION2=""
POCDEFINITION3=""
POCDEFINITION4=""
POCDEFINITION5=""
POCDEFINITION6=""
POCDEFINITION7=""
POCDEFINITION8=""
POCLAUNCH="<Name of PoC to launch after build>"
```

### Set your defaults

You can set some defaults in the `gcpcmd.sh` script to simplify usage, avoid conflicts with others and make your (and others) life easier.

```
# Your default personal settings. Can be overwritten with -c config option
FPPREPEND="fk"
ZONE=$EUROPE
PRODUCT="test"
```



**Disclaimer**   
*Nothing contained in this article is intended to teach or encourage the use of security tools or methodologies for illegal or unethical purposes. Always act in a responsible manner. Make sure you have written permission from the proper individuals before you use any of the tools or techniques described here outside this environment.*
