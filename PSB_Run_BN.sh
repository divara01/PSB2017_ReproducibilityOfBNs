#!/bin/bash

# make sure R is loaded into the enviroment
gitrepo= #path where the git is saved to
RIMBANet_repo= #path where BN2Distribute aka RIMBANet is stored
cp $gitrepo/*.pl $RIMBANet_repo/Perls/
cp $gitrepo/*.R $RIMBANet_repo/Perls/

bash ${gitrepo}/PSB2017_ReproducibilityOfBNs/BN_driver_extra.sh -d ${gitrep}/data/GTEx_100_1_BD.txt -b ${RIMBANet_repo}/Perls -o ~/Desktop/GTEx_100_1 -e ${gitrepo}/data/GTEx_eqtl.txt -E ${gitrepo}/data/GTEx_eqtl.txt -q alloc -A acc_test -W 12:00 -C TRUE -w ${gitrepo}/data/GTEx_100_1_BC.txt -m 2000
