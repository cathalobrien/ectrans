BEGIN   {
        OFS=",";
	ORS=""; #remove ORS bc we don't want automatic \n
	print "node_count", "thread_count_per_node", "ntasks_per_node", "threads_per_task", "precision", "wallclock_time", "cpu_time", "vector_time"
        }
$1 ~ /node_count/ {
        #$1 = "NUMTASKS"
        #print "compiler", "precision", $1, $2, $4, $5, $6, $9, $10
	#first_line="$2, $4, $6, $8, $10"
	print "\n" $2, $4, $6, $8, $10, "";
	}
$2 ~ /WALLCLOCK/{ #$2 = "";
        #split(FILENAME, array, "-")
        #print array[2], array[3],$1, $3, $5, $6, $7, $10, $11
	print $4, $7, $10;
        }
END     { print "\n" }
