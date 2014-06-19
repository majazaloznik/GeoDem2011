###############################################################################
# Getting data on key and quick OA statistics from the 2011 census.
#
# Just run this once.
#
# This is the June 2014 release from the ONS.
# 26 Key statistics and 47 Quick Statistics...
# So together that means 73 tables to be read.
#
# mz
# 16/6/14
###############################################################################

# download the zipped folder into a tempfile # only run once
if (!exists("temp")){
  url <- "http://data.statistics.gov.uk/Census/KS_QS_OA_UK_V1.zip"
  temp <- tempfile()
  download.file(url, temp)}

# get list of file names
file.names <- unzip(temp, list=TRUE)$Name[2:74]
table.names <- substr(file.names, 18, 22)#[1:3]

# reading the tables one by one..
# the original tables have three header rows... pure genious!

# Do they all have three? I'm not going to check manually!
table.nrows <- unlist(plyr::llply(file.names, function(n){
                length(count.fields(unzip(temp,n)))
                })) 
unique(table.nrows)

file.names[[27]]
x <-read.csv(unzip(temp,file.names[[27]]), nrows=3, header=FALSE)[1:3,4]


list.all.headers <- lapply(file.names, function(n){
  read.csv(unzip(temp,n), nrows=3, header=FALSE, stringsAsFactors = FALSE)
}
)

all.var.names<- lapply(1:2, function(i) {
  var.names <- list.all.headers[[i]][3,1]
  for (i in 2:length(list.all.headers[[i]])){
    x <- list.all.headers[[i]][2]
    nx <- stringr::str_replace_all(string=paste(x[1,], x[2,], x[3,], sep="--"), pattern=" ", repl=".")
    var.names <- c(var.names, nx)
  }
  return(var.names)
}
)

all.var.names[[1]]

stringr::str_replace_all(string=paste(x[1], x[2], x[3], sep="--"), pattern=" ", repl=".")

