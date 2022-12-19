#! /bin/bash
#SBATCH --job-name=ectrans-bm
#SBATCH --qos=np
#SBATCH --time=0:10:00
#SBATCH --nodes=2 #NOTE: you must manually edit this line so that it lists the largest number of nodes you plan to run over
#SBATCH --output=ectrans.%j.out
#SBATCH --error=ectrans.%j.out

export OMP_SCHEDULE=dynamic 

#read a command line arg which defines the benchmarking session

if [ -z "$1" ]; then #check if config file has been given, if not do a toy run
	echo "usage: sbatch benchmark_ectrans.slurm [bm_config.env]"
	echo "no config provided so doing a simple demo run (see .demo.env)"
	source .demo.env
else #load the provided config file
	echo "Running a benchmark test based on: $1"
	source $1
fi

root="/ec/res4/hpcperm/naco/moria/ectrans/"

#print a summary of this benchmarking session
echo "Benchmarking the following arches: ${ARCH_FILES[*]}"
echo "Benchmarking the following number of Nodes: ${NUM_NODES[*]}"
echo "Benchmarking the followinf number of CPUs per Node: ${NUM_THREADS[*]}"
echo "Benchmarking the following number of NPROMA values: ${NPROMA_SIZES[*]}"
#echo "Benchmarking the following number of columns: ${NCOLS[*]}" #problem size
echo "Benchmarking the following number of OpenMP threads per MPI task: ${THREAD_TASK_RATIO[*]}" #useful when looking for a shared L3 cache
echo "Benchmarking the following float precisions: ${PRECISIONS[*]}"
total_runs=$((${#ARCH_FILES[@]} * ${#NUM_NODES[@]} * ${#NUM_THREADS[@]} * ${#NPROMA_SIZES[@]} * ${#THREAD_TASK_RATIO[@]} * ${#PRECISIONS[@]} * $iterations))
echo "Performing each configuration $iterations times, for a total of $total_runs runs"
echo "Each ectrans run uses a truncation of $truncation and $fields fields"

#launch the runs
for arch in "${ARCH_FILES[@]}"; do
	echo "benchmarking ectrans built with the following profile: $arch"
	build_dir="$root/test/build/$arch"
	source $root/arch/$arch/env.sh #load the modules required for the current arch
	cd $build_dir

	#launch the runs
	for node_count in "${NUM_NODES[@]}"; do
		for thread_count in "${NUM_THREADS[@]}"; do
			for threads_per_task in "${THREAD_TASK_RATIO[@]}"; do
				ntasks_per_node=$(expr $thread_count / $threads_per_task)
				for nproma in "${NPROMA_SIZES[@]}"; do
					for p in "${PRECISIONS[@]}"; do
						binary="ectrans-benchmark-$p"
						for ((i = 0 ; i < $iterations ; i++)); do
							echo "profile $arch node_count $node_count thread_count_per_node $thread_count ntasks_per_node $ntasks_per_node " \
								"threads_per_task $threads_per_task precision $p NPROMA $nproma truncation $truncation frequency $fields"
							srun --hint=nomultithread --cpus-per-task=$threads_per_task --nodes=$node_count \
								--ntasks-per-node=$ntasks_per_node env OMP_NUM_THREADS=$threads_per_task env OMP_PLACES=cores \
								bin/$binary -t $truncation -f $fields --nproma $nproma
						done
					done
				done
			done
		done
	done
done


