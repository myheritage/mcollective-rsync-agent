# Rsync Agent
The Rsync agent lets you send an mco command to server and initiate an rsync process **from** centralized location.
It uses the rsync command (and hence needs to be installed on the remote server).
It does NOT handle authentication, this should be done with parameters/ssh keys

## Installation

Follow the [basic plugin install guide](http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/InstalingPlugins).

## Usage
``` bash
mco rsync -s|--source <SOURCE> -d|--destination <DESTINATION> [-o|--rsync_opts <OPTIONS>] [-a|--atomic]

The OPTIONS can be one of the following:
  -s | --source SOURCE    - Source location of the rsync
  -d | --destination DEST - destination folder of the rsync
  -o | --rsync_opts       - Rsync options
  -p | --rsync_proxies    - Proxies to pick from and use for the rsync
  -a | --atomic           - Use atomic update
```
### Flags:
 + --source - As described, source location, can be remote, can be local. if remote, it should 
  be compatible to the source option in the rsync command itself
 + --destination - Same as source
 + --rsync_opts - Defaults to -avr, additinal options for the rsync command. if rsync over ssh, you can use here private key etc
 + --rsync_proxies - Since the rsync can be heavy on the network, it allows specifying comma delimited list of proxy URLS, and each 
  node will pick 1 randomally to use for the transfer
 + --atomic - When used, the target will be changed to include an epoch time. when the rsync will be completed, the node
  will transfer the symlink to make the whole process as a atomic as possible. --atomic will also add "---link-dest" to the options
 

Example:
```
% mco rsync -s user1@source:/some_dir/ -d /target -o '--delay-updates -avr --delete --delay-updates -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"'

 * [ ============================================================> ] 4 / 4

Sending rsync command to servers
node1                   : Rsync completed
node2                   : Rsync completed
```

Example 2: (With --atomic)
```
% mco rsync --atomic -s user1@source:/some_dir/ -d /dir/target -o '--delay-updates -avr --delete --delay-updates -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"'

 * [ ============================================================> ] 4 / 4

Sending rsync command to servers
node1                   : Rsync completed
node2                   : Rsync completed
```

In the end, you will have on the node:
```
% ll /dir
lrwxrwxrwx  1 user     group   41 Jul  1 04:43 target -> /dir/target_1435740324
drwxr-sr-x 14 user     group  4096 Jun 30 17:56 target_1435740324

```
After the next one, you will have:
```
% ll /dir
lrwxrwxrwx  1 user     group   41 Jul  1 04:43 target -> /dir/target_1435741156
drwxr-sr-x 14 user     group  4096 Jun 30 17:56 target_1435741156