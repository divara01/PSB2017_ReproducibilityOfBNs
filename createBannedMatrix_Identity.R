options(stringsAsFactors=F)

args = commandArgs(trailingOnly=TRUE)

num_nodes = as.numeric(as.character(args[[1]]))
output = args[[2]]

banned = diag(num_nodes)

write.table(banned, file = output, sep="\t",quote=F,col.names=F,row.names=F)