#! /usr/bin/perl

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# A package for Bayesian network reconstruction
#
# Author:  Dr. Jun Zhu, Amgen Inc., Thousand Oaks, CA, 2002
#          Dr. Jun Zhu, Rosetta Informatics, a wholly owned subsidiary of Merck & CO., Seattle, WA, 2004, 2008
#
# Acknowledge:  Thanks to Amgen Inc. and Merck & CO. for their generous supports
#
# If you use this package, please cite the following references
#
# (1) Zhu J, Lum PY, Lamb J, GuhaThakurta D, Edwards SW, et al. An integrative genomics approach to the
#     reconstruction of gene networks in segregating populations. Cytogenet Genome Res 105: 363-374 (2004)
# (2) Zhu J, Wiener MC, Zhang C, Fridman A, Minch E, Lum PY, Sachs JR, & Schadt EE Increasing the power to
#     detect causal associations by combining genotypic and expression data in segregating populations
#     PLoS Comput Biol 3, e69. (2007)
# (3) Zhu, J., Zhang, B., Smith, E.N., Drees, B., Brem, R.B., Kruglyak, L., Bumgarner, R.E. and Schadt, E.E.
#     Integrating large-scale functional genomic data to dissect the complexity of yeast regulatory networks,
#     Nat Genet, 40, 854-861 (2008)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#r of pvalue=0.01
$corrFile = "corrP01.txt";
open(IN, $corrFile) || die ("$corrFile is not found.");
while(<IN>) {
    chop($_);
    @tmp = split(/[ \t]+/);
    $Offset[$tmp[0]] = $tmp[1];
}
close(IN);

$workDir = $ENV{PWD};

# print "in process_w_genetics_extra.pl working directory $workDir\n";
# $BNBIN = "$workDir/testBN";

# $prog = "$workDir/testBN -f 0 ";
$prog = "testBN -f 0 "; ## testBN was loaded with module load BN.
if(@ARGV<3) {
    print "$0 step BD BC\n";exit(0);
}
$step = $ARGV[0];
# print "step is $step\n";
$BD = $ARGV[1];
# print "BD path is $BD\n";
$BC = $ARGV[2];
# print "BC path is $BC\n";
#$data = $ARGV[3]; #"data.txt";
# print "data file is $data \n";
$init = "init.xml";
$prior = "qtl.prior";
$ban = "banned.matrix";
$cis = $ARGV[3]; #"cisqtl.txt";
# print "cis file $cis \n";
$cis_HQ = $ARGV[4]; #"cisqtl_HQ.txt"; update banned matrix based on cis-QTL, does not require $cis_HQ but will process it if present
# print "cis HQ $cis_HQ\n";
$causal = $ARGV[5]; #"bannedList_causal.txt";
# print "causal is $causal\n";
$partialCorr =  $ARGV[6]; # "partialCorr_list.txt";
# print "partialCorr_list is $partialCorr\n";
$mi_cutoff = "mi.cutoff1";
$qtloverlap = "QTLOverlap.txt"; #ARGUMENT NOT USED!
$cisTransOverlap = "cisTransOverlap.txt"; #ARGUMENT NOT USED!
$fixedPriors =$ARGV[7]; #"fixed.priors";

# $fixedPriors_TF_PPI =$ARGV[9]; #"fixed.TF_PPI";

$causal_prior = $ARGV[8];
$kegg_prior =  $ARGV[9];
$tf_prior =$ARGV[10];
$ppi_prior = $ARGV[11];

$wallclock=$ARGV[12];
print "wallclock $wallclock\n";
$memory=$ARGV[13];
print "memory $memory\n";
$queue=$ARGV[14];
print "queue $queue\n";

$continuous = $ARGV[15];

$numStates = 3;

# if (@ARGV>15) {
$alloc=$ARGV[16];
# }else{
#     $add_flags="";
# }

#get data dimension
#print "working Directory: $workDir\n";

open(IN, "$BD/BD_data") || die;
$nNode=0;
while(<IN>){
    chop($_);
    @tmp = split(/[ \t]+/);
    $nSample = @tmp-1;
    $nNode++;
}
close(IN);

