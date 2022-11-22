BEGIN   {
        OFS=",";
	ORS=""; #remove ORS bc we don't want automatic \n
	print "compiler", "mpi_implementation", "node_count", "thread_count_per_node", "ntasks_per_node", "threads_per_task", "precision", "wallclock_time", "cpu_time", "vector_time"
        }
$1 ~ /node_count/ {
	split(FILENAME, array, "_") #get compiler and mpi imp from filename
	print "\n" array[2], array[3], $2, $4, $6, $8, $10, "";
	}
$2 ~ /WALLCLOCK/{ 
	print $4, $7, $10;
        }
END     { print "\n" }
