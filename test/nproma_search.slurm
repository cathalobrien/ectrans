#! /bin/bash
#SBATCH --job-name=ectrans-benchmark-nproma-search
#SBATCH --qos=np
#SBATCH --time=0:15:00
#SBATCH --nodes=2
#SBATCH --output=ectrans_multinode.%j.out
#SBATCH --error=ectrans_multinode.%j.out

#setup enviorment by loading modules and setting constants
source /ec/res4/hpcperm/naco/moria/ectrans/build/.current_arch #read what current arch ectrans was built with, stored in $arch
source "/ec/res4/hpcperm/naco/moria/ectrans/$arch/env.sh"
CPUS_PER_NUMA_REGION=16
CPUS_PER_SOCKET=64
CPUS_PER_NODE=128
#NUM_THREADS=($CPUS_PER_NUMA_REGION $CPUS_PER_SOCKET $CPUS_PER_NODE)
NUM_THREADS=($CPUS_PER_NODE) #use the entire node, no point not too
#NUM_NODES=(64 96 128)
NUM_NODES=(2)
#NPROMA_SIZES=(1 4 16 32 64 128 256)
NPROMA_SIZES=(256)

#set some runtime parameters
iterations=3

#openmp x mpi geometry (how many tasks vs threads will be used)
THREAD_TASK_RATIO=(4) #4 is the best on atos bc they share an L3 cache

#launch the runs
for node_count in "${NUM_NODES[@]}"; do
	for thread_count in "${NUM_THREADS[@]}"; do
		for threads_per_task in "${THREAD_TASK_RATIO[@]}"; do
			ntasks_per_node=$(expr $thread_count / $threads_per_task)
			for nproma in "${NPROMA_SIZES[@]}"; do
				for ((i = 0 ; i < $iterations ; i++)); do
					echo "node_count $node_count thread_count_per_node $thread_count ntasks_per_node $ntasks_per_node threads_per_task $threads_per_task precision sp NPROMA $nproma"
					srun --hint=nomultithread --cpus-per-task=$threads_per_task --nodes=$node_count \
						--ntasks-per-node=$ntasks_per_node env OMP_NUM_THREADS=$threads_per_task env OMP_PLACES=cores \
						/ec/res4/hpcperm/naco/moria/ectrans/build/bin/ectrans-benchmark-sp -t 1279 -f 412 --nproma $nproma
					echo "node_count $node_count thread_count_per_node $thread_count ntasks_per_node $ntasks_per_node threads_per_task $threads_per_task precision dp NPROMA $nproma"
					srun --hint=nomultithread --cpus-per-task=$threads_per_task --nodes=$node_count \
						--ntasks-per-node=$ntasks_per_node env OMP_NUM_THREADS=$threads_per_task env OMP_PLACES=cores \
						/ec/res4/hpcperm/naco/moria/ectrans/build/bin/ectrans-benchmark-dp -t 1279 -f 412 --nproma $nproma
				done
			done
		done
	done
done
