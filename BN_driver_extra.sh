#! /bin/bash

## SEE THE README FOR DETAILS

queue="low"
memory="1000"
wallclock="24:00"
cis_HQ="NULL"
causal="NULL" 
partialCorr="NULL" 
fixedPriors="NULL" 
tf_prior="NULL"
kegg_prior="NULL"
ppi_prior="NULL"
causal_prior="NULL"
continuous="FALSE"
BN_path=""
continuous_data=""

##### READ IN ARGUMENTS //FLAGS:
while getopts d:b:e:o:W:m:q:E:c:r:p:A:K:T:P:C:w: opt; do
case $opt in
    d)
      echo "-d was triggered, Data: $OPTARG" >&2
      data=$OPTARG
      ;;
    b)
      echo "-b was triggered, BN program path: $OPTARG" >&2
      BN_path=$OPTARG
      ;;
    e)
      echo "-e was triggered, cis eQTL data: $OPTARG" >&2
      cis_file=$OPTARG
      ;;
    o)
      echo "-o was triggered, Output path: $OPTARG" >&2
      output_path=$OPTARG
      ;;
    W)
      echo "-W was triggered, wallclock: $OPTARG" >&2
      wallclock=$OPTARG
      ;;
    m)
      echo "-m was triggered, Memory: $OPTARG" >&2
      memory=$OPTARG
      ;;
    q)
      echo "-q was triggered, queue: $OPTARG" >&2
      queue=$OPTARG
      ;;
    E)
      echo "-E was triggered, high quality cis eQTL: $OPTARG" >&2
      cis_HQ=$OPTARG
      ;;
    c)
      echo "-c was triggered, causal gene list: $OPTARG" >&2
      causal=$OPTARG
      ;;
    r)
      echo "-r was triggered, partial correlation list: $OPTARG" >&2
      partialCorr=$OPTARG
      ;;
    p)
      echo "-p was triggered, fixed prior list: $OPTARG" >&2
      fixedPriors=$OPTARG
      ;;
    A)
	  echo "-A was triggered, allocation queue: $OPTARG" >&2
      alloc=$OPTARG
      ;;
    K)
    echo "-K was triggered, kegg prior file: $OPTARG" >&2
      kegg_prior=$OPTARG
      ;;
    T)
    echo "-T was triggered, TF prior file: $OPTARG" >&2
      tf_prior=$OPTARG
      ;;
    P)
    echo "-P was triggered, PPI prior file: $OPTARG" >&2
      ppi_prior=$OPTARG
      ;;
    C)
    echo "-C was triggered, using continuous data to update prior: $OPTARG" >&2
      continuous=$OPTARG
      ;;
    w)
    echo "-w was triggered, using continuous data to update prior, data is: $OPTARG" >&2
      continuous_data=$OPTARG
      ;;  

  esac
done

module load BN

mkdir $output_path

mkdir -p $output_path/tmp/
mkdir $output_path/consensus_results/

cp $BN_path/* $output_path/tmp/
cp $data $output_path/tmp/
cp $cis_file $output_path/tmp/
cd $output_path/tmp/


BD=$output_path/tmp/Discrete;
BC=$output_path/tmp/Continuous;

mkdir $BD;
mkdir $BC;

cp $continuous_data $BC/BC_data
cp $data $BD/BD_data

for i in `seq 0 4`; do
	echo "running process with genetics on step $i--"
	pwd
	perl process_w_genetics_extra.pl $i $BD $BC $cis_file $cis_HQ $causal $partialCorr $fixedPriors $causal_prior $kegg_prior $tf_prior $ppi_prior $wallclock $memory $queue $continuous $alloc
done;

num_runs=`grep "Successfully" ${output_path}/tmp/stdout.* |wc -l`;
echo "Consensus built on: ${num_runs}";

