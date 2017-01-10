# robotdev
## Docker file to build robot developing environment image

* Ubuntu 14.04 64bits
* Build player from svn latest
* Build stage from git latest
* Install sshd for x forwarding (we need GUI to show simulator's window)
* Add user docker/docker for ssh
* Put public key in authorized_keys to password-less login with ssh

#### Find docker image here: https://hub.docker.com/r/titanzhang/robotdev/
