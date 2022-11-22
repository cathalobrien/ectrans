#!/bin/bash

cd /ec/res4/hpcperm/naco/moria/ectrans/

#setup the specified compiler x mpi implementation based pn the arch
arch="arch/atos/intel_intelmpi" #a sensible default
fiat_root="../deps/fiat"

#parsing command line args in bash is so horrible, credit to https://devhints.io/bash
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -a | --arch )
    shift; arch=$1
    ;;
  -h | --help )
    echo "usage: bash build.sh -a arch/{system}/{compiler}_{mpi_implementation}"
    echo "optional: -f => build dependancy fiat with the specified architecture"
    exit
    ;;
  -f | --fiat )
    echo "-f flag passed => rebuilding fiat..."
    bash $fiat_root/build.sh -a $arch
    cd /ec/res4/hpcperm/naco/moria/ectrans/ #move back to ectrans once done
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

echo "building ectrans with arch: " $arch

source $arch/env.sh #load compiler x mpi specific modules
source $arch/../env.sh #load modules which are shared regardless of compiler or mpi implementation
rm -r build; mkdir build; cd build
echo "arch=$arch" > .current_arch #so the slurm script knows which env to load

#cmake .. -Dfiat_ROOT="$fiat_root/build"
cmake .. -Dfiat_ROOT="../$fiat_root/build"
make -j10
