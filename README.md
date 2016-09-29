# PSB2017_ReproducibilityOfBNs
This repository contains code and data associated with the PSB 2016 conference paper entitled: Exploring the Reproducibility of Probabilistic Causal Molecular Network Models



##Data:
###	RData Files:
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/results/*MappedCliqueList.RData - contains a list format of all the cliques that were detected using COS.
		
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/results/*edges_all_RIMBANet.RData - a data frame object containing all the edges for all the different BNs (for each dataset). Format is node1, node2, posterior probability, replication, subsampling type. 
		
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/results/*edges_all_RIMBANet_cliqueAdded.RData - a data frame object containing all the edges for each dataset, but appended to it is a column if both nodes in an edge are present in a clique. 
		
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/results/*edges_all_RIMBANet_cliqueAdded_KDAdded.RData - a dataframe where appended is if node1 is a Key Driver.
	
### RIMBANet Input Files:
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/*BC - 
		The continuous data for the input of running BN. Format is Genes as rows, no column names, but rows are labeled. 
	
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/*BD - 
		The discretized data, where the three states are 0,1,and 2. Same file format as the continuous data.
	
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/*eqtl.txt - 
		the list of genes which have an eQTL associated with them
	
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/*citPriors.txt - 
		priors for the STARNET data that we detected using the Causal Inference Test. (See PMID: 27540175 for methods)	
###	RIMBANew Output Files: 
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/*EdgeFile  - 
		these are the output for RIMBANet of the consensus digraph where the BN is a directed acyclic graph (DAG). Edges here don't have weights. 
	
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/*labeledEdges - 
		output from RIMBANet where the label is the number of times out of 1,000 reconstructions that the edge is present in. 
	
		https://github.com/divara01/PSB2017_ReproducibilityOfBNs/tree/data/Simulation_true_network.txt - 
		the actual simulation true, real network. 
##Code:
	https://github.com/divara01/PSB2017_ReproducibilityOfBNs/PSB_RMarkdown.Rmd - 
	all the code in chunks that were run for making all the plots and tables in the PSB Paper.
		
	https://github.com/divara01/PSB2017_ReproducibilityOfBNs/Running_Cos.sh - 
	how we ran COS to detect cliques based on undirected top X% correlated edges.
		
	https://github.com/divara01/PSB2017_ReproducibilityOfBNs/PSB_Run_BN.sh - 
	how we ran RIMBANet for each of the networks. 
	
	https://github.com/divara01/PSB2017_ReproducibilityOfBNs/BN_Driver.sh - 
	a driver script that was used to get RIMBANet to run. 


