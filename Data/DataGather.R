# Download the zipped folder into a tempfile.

url <- "http://data.statistics.gov.uk/Census/KS_QS_OA_UK_V1.zip"
temp <- tempfile()
download.file(url, temp)
# get list of file names
file.names <- unzip(temp, list=TRUE)$Name[2:74]
table.names <- substr(file.names, 18, 22)

# first extract only the top three rows from each table (tip: unz instead of unzip)
list.all.headers <- lapply(file.names, function(n){
read.csv(unz(temp, n),  nrows=3, header=FALSE, stringsAsFactors = FALSE)}
)

# create a list of variable names pasted from the three header rows in each table
all.var.names<- lapply(1:73, function(i) {
  var.names <- list.all.headers[[i]][3,1]
  for (v in 2:length(list.all.headers[[i]])){
    x <- list.all.headers[[i]][v]
    nx <- stringr::str_replace_all(string=paste(x[1,], x[2,], x[3,], sep="--"), pattern=" ", repl=".")
    var.names <- c(var.names, nx)}
  return(var.names)}
)

# also to keep it neat, give the list the correct names
names(all.var.names) <- table.names

# import 73 tables, no headers, exact rows
all.tables <- lapply(file.names, function(n){
  read.csv(unz(temp,n), nrows=232296, skip = 3, header=FALSE, stringsAsFactors = FALSE)}
)

# add the variable names to each of the 73 tables
for (i in 1:73) {
names(all.tables[[i]]) <- all.var.names[[i]]
}

# add the table names to the list
names(all.tables) <- table.names

# keep it tidy
unlink(temp)
rm(temp, url, list.all.headers, file.names, table.names)

# remove the empty columns from KS201
all.tables$KS201 <- all.tables$KS201[1:12]
# remove variables with missing values in KS501 and QS501
all.tables$KS501 <- all.tables$KS501[,-c(6,9)]
all.tables$QS501 <- all.tables$QS501[,-c(6,9)]


# function to remove 1000 separator commas from the columns that need it
RemoveComma <-  function(df){
  cbind(OA = df[,1],
        as.data.frame(
          lapply(df[, -1], function(v) {
            if (class(v) == "character") {
              v <- as.numeric(gsub(',', '', v)) # remove 1000 separator commas
              } else { v <- v}}))
        ,stringsAsFactors = FALSE) # protect OA geog from becoming a factor
}

# Run RemoveComma on all 73 tables
all.tables <- lapply(all.tables, RemoveComma)

# clean up and save
rm(all.var.names, RemoveComma)
save(all.tables, file= "KS_QS_OA2011.R")

