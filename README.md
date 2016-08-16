# GettingandCleaningData-CourseProject
Course project for the Getting and Cleaning Data Course on Coursera.

# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Step 1: Merge the training and the test sets to create one data set.  

## Downloading the raw data set. 

We'll download the raw data set to our working directory using **download.file**. The raw data set will be downloaded with the name **raw_dataset.zip**. 

Once downloaded, we'll extract the all the files contained in this zip file to our working directory using **unzip**.

```r
download.file(
    url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
    destfile = "raw_dataset.zip")

unzip(zipfile = "raw_dataset.zip")
```

All the following steps assume the files in the raw dataset are located inside your working directory. This is very important when making references to file paths, and they are **relative**. This means a mention to "*some_file.txt*", assumes this particular file is located in your working directory and "*some_directory/other_file.txt*", assumes this directory and its contents are located inside your working directory.

## Raw files and rationale on how to combine them
The training set is divided and stored in three different files.

* "*UCI HAR Dataset/test/y_test.txt*" contains the activity identifiers.
* "*UCI HAR Dataset/test/Subject_test.txt*" contains the subject identifiers.
* "*UCI HAR Dataset/test/x_test.txt*" contains the measurements of the feature variables.

As all files have the same number of rows, so we'll use **cbind** to bind their columns in a single data set.

The test set is divided and stored in the very same way, in three different files.

* "*UCI HAR Dataset/test/y_test.txt*" contains the activity identifiers.
* "*UCI HAR Dataset/test/Subject_test.txt*" contains the subject identifiers.
* "*UCI HAR Dataset/test/x_test.txt*" contains the measurements of the feature variables.

We can also combine these files with **cbind** to create a single data set.

We'll have as a result two data sets, with the exact same number of columns, containing the same variables in them, in the same order.

So we can then use **rbind* to bind their their rows in a single data set.

## Reading and combining the raw files

We'll read all the required raw files using **read.table**. 

For "*UCI HAR Dataset/test/y_test.txt*" and "*UCI HAR Dataset/train/y_train.txt*" , we'll set the parameter **col.names = "Activity"**; and for "*UCI HAR Dataset/test/Subject_test.txt*" and "*UCI HAR Dataset/train/Subject_train.txt*" we set the parameter **col.names = "Subject"**. 

This will prevent confusion about the contents of these columns.

The following chunk of code will read, for each the training and test sets, the three raw files we need using **read.table** and bind their columns in a single data set, then bind the columns of the two resulting data sets into a single one, assigned to the **table_combined** object.

```r
table_combined <-
    rbind(
        cbind(
            read.table(file = "UCI HAR Dataset/test/y_test.txt",
                col.names = "Activity"),
            read.table(file = "UCI HAR Dataset/test/Subject_test.txt",
                col.names = "Subject"),
            read.table(file = "UCI HAR Dataset/test/x_test.txt")
        ),
        cbind(
            read.table(file = "UCI HAR Dataset/train/y_train.txt",
                col.names = "Activity"),
            read.table(file = "UCI HAR Dataset/train/Subject_train.txt",
                col.names = "Subject"),
            read.table(file = "UCI HAR Dataset/train/x_train.txt")
        )
    )
```



# Extract only the measurements on the mean and standard deviation for each measurement.

## Setting the name of the variables

We neeed some way to identify our variables, so we'll take the variable names contained in the file **features.text** with **read.table**, setting stringAsFactors to FALSE. Since the names of the features are stored in the second column of features.txt, we use **[, 2]** in read table.

We need to keep the names of the columns containing the Activity and Subject data, so we create a vector that contains "Activity", "Subject" and the
variable names in features.txt
Then, we assign this vector to the function names, called on table_combined, to
set the variable names.

```r
names(table_combined) <-
    c("Activity", "Subject",
        read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F)[, 2]
    )
```

## Selecting the variables that contain a mean or a standard deviation

We use the function names to get a vector with the names of all variable names in table_combined. We call grep on this vector to use regular expressions for finding variable names that contain "mean()" and "std()" in their name.

There are variables that contain "meanFreq()" in their name. We'll ignore these in this script, as we are requested to get "means" and "standard deviations" of each feature, and "meanFreq()" is an aditional and different measurement, that also appears in each measure.

With this in mind, we call a pattern that finds either **mean()** or **std()** in the variable names, and create a vector with the found values, setting **value = TRUE**, so we get strings and not just positions.

Just like the last step, we need to keep "Activity" and "Subject", so we also
add them to this vector.

