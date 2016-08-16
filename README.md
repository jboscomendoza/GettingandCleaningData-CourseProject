# GettingandCleaningData-CourseProject
Course project for the Getting and Cleaning Data Course on Coursera.

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

# Step 2. Extract only the measurements on the mean and standard deviation for each measurement.

## Setting the name of the variables

We neeed some way to identify our variables, so we'll take the variable names contained in the file "*UCI HAR Dataset/features.text*" with **read.table**, setting the parameter **stringAsFactors = FALSE**, so we get a characters instead of factors.

This will create a data frame with the names of the features stored in its second column, so we will use **[, 2]** directly on **read.table** to subset it. This will get us a vector with all the variable names corresponding to the features in the data set.

We also need to keep the names of the columns containing the **Activity** and **Subject** data, so we will add them to the vector with the variable names taken from *"UCI HAR Dataset/features.txt*"

Finally, we assign this resulting vector **names(table_combined)**, to set the variable names in this data set to the contents of our vector.

```r
names(table_combined) <-
    c("Activity", "Subject",
        read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F)[, 2]
    )
```

## Selecting only variables containing a mean or a standard deviation of a measurement

We use the **names** to get a vector with all variable names in **table_combined**, then we call **grep** on this vector to use *regular expressions* for finding variable names that contain either **mean()** (a mean value) or **std()** (a standard deviation), as described in the file "*UCI HAR Dataset/features_info.txt*"

There are variables in the data set that contain **meanFreq()** in their name. We'll ignore these in this script. We are requested to get **mean** and **standard deviation** values of each feature and **meanFreq()** is an aditional and different measurement, that also appears for each feature.

With this in mind, we'll call **grep** with a pattern that finds either **mean()** or **std()** in the variable names and the parameter **value = TRUE**, so we get a vector of characters, instead of positions, as it is the default for **grep**. When we will create a vector with the found values.

Just like the previous step, we need to keep **Activity** and **Subject**, as variable names, so we add them to this vector.

This vector is used to to subset **table_combined** with bracket notation, taking advantage of bracket notation allowing us to subset columns by name. This way, we keep only the columns named **Activity**, **Subject**, and all the variable names containing a **mean()** or **std()**.

The results are assigned to **table_combined**.

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

# Step 3. Use descriptive activity names to name the activities in the data set

## Reorder table_combined by Activity and then by Subject

This is not a key thing to do, but makes our data set a bit easier to understand. 

**order** is called on **table_combined**,  with two arguments, **table_combined[, "Activity"]** and **table_combined[, "Subject"]** to sort this data set by **Activity** and then by **Subject**.

The results are assigned to **table_combined**.

```r
table_combined <-
    table_combined[order(table_combined[, "Activity"], table_combined[, "Subject"]), ]
```

## Recode the values in the column Activity to descriptive ones

The file "*UCI HAR Dataset/activity_labels.txt*" is the reference to label the values contained in our **Activity** variable.

Each numeric value from one to six corrresponds to one of particular activity, so they are replaced accordingly in our **Activity** variable. The new values will be of class **character**.

```r
table_combined["Activity"][table_combined["Activity"] == 1] <- "WALKING"
table_combined["Activity"][table_combined["Activity"] == 2] <- "WALKING_UPSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 3] <- "WALKING_DOWNSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 4] <- "SITTING"
table_combined["Activity"][table_combined["Activity"] == 5] <- "STANDING"
table_combined["Activity"][table_combined["Activity"] == 6] <- "LAYING"
```

# Step 4. Appropriately labels the data set with descriptive variable names.

##Setting descriptive names for the variables in table_combined

We'll get the columns names in **table_combined** using **name**, and assigning it to the object **newNames**.

```r
newNames <- names(table_combined)
```

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

# Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
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
