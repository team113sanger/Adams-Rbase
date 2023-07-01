#!/bin/bash

set -uxe
set -o pipefail

(cd /tmp && sudo rm -rf gitflow && git clone https://github.com/datasift/gitflow && cd gitflow && sudo ./install.sh && sudo git hf upgrade)
sudo rm -rf /tmp/gitflow

set +e
# this fails if unstaged changes, however they should only exist when resuming
git hf init -f

# singularity install for debugging
cd /tmp
sudo apt-get update -y
sudo apt-get install -y alien
wget https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/s/singularity-ce-3.11.4-1.el7.x86_64.rpm
sudo alien -d singularity-ce-3.11.4-1.el7.x86_64.rpm
sudo apt-get install -y ./singularity-ce_3.11.4-2_amd64.deb
rm -rf singularity-ce-3.11*
cd -
