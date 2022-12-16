BEGIN   {
        OFS=",";
	ORS=""; #remove ORS bc we don't want automatic \n
	print "profile", "node_count", "thread_count_per_node", "ntasks_per_node", "threads_per_task", "precision", "NPROMA_size", "truncation", "frequency", "wallclock_time", "cpu_time", "vector_time"
        }
$1 ~ /profile/ {
	print "\n" $2, $4, $6, $8, $10, $12, $14, $16, $18, "";
	}
$2 ~ /WALLCLOCK/{ 
	print $4, $7, $10;
        }
END     { print "\n" }
