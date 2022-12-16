#! /bin/bash
#script which takes a list of profiles (different flag + module configurations) and builds each one
#binaries are stored in a directory tree at . whith each subdirectory containing the name of its profile

root=/ec/res4/hpcperm/naco/moria/ectrans
cd $root

ARCH_FILES=("atos/intel_hpcx" "atos/gnu_hpcx")
for arch in "${ARCH_FILES[@]}"; do

	echo "building ectrans with the following profile: $arch"

	#load required modules
	module purge
	source $root/arch/$arch/env.sh

	#building the fiat depenancy with the correct arch
	fiat_root=$root/../deps/fiat
	bash $fiat_root/build.sh -a $arch
    	cd $root #move back to ectrans once done

	#generate a unique subdir based on arch and flag combo
	subdir=test/build/$arch

	#build the requested arch in the correct subdir
	mkdir -p $subdir; rm -r $subdir/* #make dir and clean contents just in case
	cmake -Dfiat_ROOT="$fiat_root/arch/$arch/build" -B $subdir
	cd $subdir
	make -j10

done
