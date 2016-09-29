#! /usr/bin/perl

$workDir = $ENV{PWD};
# print "in run_w_genetics_queue working directory is $workDir\n";
$dim = $ARGV[0];
$nNodes = $ARGV[1];
$init = $ARGV[2];
$data = $ARGV[3];
$ban = $ARGV[4];
$prior = $ARGV[5];
$wallclock = $ARGV[6];
$memory = $ARGV[7];
$queue = $ARGV[8];


# if(@ARGV>8){
	$alloc = $ARGV[9];

# }
# else{
# 	$alloc = "";
# }
# if(@ARGV>6) {
#     $sleeptime = $ARGV[6];
# }
# else {
#    $sleeptime = 10;
# }


# if(@ARGV>7) {
#     $label = $ARGV[7];
# }
# else {
#     $label = "Label";
# }
$cmd = "module load BN";
print "$cmd\n";
system($cmd);

$NS = 1;

$interactive = 1;
$prog = "testBN -f 0 -M 5000000 "; # testBN module loaded in
# $prog = "$workDir/testBN -f 0 -M 5000000 ";

#the values for new ban matrix
$qratio = 1/($nNodes+1000);
$te=0;
$N=1000;
$alpha = 0.65-($dim/100)*0.015;
$r=1;

#calculate trylist
system("touch Trylist");
&submit2Que(0, $N);

#checking to make sure all 1000 jobs have been submitted: 

# $cmd = "bash script.sh";
# system($cmd);

#check whether all results have finished.
$n=0;
$num_complete = 0;
#while($n!=$N) {
while($n<$N) {
    sleep(30);
   	# $num_complete = system("grep \"Successfully completed\" out.* |wc -l");
   	# print "Number completed " , $num_complete;
   	# $n = $num_complete;
    $n=0;
    for($i=0; $i<$N; $i++) {
        if(-s "stdout.$i" >0) {
            $n++;
        }
    }
    # system("pwd");
    print "Completed Jobs: $n\tTotal Jobs: $N\n";
}

#create structure
$cmd = "perl createStructure.pl $dim $nNodes $init $data \"BN\" ";
print "$cmd\n";
system($cmd);

#print "Consensus graph generating...\n";
#sleep(60);

## checking to see if the consensus graph has been generated, if so, copies files to consesus results:
while(!-e "result.links3" ){
	print "waiting for the consesus graph to finish....\n";
	sleep(90);

}

$cmd = "cp result.links3 ../consensus_results/BN_digraph_pruned";
print "$cmd\n";
system($cmd);

$cmd = "cp result.links.3 ../consensus_results/labeled_digraph_all_edges";
print "$cmd\n";
system($cmd);

$cmd = "cp result.linksMatrix.3 ../consensus_results/digraph_matrix_all_edges";
print "$cmd\n";
system($cmd);

print "Consensus graph completed!\n";
print "PUSH ENTER TO EXIT\n";

system("exit");

sub submit2Que  {
    $start = $_[0];
    $end = $_[1];
    
    $time =time();

    my($njobs)=0;
    my($M);
    for($j=$start; $j<$end; $j+=$NS) {
	$cmd = "";
	for ($i=$j; $i<$j+$NS; $i++) {
	    if( !-e "result.out.$i") {
		system("touch result.out.$i");
		$time++;
		if(-s "Trylist" ==0) {
		    $up ="-U trylist.$i";
		}
		else {
		    $up = "";
		}
		$up = "";
		$cmd = "$prog -s $time -b $init -d $data -t -1 -T $te -D $dim -r $r -P $prior -a $alpha -q $qratio -l Trylist -g $ban $up -o result.out.$i>junkK.$i ;";
		open(OUT, ">bsub_job.$i") || die;   
		print OUT "#!/bin/bash\n";
		print OUT "#BSUB -W $wallclock\n";
		print OUT "#BSUB -q $queue\n";
		print OUT "#BSUB -R rusage[mem=$memory]\n";
		print OUT "#BSUB -e stderr.$i\n";
		print OUT "#BSUB -o stdout.$i\n";
		print OUT "#BSUB -P $alloc\n";
		print OUT "cd $workDir;\n";
		print OUT "module load BN;\n";
		print OUT $cmd;
		close(OUT);
		# $job_run ="bsub $alloc<bsub_job.$i";
		$job_run ="bsub <bsub_job.$i";
	    system($job_run);# print $cmd;
	    }
	}
	# if(length($cmd) >0) {
	#  #    print "Job Number $njobs Submitted\n";
	#  #    system("echo $cmd >bsub_job.$njobs");
	#  #    $njobs++;
	# 	# $job_run.="bsub -q scavenger -W 1:00 -o out.$njobs -e err.$njobs <bsub_job.$njobs";
	#  #    system($job_run);

	#  #    if ($njobs%100 ==0) {
	# 	# sleep($sleeptime);
	#  #    }
	# }
    }
}