#step 0: create ban matrix
#step 1: initialize priors
#step 2: update priors
#step 3: add fixed links
#step 4: calculate structure
$BN_PERL = "$workDir";
if ($step==0) {
    ### Use continuous data to generate init.xml and construct prior network (testBN -t 0),
    ### These values are store in the directory $BC (Bayesian Continuous.) and will be compared in step 1
    ### to a reference table (corrP01.txt) of r value for p-values = 0.01 at various sample sizes.
    ### Then, use discrete data to generate a second init.xml and prior network. This is stored in $BD directory (Bayesian Discrete).
    ### Create banned.matrix based on the top 20% correlation edges in prior network that is ONLY 
    ### from DISCRETE expression data. Update banned.matrix with the cis-eQTL genes that are not in LD.
    ### Update banned.matrix with High Quality (HQ) cis QTLs (assume not in LD with anything else)
    ### Update banned.matrix with any other causal data (experimental, literature, etc) file is 
    ### formatted as node1\tnode2\n. 

    #prepare for continuous data, if there is no BC_data flag, will not generate priors based off of continuous data.
    if(-s "$BC/BC_data" >0){
        print "BC data exists, using it to generate priors";
        if(-s "$BC/$prior"==0) {
    	$cmd = "cd $BC; perl $BN_PERL/generateBIF.pl BC_data \"continuous \" -1 >$init";
    	print "$cmd\n";
    	system($cmd);
    	$cmd = "cd $BC; $prog -b $init -d BC_data -t 0 -T 0 -D $nSample -o junk -r 1 -L 1  >junk ; egrep  \\> junk > $prior";
    	print "$cmd\n";
    	system($cmd);
    	unlink("$BC/junk");
        }
    }else{
        print "BC data does not exists, not using it to generate priors";
    }
    #prepare for discrete data data
    $cmd = "cd $BD; perl $BN_PERL/generateBIF.pl BD_data \"discrete \" $numStates >$init";
    print "$cmd\n";
    system($cmd);

    if(-s "$BD/$prior"==0) {
        #### think the flag -t 0 is indicating that generating prior based on correlation
	$cmd = "cd $BD; $prog -b $init -d BD_data -t 0 -T 0 -D $nSample -o junk -r 1 -L 1  >junk ; egrep  \\> junk > $prior";
	print "$cmd\n";
	system($cmd);
	unlink("$BD/junk");
    }

    #goto L1;
    #determined cutoff value at X percentile
    $mi_cutoffR =0.8; #mi cutoff rate
    if(!-e "$BD/$mi_cutoff" || -s "$BD/$mi_cutoff" ==0) {
    	print "calculating mi cutoff...\n";
    	@res = `cd $BD; perl $BN_PERL/getHistogram.pl 0 0.3 0.001 $prior 4 | egrep -v "max|min" `;
    	$ti = 0;
    	$p=0;
    	for ($i=0; $i<@res; $i++) {
    	    @tmp = split(/[ \t]+/, $res[$i]);
    	    if ($p<$mi_cutoffR && $tmp[2]>$mi_cutoffR) { # tmp[2] is the area under the curve from histogram.
    		break;
    	    }
    	    else {
    		$ti = $tmp[0]; #start of bin
    		$p = $tmp[2]; #area under the curve at bin i
    	    }
    	}
    	#upper bound
    	$ti2 = 0;
    	$p=0;
    	$mi_cutoffR2 =0.8; #mi cutoff rate
    	for ($i=0; $i<@res; $i++) {
    	    @tmp = split(/[ \t]+/, $res[$i]);
    	    if ($p<$mi_cutoffR2 && $tmp[2]>$mi_cutoffR2) {
    		break;
    	    }
    	    else {
    		$ti2 = $tmp[0];
    		$p = $tmp[2];
    	    }
    	}
    }
    else {#cutoff based on permuation if mi_cutoff file exists:
        open(IN, "$BD/$mi_cutoff") || die;
    	$_=<IN>;
    	chop($_);
    	$ti = $_;
    	close(IN);
    }

    print "ti=$ti\n";
    print "ti2=$ti2\n";
    
    #create the banned matrix - priors generated from correlation data (strongest correlation links from prior file)
    $r= (1-$mi_cutoffR)*1.2; #assuming mi_cutoffR = 0.8, this is 0.24
    $cmd = "cd $BD; perl $BN_PERL/createBannedMatrix.pl BD_data $prior 4 $ti $ti2 $r $ban";
    print "$cmd\n";
    system($cmd);

    print "Forcing Banned matrix to be identity matrix\n";
    $cmd = "cd $BD; Rscript $BN_PERL/createBannedMatrix_Identity.R $nNode $ban";
    print "$cmd\n";
    system($cmd);

    #update banned matrix based on cis-QTL, does not require $cis_HQ but will process it if present
    $cmd = "cd $BD; perl $BN_PERL/updateBannedMatrix4Cis.pl BD_data $ban $cis $cis_HQ";
    print "$cmd\n";
    system($cmd);
 
    #update banned matrix based on causal-list: file is gene1\tgene2\n
    if (-e "$causal") {
	$cmd = "cd $BD; perl $BN_PERL/updateBannedMatrixFromList.pl BD_data $ban $causal ";
	print "$cmd\n";
	system($cmd);
    }
}   
if ($step ==1) {
    ### Updating BD prior file (a -> b x y):
    ###    1) continuous data - update x to be = log(r_continuous(a,b)/r_threshold)*log(nNodes)
    ###    2) partial correlation file if exists - update x= log(partial_corr(a,b)/r_threshold)*log(nNodes)

    #update prior based on continuous data
    $offset = $Offset[$nSample];
    if ($offset ==0) {
	print "Error: offset is 0 for $nSample!\n";
	exit(0);
    }

    ### pass in to updatePrior.pl data, continuous prior file, discrete prior file, offset, numberNodes
    ### prior file in BD directory gets updated with continuous prior info.
    ### prior output format: a -> b x y. a= node1, b=node2, x=log(r_continuous(a,b)/r_threshold)*log(nNodes),
    ### y=r_discrete(a,b). r_threshold is precalculated and is the r value which gives p=0.01 @ sampleSize N.


    if($continuous eq "TRUE"){
        $cmd="cd $BD; perl $BN_PERL/updatePrior.pl BD_data $BC/$prior $prior $offset $nNode";
        print "$cmd\n";
        system($cmd);
    }   



    #update based on partial correlation
    ### update prior file based on partial correlation file which is formatted as: a -> b x y;
    ### where a = node1, b=node2, x= ?, y= correlation value.
    ### updates the prior file output is now: a -> b x y; a=node1,b=node2,
    ### x=logscale, weighted (by Nnodes), partial correlation; y = r_discrete(a,b)
    if (-e "$partialCorr") {
	$cmd="cd $BD; perl $BN_PERL/partialCorr2Prior.pl BD_data $prior $partialCorr $offset $nNode";
	print "$cmd\n";
	system($cmd);
    }
}