We then use this vector to subset table_combined using bracket notation. We
take advantage of bracket notation allowing us to subset columns by name, this
way, we keep only "Activity", "Subject" and all variables containing a mean or
a standard deviation.

```r
table_combined <-
    table_combined[,
        c(
            "Activity",
            "Subject",
            grep(x = names(table_combined),
                pattern = "mean\\(\\)|std\\(\\)",
                value = TRUE)
          )
        ]
```
## Reorder table_combined by "Activity", then by "Subject"

We'll use the function "order" with two arguments, to sort table_combined,
first by "Activity", and then by "Subject"

```r
table_combined <-
    table_combined[order(table_combined[, "Activity"], table_combined[, "Subject"]), ]
```

Recode the values in the column "Activity" to descriptive ones

We'll use the contents of "UCI HAR Dataset/activity_labels.txt" as reference
to recode the values contained in our "Activity" variable.

Each value corrresponds to one of six particular activities, so we replace the
values in our "Activity" variable accordingly.

```r
table_combined["Activity"][table_combined["Activity"] == 1] <- "WALKING"
table_combined["Activity"][table_combined["Activity"] == 2] <- "WALKING_UPSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 3] <- "WALKING_DOWNSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 4] <- "SITTING"
table_combined["Activity"][table_combined["Activity"] == 5] <- "STANDING"
table_combined["Activity"][table_combined["Activity"] == 6] <- "LAYING"
```

## Get the average for each variable, by activity and subject.

Our expected result:
We'll get one average value for each value using the function mean. As we are
requested, we'll group our data by activity, and then compute the average value
for each subject in that group for each variable.

We have 6 activities and 30 subjects so we'll end up with 6 * 30 = 180 rows.
We have 66 variables corresponding to a feature, so well have one column to
indicate activity, one to indicate the subject and 66 columns, containing the
average value of each feature for that activity and subject, that is
 1 + 1 + 66 = 68 columns.

##Summarising with dplyr
We'll use the dplyr package to summarise table_combined.

We'll use the function "require" instead of "library" to load dplyr in our
eviroment. This is because "require", when called, besides loading a package,
returns a TRUE value if succeded, or a FALSE value if the package couldn't be
found, likely because it's not installed.

We'll take advantage of this using an if statement. If require("dplyr") returns
a FALSE, then it calls "install.packages" to download or install it.

```r
if(!require("dplyr")) install.packages("dplyr")
```

Once dplyr is loaded, we'll use the function group_by to group table_combined
by "Activity" and then by "Subject".

We'll pass this grouped table as an argument to the function "summarise_each".
This function returns a summary statistic for each column and each group, in
this case, the argument "funs(mean)" will call the function "mean".

We'll assign the result of this computation to the object "table_summary".

```r
table_summary <-
    summarise_each(
        tbl = group_by(table_combined, Activity, Subject),
        funs(mean)
    )
```

##Setting descriptive names for the variables in table_summary

We'll get the columns names in table_summary using "name", and assigning it to
the object "newNames".
newNames <- names(table_summary)

We'll use regular expressions to rename the columns, matching certain patterns
and replacing them, one at a time.

The key ones are the first two replacementes, that change the start of the
variable names to "AverageTime" and "AverageFrequency", to better reflect it's
content.
The rationale behind this change is the information contained in
"UCI HAR Dataset/features_info.txt", that indicates that a "t" prefix means
"time" and a "f" prefix means "frequency".

Changes done:
"t" at the start to "AverageTime-"
"t" at the start to "AverageFrequency-"
"mean()" to "Mean"
"std"()" to "StandardDeviation"
"Acc" to "Accelertion"

```r
newNames <- gsub(newNames, pattern = "^t", replacement = "AverageTime-")
newNames <- gsub(newNames, pattern = "^f", replacement = "AverageFrequency-")

newNames <- gsub(newNames, pattern = "mean\\(\\)", replacement = "Mean")
newNames <- gsub(newNames, pattern = "std\\(\\)", replacement = "StandardDeviation")

newNames <- gsub(newNames, pattern = "Acc", replacement = "_Acceleration")
```

We'll assign the new names to "table_summary" using "names".
names(table_summary) <- newNames

## Writing our tidy data set to a file

We'll use the function "write.table" to write "summary_table" to a text file
"table_summary.txt". The argument "row.names = FALSE" prevents writing an extra
column to this file, cointaining the row numbers.

```r
write.table(table_summary, file = "table_summary.txt", row.names = FALSE)
```

## Reading our tidy data set from a file

Once we saved our data set, we can read it from a file using "read.table"
with the argument header = TRUE, to properly read the column names.

```r
read.table("table_summary.txt", header = TRUE)
```
