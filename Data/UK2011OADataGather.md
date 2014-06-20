# UK 2011 Census Output Area Key and Quick Statistics Import

<p>Maja Zalo&#382;nik </p>
20.6.2014

----------

This code is for the import and cleaning up of the June 2014 release from the ONS.

The dataset contains 26 Key statistics and 47 Quick Statistics, so all together that means 73 tables to be read.

Three issues are solved with this code:
- the fact that the tables have three-row-headers.
- the fact that in this release the tables have randomly from 3 to 7 empty rows appended at the end. 
- the fact that some tables also have extra empty columns appended on the right.
- the fact that the Scottish OAs have Excel formatted 1000 comma separators, which mean they are imported as character strings...
- KS501 and QS501 have variables that are not applicable in Scotland, which is indicated by a ":". These are removed completely here. 

To Do:
- nicer variable names
- overlap between KS and QS?

--------

Download the zipped folder into a tempfile.

```r
url <- "http://data.statistics.gov.uk/Census/KS_QS_OA_UK_V1.zip"
temp <- tempfile()
download.file(url, temp)
# get list of file names
file.names <- unzip(temp, list = TRUE)$Name[2:74]
table.names <- substr(file.names, 18, 22)
```


OK, now we know there are always 3 header rows in each table. Let's make them into variable names.


```r
# first extract only the top three rows from each table (tip: unz instead of
# unzip)
list.all.headers <- lapply(file.names, function(n) {
    read.csv(unz(temp, n), nrows = 3, header = FALSE, stringsAsFactors = FALSE)
})
# create a list of variable names pasted from the three header rows in each
# table
all.var.names <- lapply(1:73, function(i) {
    var.names <- list.all.headers[[i]][3, 1]
    for (v in 2:length(list.all.headers[[i]])) {
        x <- list.all.headers[[i]][v]
        nx <- stringr::str_replace_all(string = paste(x[1, ], x[2, ], x[3, ], 
            sep = "--"), pattern = " ", repl = ".")
        var.names <- c(var.names, nx)
    }
    return(var.names)
})
# also to keep it neat, give the list the correct names
names(all.var.names) <- table.names
```


Now we can import the actual tables and add the long and awkward variable names

```r
# import 73 tables, no headers, exact rows
all.tables <- lapply(file.names, function(n) {
    read.csv(unz(temp, n), nrows = 232296, skip = 3, header = FALSE, stringsAsFactors = FALSE)
})
# add the variable names to each of the 73 tables
for (i in 1:73) {
    names(all.tables[[i]]) <- all.var.names[[i]]
}
# add the table names to the list
names(all.tables) <- table.names
# keep it tidy
unlink(temp)
rm(temp, url, list.all.headers, file.names, table.names)
```


Cleaning up: first remove the empty rows in KS201 (this was detected manually) and the two variables with ":" in KS501 and Qs501 (highest qual: apprenticeship and highest qual: other) 


```r
# remove the empty columns from KS201
all.tables$KS201 <- all.tables$KS201[1:12]
# remove variables with missing values in KS501 and QS501
all.tables$KS501 <- all.tables$KS501[, -c(6, 9)]
all.tables$QS501 <- all.tables$QS501[, -c(6, 9)]
```


Then we need to deal with the comma separator for thousands. These automatically got imported as "character". So assuming all the variables (except the OA code) should be numeric, we look for class == "character", and within them use grep to remove the commas..



```r
# function to remove 1000 separator commas from the columns that need it
RemoveComma <- function(df) {
    cbind(OA = df[, 1], as.data.frame(lapply(df[, -1], function(v) {
        if (class(v) == "character") {
            v <- as.numeric(gsub(",", "", v))  # remove 1000 separator commas
        } else {
            v <- v
        }
    })), stringsAsFactors = FALSE)  # protect OA geog from becoming a factor
}

# Run RemoveComma on all 73 tables
all.tables <- lapply(all.tables, RemoveComma)
```



Clean up and save list of all tables.

```r
# clean up and save
rm(all.var.names, i, RemoveComma)
save(all.tables, file = "KS_QS_OA2011.R")
```