if($step ==2) {
    ### if any prior files exist, updating current $prior by adding the maximum value from each prior.* list
    ### to the previously calculated x value (a -> b x y) in $prior. 
    ### If edge is in prior.* but not in $prior file, the edge will not be added to $prior. 
    ### Only edges already in $prior will be updated. 

    #scan prior base on causality
    if (-e "$causal_prior") {
        $cmd="cd $BD; perl $BN_PERL/addPrior.pl BD_data $causal_prior $prior ";
        print "$cmd\n";
        system($cmd);
    }
    
    #scan prior base on KEGG
    if (-e "$kegg_prior") {
        $cmd="cd $BD; perl $BN_PERL/addPrior.pl BD_data $kegg_prior $prior ";
        print "$cmd\n";
        system($cmd);
    }


    #scan prior base on PPI
    if (-e "$ppi_prior") {
	$cmd="cd $BD; perl $BN_PERL/addPrior.pl BD_data $ppi_prior $prior ";
	print "$cmd\n";
	system($cmd);
    }
 
    #scan prior base on TF_PPI
    if (-e "$tf_prior") {
	$cmd="cd $BD; perl $BN_PERL/addPrior.pl BD_data $tf_prior $prior ";
	print "$cmd\n";
	system($cmd);
    }
}

if($step==3) {
    ### Updating init.xml by adding to that file known fixed prior connections
    ### $fixedPriors is formatted: "parent\tchild\tprior\n"
    ### init.xml is updated. 

    #add fixed priors
    if(-s "$fixedPriors" >0) {
	$cmd = "cd $BD; perl $BN_PERL/addPriorFromFile.pl $fixedPriors $init >junk ";
	print "$cmd\n";
	system($cmd);
    }
}

if($step==4) {
    ### Submitting jobs that will run and then gather all the results from the BN!
    # calculate structure
    # $cmd="cd $BD; perl $BN_PERL/run_w_genetics.pl $nSample $nNode $init $data $ban $prior &";
    $cmd="perl $BN_PERL/run_w_genetics_queue.pl $nSample $nNode $BD/$init $BD/BD_data $BD/$ban $BD/$prior $wallclock $memory $queue $alloc&";
    print "$cmd\n";
    system($cmd);
}


