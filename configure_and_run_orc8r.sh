#!/bin/bash

set -x

chmod a+x ./orc8r_prereqs.sh
chmod a+x ./orc8r_installation.sh

bash ./orc8r_prereqs.sh
bash ./orc8r_installation.sh
