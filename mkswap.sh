#!/bin/bash
SIZE="1G"
SPATH="/opt/"
SNAME="swapfile"

SFULL=${SPATH}/${SNAME}

fallocate -l ${SIZE} ${SFULL}
chmod 600 ${SFULL}
mkswap ${SFULL}
swapon ${SFULL}
echo "${SFULL} none swap sw 0 0" | sudo tee -a /etc/fstab
