# FortiPoC Toolkit for Google Cloud Platform

<p align="center">
  <img width="314" height="375" src="img/FortiPoConGCP.png">
</p>

Manage and configure FortiPoC instances on Google Cloud Platform (GCP).
This toolkit (scripts) allow you to manage the workload of creating, configuring and deleting FortiPoc's in a consitent and easy way.

The toolkit allows you to:

* **Handle GCP instances**: Build, Clone, Delete, Change Machine-type, List, Listpubip, Start, Stop (gcpcmd.sh)
* **Tweak FortiPoC's**: Make config changes on FortiPoC's (fpoc-to-all.sh)

![](img/FortiPoCflow.png)

## Prerequisites
You will need access to GCP and prepare your local environment

* Active GCP account
* Subscription to your private or company project (billing)
* Computer system capable of running bash shell e.g. Linux, MacOs or Windows + Cygwin/Bash-on-Windows10
* Locally installed `GCP SDK` ([Installing Google Cloud SDK](https://cloud.google.com/sdk/install))
* Locally installed program `parallel` ([Install parallel on Mac OSX](http://macappstore.org/parallel/)) (Linux: apt install parallel)
* Locally installed program `jq` ([Install jq on Mac OSX](https://brewinstall.org/install-jq-on-mac-with-brew/)) (Linux: apt install jq)

## Obtaining Scripts
You can obtain the latest releases of the scripts from GitHub.

## Install
No package installation is needed besides those listed in prerequisites section.
Pull the environment with `git clone https://github.com/fkemps/FortiPoC-Toolkit-for-GCP.git` in your prefered working directory.

Make sure you properly install the needed programs and do basis setup:

* `gcloud init`, and logout/login
* `parallel --citation`, and enter `will cite`

### Directory and file
The directory structure and files explained

```
 0 drwxr-xr-x  15 fkemps  staff   480B Nov  1 16:22 conf                   << Directory holding fpoc-xxxxx.conf files
 8 -rw-r--r--   1 fkemps  staff   587B Nov  1 16:41 fpoc-example.conf      << Config example created by -b option
16 -rwxr-xr-x   1 fkemps  staff   5.2K Nov  1 16:10 fpoc-to-all.sh         << FortiPoC config tweaking script
32 -rwxr-xr-x   1 fkemps  staff    12K Nov  1 16:40 gcpcmd.sh              << Handling instances on GCP
 0 drwxr-xr-x  30 fkemps  staff   960B Nov  1 21:29 logs                   << Directory holding build log files
```

### Google Cloud Plaftorm preparation
**FortiPoC VM image**   
If you need to deploy your FortiPoC in a GCP project where the FortiPoC image is not available yet, you need to type the commands below because GCP only accepts tar.gz of a raw disk.

```
qemu-img dd -f vmdk -O raw bs=4M count=1K if=fortipoc.vmdk of=disk.raw
tar -cvzf fortipoc-VER.tar.gz disk.raw
gsutil cp fortipoc-VER.tar.gz gs://YOUR_BUCKET/
gcloud compute images create fortipoc-VER \
  --project=YOUR_PROJECT \
  --source-uri gs://YOUR_BUCKET/fortipoc-VER.tar.gz \
  --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx" \
  --family fortipoc
```

To start FortiPoC in GCP you need either to add an extra disk or to tell GCP that you want to extend the 4GB base image to the size you need (64GB is a minimum). The second solution is easier if you plan to build golden images of your PoCs.

Alternatively you could ask me for an image to upload to GCP.

Create a compute image per:

```
gcloud compute images create "fortipoc-1714-test" --project=project-name \
--source-uri gs://fortipoc_bucket/fortipoc-1.7.14-clear.tar.gz \
--licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx" --family fortipoc
```

**Security**   
To allow controlled access to the FortiPoC instances we protect it with firewall-rules. Make sure default access (HTTP, HTTPS) to your instances is disabled. Only source IP-addressess listed on `workshop-source-networks` are allowed.

* Create a VPC Network > Firewall object called "workshop-source-networks” and allow tcp:22,80,443,514,8000,8080,8888,10000-20000,22222

# Handle GCP Instanced (*gcpcmd.sh*)

### Configure
Configuration is embeded in gcpcmd.sh and will happen on first execution, or after `gcpcmd.sh -d | --delete-config`.   
User default settings will be stored in `~/.fpoc/gcpcmd.conf`

* Your **GCP Project ID** can obtain via `gcloud projects list` and listed as PROJECT_ID.

```
Welcome to FortiPoc Toolkit for Google Cloud Platform
This is your first time use of gcpcmd.sh and no preferences are set. Let's set them!
Provide your initials e.g. fl : fl
Provide your name to lable instanced e.g. flastname : flastname.    <<===firstname letter + lastname
Provide a groupname for shared instances (optional) :
Provide your region 1) Asia, 2) Europe, 3) America : 2
Provide your GCP billing project ID [cse-projects-000000] :
Provide your GCP service account (only one if multiple shown) [00000000-compute@developer.gserviceaccount.com] :
IP-address of FortiPoC license server (if available) :
Provide your SSH public key for FortiPoC access [ssh-rsa <value>] :
```

### Build Config Template
To create an example config file you can issue `./gcpcmd.sh -b`. This will create a fpoc-example.conf template file which can be use to create workload specific config files.

Copy fpoc-example.conf to conf directory with an descriptive name for your workload. You will need this file for the Build option via -b conf/fpoc-fwb-workshop.conf as an example.

```
# Uncomment and speficy to override user defaults
#GCPPROJECT="cse-projects-000000"
#GCPSERVICEACCOUNT="000000000-compute@developer.gserviceaccount.com"
#FPPREPEND="fl"
#LABELS="fortipoc=,owner=flastname"
#LICENSESERVER=""

# --- edits below this line ---
# Specify FortiPoC instance details.
MACHINETYPE="n1-standard-4"
FPIMAGE="fortipoc-1-7-14-clear"
#FPSIMPLEMENU="enable"
FPTRAILKEY='ES-xamadrid-201907:765eb11f6523382c10513b66a8a4daf5'
#GCPREPO=""
#FPGROUP="flastname"
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

* The POCDEFINITION name can be obtained from the available POC-definitions on the repositories.

![POC-definition name](img/poc-definition-name.png)

## Managing FortiPoC instances
To control the FortiPoC instances you can use the `gcpcmd.sh` script.   
This allows you to **Build**, **Clone**, **Start**, **Stop**, **Delete** and **list** FortiPoC instances.

`./gcpcmd.sh`

```
 _____          _   _ ____              _____           _ _    _ _      __               ____  ____ ____
|  ___|__  _ __| |_(_)  _ \ ___   ___  |_   _|__   ___ | | | _(_) |_   / _| ___  _ __   / ___|/ ___|  _ \
| |_ / _ \|  __| __| | |_) / _ \ / __|   | |/ _ \ / _ \| | |/ / | __| | |_ / _ \|  __| | |  _| |   | |_) |
|  _| (_) | |  | |_| |  __/ (_) | (__    | | (_) | (_) | |   <| | |_  |  _| (_) | |    | |_| | |___|  __/
|_|  \___/|_|   \__|_|_|   \___/ \___|   |_|\___/ \___/|_|_|\_\_|\__| |_|  \___/|_|     \____|\____|_|

(Version: 2021061601)
Default deployment region: europe-west4-a
Personal instance identification: fk
Default product: test

Usage: ./gcpcmd.sh [OPTIONS] [ARGUMENTS]
      ./gcpcmd.sh [OPTIONS] <region> <product> <action>
      ./gcpcmd.sh [-b configfile] <region> <product> build
      ./gcpcmd.sh [OPTIONS] [region] [product] list
      ./gcpcmd.sh [OPTIONS] [region] [product] listpubip
OPTIONS:
       -b    --build-file                     File for building instances. Leave blank to generate example
       -d    --delete-config                  Delete default user config settings
       -g    --group                          Group name for shared instances
       -i    --initials                       Specify intials on instance name for group management
       -ia   --ip-address-add [IP-address]    Add current public IP-address to GCP ACL
       -ir   --ip-address-remove [IP-address] Remove current public IP-address from GCP ACL
       -il   --ip-address-list                List current public IP-address on GCP ACL
       -p    --preferences                    Show personal config preferences
       -lg   --list-global                    List all your instances globally
ARGUMENTS:
      region  : america, asia, europe
      product : appsec, fad, fpx, fsa, fsw, fwb, sme, test, xa or <custom-name>
      action  : build, clone, delete, list, machinetype, listpubip, start, stop
                action build needs -b configfile. Use ./gcpcmd.sh -b to generate fpoc-example.conf
```

### Build
Building will be fully automatic per specified config file. Each FortiPoC will be provisioned in parallel and download all needed VM-images and documentation. This will cause a high download on FortiPoC repository and the more you deploy in parallel the longer it will take. Advice is to not provision more then 10 simultaniously. Do it in batches or build just one and use the `clone` function to duplicate which will be much faster.

Good practice is to have a config file per environment e.g. testing, workshop, seminars, products or solutions. For example `conf/fpoc-apac-se-fwb-ws.conf`, `conf/fpoc-emea-xa-fad-ws.conf`, `conf/fpoc-appsecc-demo.conf`.

FortiPoC's will be running with e.g. PoC-definitions loaded, VM-images and documentation prefetched, guest/guest account enabled, GUI title set and optionally a PoC-definition launched.

`./gcpcmd.sh -b conf/fpoc-test.conf europe test build`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

 Enter amount of FortiPoC's : 3
 Enter start of numbered range : 1

Okay to build fpoc-fk-test-001 till fpoc-fk-test-003 in region europe-west4-a.   y/n? y
==> Lets go...using Owner=fkemps or Group=fkemps, Zone=europe-west4-a, Product=test, Action=build
==> Sleeping 1s seconds to avoid GCP DB locking
==> Creating instance fpoc-fk-test-003
NAME              ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
fpoc-fk-test-003  europe-west4-a  n1-standard-4               10.164.0.64  34.90.88.37  RUNNING

==> Sleeping 90 seconds to allow FortiPoC booting up
fpoc-fk-test-003 = 34.90.88.37
FortiPoC fpoc-fk-test-003 on 34.90.88.37 reachable
==> Registering FortiPoC
Boot installation:
1/ Preparing host
2/ Mounting disks
- Preparing resources disk
- Preparing local repository
- Enabling SWAP
3/ Validating DB
- Building en_US locale(s)
- Set default LANG to en_US.UTF-8
- Migrating
- Preparing default values
- Apply default settings
- Generating default configuration
- Defining users permissions
- Analyzing host hardware
  synciface
  hoststate
  virtcpu
  complete
4/ Enabling interfaces
- Enabling /etc/network/interfaces.d/eth0
5/ Enabling WebUI
- Start WebUI
6/ L0 Hypervisor tasks
registered
==> Setting title
==> Setting licenseserver
==> Prefetching all images and documentation
==> End of Build phase <==
<other output skipped>
```

Output for all FortiPoC builds will by provided once finished build phase.

### List
Full overview of FortiPoC's can be obtained with **list** function. Specify *region*, *product* and *list*.

`/gcpcmd.sh europe test list`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

==> Lets go...using Owner=fkemps or Group=fkemps, Zone=europe-west4-a, Product=test, Action=list

NAME              ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
fpoc-fk-test-001  europe-west4-a  n1-standard-4               10.164.0.66  34.90.107.239  RUNNING
fpoc-fk-test-002  europe-west4-a  n1-standard-4               10.164.0.65  34.90.90.164   RUNNING
fpoc-fk-test-003  europe-west4-a  n1-standard-4               10.164.0.64  34.90.88.37    RUNNING
```

FortiPoC IP-addresses can be obtained to use for `fpoc-to-all.sh` usage.

`./gcpcmd.sh europe test listpubip`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

==> Lets go...using Owner=fkemps or Group=fkemps, Zone=europe-west4-a, Product=test, Action=listpubip

34.90.107.239 34.90.90.164 34.90.88.37
```


### Clone
The clone function allows you to clone a FortiPoC (GCP instance) one or multiple times in parallel. The operational state of FortiPoC doesn't matter, it can be `Terminated` or `Running` for example. If you're *"better safe than sorry"* then first stop the FortiPoC instance you whish to clone.

You can use first the `build` function to provision a FortiPoC, tweak as wanted with `fpoc-to-all.sh` and clone it to the amount you need. Use `list` function to see which FortiPoC instances are available to clone and their numbering.

`./gcpcmd.sh europe test clone`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

 FortiPoC instance number to clone : 1
 Enter amount of FortiPoC's clones : 15
 Enter start of numbered range : 2

Okay to clone fpoc-fk-test-001 to fpoc-fk-test-002 till fpoc-fk-test-016 in region europe-west4-a.   y/n?
Do you want to create a fresh snapshot? (If no, latest snapshot will be used if available) y/n:
Creating snapshot(s) fpoc-fk-test...done.
==> Lets go...using Zone=europe-west4-a, Product=test, Action=clone

==> Sleeping 6s seconds to avoid GCP DB locking
==> Cloning instance fpoc-fk-test-001 to fpoc-fk-test-002
==> Creating disk for fpoc-fk-test-002
NAME              ZONE            SIZE_GB  TYPE         STATUS
fpoc-fk-test-002  europe-west4-a  200      pd-standard  READY
==> Create instance fpoc-fk-test-002
NAME              ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
fpoc-fk-test-002  europe-west4-a  n1-standard-4               10.164.0.38  34.90.151.94  RUNNING
```

### Start / Stop

`./gcpcmd.sh europe test start` or `./gcpcmd.sh europe test stop`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

 Enter amount of FortiPoC's : 2
 Enter start of numbered range : 1

Okay to stop fpoc-fk-test-001 till fpoc-fk-test-002 in region europe-west4-a.   y/n? y
==> Lets go...using Zone=europe-west4-a, Product=test, Action=stop

==> Stopping instance fpoc-fk-test-001
Stopping instance(s) fpoc-fk-test-001...
..............................................................................................................................................................................................................................done.
Updated [https://compute.googleapis.com/compute/v1/projects/cse-projects-202906/zones/europe-west4-a/instances/fpoc-fk-test-001].
==> Stopping instance fpoc-fk-test-002
Stopping instance(s) fpoc-fk-test-002...
..........................................................................................................................................................................................................................................done.
Updated [https://compute.googleapis.com/compute/v1/projects/cse-projects-202906/zones/europe-west4-a/instances/fpoc-fk-test-002].
```

### Delete

`./gcpcmd.sh europe test delete`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

 Enter amount of FortiPoC's : 3
 Enter start of numbered range : 1

Okay to delete fpoc-fk-test-001 till fpoc-fk-test-003 in region europe-west4-a.   y/n? y
==> Lets go...using Zone=europe-west4-a, Product=test, Action=delete

==> Deleting instance fpoc-fk-test-002
The following instances will be deleted. Any attached disks configured
 to be auto-deleted will be deleted unless they are attached to any
other instances or the `--keep-disks` flag is given and specifies them
 for keeping. Deleting a disk is irreversible and any data on the disk
 will be lost.
 - [fpoc-fk-test-002] in [europe-west4-a]

Do you want to continue (Y/n)?
Deleted [https://www.googleapis.com/compute/v1/projects/cse-projects-202906/zones/europe-west4-a/instances/fpoc-fk-test-002].
==> Deleting instance fpoc-fk-test-001
The following instances will be deleted. Any attached disks configured
 to be auto-deleted will be deleted unless they are attached to any
other instances or the `--keep-disks` flag is given and specifies them
 for keeping. Deleting a disk is irreversible and any data on the disk
 will be lost.
 - [fpoc-fk-test-001] in [europe-west4-a]

Do you want to continue (Y/n)?
Deleted [https://www.googleapis.com/compute/v1/projects/cse-projects-202906/zones/europe-west4-a/instances/fpoc-fk-test-001].
==> Deleting instance fpoc-fk-test-003
The following instances will be deleted. Any attached disks configured
 to be auto-deleted will be deleted unless they are attached to any
other instances or the `--keep-disks` flag is given and specifies them
 for keeping. Deleting a disk is irreversible and any data on the disk
 will be lost.
 - [fpoc-fk-test-003] in [europe-west4-a]

Do you want to continue (Y/n)?
Deleted [https://www.googleapis.com/compute/v1/projects/cse-projects-202906/zones/europe-west4-a/instances/fpoc-fk-test-003].
```

#### Machinetype

You can change the machine-type to adjust CPU/Memory of the instance on GCP.

`./gcpcmd.sh europe test machinetype`

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

 Enter amount of FortiPoC's : 20
 Enter start of numbered range : 1
 select machine-type : 1) n1-standard-1, 2) n1-standard-2, 3) n1-standard-4, 4) n1-standard-8, 5) n1-standard-16 : 2

Okay to machinetype fpoc-fk-test-001 till fpoc-fk-test-020 in region europe-west4-a.   y/n?
```

#### Allow / Deny access to FortiPoC
The FortiPoC's deployed are by default **not** reachable from the internet.   
You can allowed/denied access to the FortiPoC's by simply running `gcpcmd.sh -ip-address-add` or `gcpcmd.sh --ip-address-remove` respectively while you're connected onto the location network. It will automatically obtain your public IP-address and add/remove it to the GCP firewall rule-set.

`./gcpcmd.sh --ip-address-add`

By adding [IP-ADDRESS] argument you can specify which IP-address to add/remove.

`./gcpcmd.sh --ip-address-add 10.1.1.1`

```
Adding public-ip 10.1.1.1 to GCP ACL to allow access from this location
Updated [https://www.googleapis.com/compute/v1/projects/cse-projects-202906/global/firewalls/workshop-source-networks].
Current GCP ACL list
80.60.25.77/32
121.7.171.108
94.210.222.83
87.69.50.141
88.151.153.107
109.144.211.50
88.151.153.101
195.228.28.243
85.88.130.222
193.126.247.194
62.48.251.38
195.76.37.24
146.88.49.66
91.126.136.150
91.126.136.155
219.74.227.60
82.217.133.158
85.88.152.134
85.138.76.14
188.37.53.177
77.54.220.220
62.28.181.26
85.139.134.54
118.201.61.6
146.185.63.130
85.251.147.205
203.172.126.3
10.1.1.1
```

To retrieve the public IP-addresses on the GCP ACL you can use

`./gcpcmd.sh --ip-address-list`

```
Listing public-ip addresses on GCP ACL
80.60.25.77/32
121.7.171.108
94.210.222.83
87.69.50.141
88.151.153.107
109.144.211.50
88.151.153.101
195.228.28.243
85.88.130.222
193.126.247.194
62.48.251.38
195.76.37.24
146.88.49.66
91.126.136.150
91.126.136.155
219.74.227.60
82.217.133.158
85.88.152.134
85.138.76.14
188.37.53.177
77.54.220.220
85.139.134.54
118.201.61.6
146.185.63.130
85.251.147.205
203.172.126.3
10.1.1.1
```

#### List all your instances
`./gcpcmd.sh --list-global` will list all your instances of which you're the owner.

```
---------------------------------------------------------------------
             FortiPoC Toolkit for Google Cloud Platform
---------------------------------------------------------------------

Listing all global instances for owner:fkemps or group:fkemps

NAME              ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
fpoc-fk-test-001  europe-west4-a  n1-standard-4               10.164.0.60  34.90.228.152  RUNNING
fpoc-fk-test-002  europe-west4-a  n1-standard-4               10.164.0.59  34.90.81.85    RUNNING
```

#### Manage your instances with a group
`./gcpcmd.sh --group <groupname>` allows you to view, control and build instances with a group label.   
The `-g` ro `--group` option can be specified after gcpcmd.sh command in any order and will override the stored perferences and config-template group definition.
Order of group preferences is personal, config-template and command-option.

---

# Tweaking FortiPoC Settings (*fpoc-to-all.sh*)
Settings of running FortiPoC instances can be tweaked in a consistend and automated way.

The `fpoc-to-all.sh` script allows you to issue CLI commands on a single or multiple FortiPoC's.

```
(Version: 2019110802)
Usage: ./fpoc-to-all.sh OPTION

OPTION: -a    --address       Excute commands on FortiPoCs with IP-address 192.168.254.1 or via "192.168.254.2 192.168.254.3" space delimitted
        -h    --help          Show script usage and option
        -e    --execute       Execute commands on FortiPoC with IP-addresses inside fpoc-to-all.sh
        -r    --review        Review commands before executing on FortiPoC CLI
```

What works good (best practices) is a three step approach:

1. Upload your SSH public-key to all FortiPoC's
2. Validate access per SSH public-key authentication
3. Changes admin password to prevent attendees mess around with your FortiPoC.    Attendees can get access per `guest/guest` and are provided the simple menu

The above steps are part of `fpoc-to-all.sh` automated execution.

### FortiPoC targets (IP-addresses)

`-a | --address` option allows you to execute commands on provide dynamically the list of FortiPoC's.   

Use the `gcpcmd.sh <region> <product> listpubip` to generate the list of IP-addresses for the `-a | --address` option.

Alternatively you can statially provide the list by editing *fpoc-to-all.sh* script and define them in `"IPADDRESS="` parameter.

`-e | --execute` option will execute the commands on FortiPoC's.

`-r | --review` option to review the CLI command to be executed on FortiPoC's.

### Review & Executing Commands

First you need to do the Steps 1, 2 and 3 by uncommenting the "echo" lines as described in the `fpoc-to-all.sh` script.

`./fpoc-to-all.sh --review`

```
----------------- Executing commands on FortiPoCs --------------------------
echo "Adding SSK-keys"; sshfpoc 'set ssh authorize keys "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNJYNMdL9o1Xt3ADg1DCOBhp8Vvr6eX8KGOK9tpqYH8Q6yW6Y1ARzDwqytg2zacRqwwZdpelEQ2vc9Kd4xsYA2Ds/OvUhwxJ1mPr5AVaqy6UxmkSU4fIQaIwkBgfaVxxntND8WRQVbjvkvlfoVBel93yz4jYcUDG0wsBNawuMS2BYHXDWb+w5RtEtkWf1cGfzHVSQSrhmk1uFFXMhFY95t9b1mMgroZqYkYaYb1sxmOxnQTQwC1J5Hf8LajXAMPV9br523mCXpJ5aeD+1T1706XM8EikT9JHDhgnqyTLMf8FAdaetT2fju2FZ9WnmHM2V3wQnC0t0QIuoYgEnZlQND fkemps@Ferrys-MacBook-Pro.local"'
echo "Validating access"; sshfpoc 'exit'
echo "Changing admin pwd"; sshfpoc 'set passwd f0rt1n3t2019'
----------------------------------------------------------------------------
```

`./fpoc-to-all.sh --address "35.204.64.17 34.90.183.89"`

```
---------------- Start of actions on FortiPoC - Fri Nov 15 13:51:37 CET 2019  ---------------------
Executing on targets 35.204.64.17 34.90.183.89

======== FortiPoC on IP : 35.204.64.17 ========= FPOC: 1
Adding SSK-keys
Warning: Permanently added '35.204.64.17' (ECDSA) to the list of known hosts.
Validating access
Changing admin pwd

======== FortiPoC on IP : 34.90.183.89 ========= FPOC: 2
Adding SSK-keys
Warning: Permanently added '34.90.183.89' (ECDSA) to the list of known hosts.
Validating access
Changing admin pwd
```

There after you can re-use the example commands in the file by uncommenting the lines containing `sshfpoc` for `sshfpocparallel` or write your own.

* `sshfpoc` will execute and will wait for FortiPoC to finish

* `sshpocparallel` will execute and will immediately return and put the execution in the background. This is especially welcome in launching POC-definitions as they take couple of minutes.

For example setting the timezone. Uncomment the line `echo "Setting timezone"; sshfpoc 'set timezone Europe/Amsterdam'`

`./fpoc-to-all.sh --review`

```
----------------- Executing commands on FortiPoCs --------------------------
echo "Setting timezone"; sshfpoc 'set timezone Europe/Amsterdam'
----------------------------------------------------------------------------
```

`./fpoc-to-all.sh --address "35.204.64.17 34.90.183.89"`

```
---------------- Start of actions on FortiPoC - Fri Nov 15 14:01:30 CET 2019  ---------------------
Executing on targets 35.204.64.17 34.90.183.89

======== FortiPoC on IP : 35.204.64.17 ========= FPOC: 1
Setting timezone

======== FortiPoC on IP : 34.90.183.89 ========= FPOC: 2
Setting timezone

---------------- End of actions on FortiPoC - Fri Nov 15 14:01:37 CET 2019  ---------------------
```


**Disclaimer**   
*Nothing contained in this article is intended to teach or encourage the use of security tools or methodologies for illegal or unethical purposes. Always act in a responsible manner. Make sure you have written permission from the proper individuals before you use any of the tools or techniques described here outside this environment.*
