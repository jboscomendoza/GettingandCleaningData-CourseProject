# Getting and Cleaning Data - Course Project
*(Course project for the Getting and Cleaning Data Course on Coursera)*

This readme file describes the contents and rationale of the run_analysis.R file, contained in this repository.

# Step 1: Merge the training and the test sets to create one data set.  

## Downloading the raw data set. 

**download.file** is used to download the raw data set to your working directory as **raw_dataset.zip**. 

```r
download.file(
    url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
    destfile = "raw_dataset.zip")
```

Once downloaded, the files contained in **raw_dataset.zip** are extracted to your working directory using **unzip**.

```r
unzip(zipfile = "raw_dataset.zip")
```

## Setting your working directory

Extracting **raw_dataset.zip** creates a directory called "*UCI HAR Dataset*". 

For convenience in locating the files that are required for this script the working directory will be changed to this directory with **setwd()**

```r
setwd("UCI HAR Dataset/")
```

## Raw files in the UCI HAR Dataset and rationale on how to combine them

The "*UCI HAR Dataset*" directory, now your working directory contains two subdirectories, "*train*" and "*set*", each one containing a subset of the raw data.

The **training** set is located in "*train*", it's divided and stored in three different files.

1. "*train/y_train.txt*" containing the activity identifiers.
2. "*train/Subject_train.txt*" containing the subject identifiers.
3. "*train/x_train.txt*" containing the measurements of the feature variables.

All these files have the same number of rows, so **cbind** is used bind their columns in a single data set.

The **test** set is divided and stored in the same way in *"test"*.

1. "*test/y_test.txt*" containing the activity identifiers.
2. "*test/Subject_test.txt*" containing the subject identifiers.
3. "*test/x_test.txt*" containing the measurements of the feature variables.

These files are also combined using **cbind** to create a single data set.

This results in two data sets, with the exact same number of columns, containing the same variables, in the same order.

Then **rbind** is used to bind their their rows in a single data set.

## Reading and combining the raw files

The required raw files are read using **read.table**. 

For "*test/y_test.txt*" and "*train/y_test.txt*" , we set the parameter **col.names = "Activity"**; and for "*test/Subject_text.txt*" and "*train/Subject_train.txt*" we set the parameter **col.names = "Subject"**. This prevents confusion about the contents of these files.

For the training and test sets, the three raw files are read using  **read.table**, then their columns are bound in a single data set, and finally, the rows of the two resulting data sets are bound into a single one.

The results of this are assigned to the object called **table_combined**.

```r
table_combined <-
    rbind(
        cbind(
            read.table(file = "test/y_test.txt",
                col.names = "Activity"),
            read.table(file = "test/Subject_test.txt",
                col.names = "Subject"),
            read.table(file = "test/x_test.txt")
        ),
        cbind(
            read.table(file = "train/y_train.txt",
                col.names = "Activity"),
            read.table(file = "train/Subject_train.txt",
                col.names = "Subject"),
            read.table(file = "train/x_train.txt")
        )
    )
```

# Step 2. Extract only the measurements on the mean and standard deviation for each measurement.

## Setting the name of the variables

The variable names contained in the file "*features.txt*" are used to name the variables in **table_combined**.

"*features.txt*" is read with **read.table** setting the parameter **stringAsFactors = FALSE**, so the text strings are read as values of class character.  

This creates a data frame with the names of the variables stored in its **second column**. so bracket notation is used (**[, 2]**) directly on **read.table** to subset it, and extract its contents. 

The result is a vector with all the variable names of the features in our data set.

To keep the names of the columns containing the **Activity** and **Subject** data, these two values are added to the vector with the variable names taken from *"features.txt*"

Finally, the resulting vector is assigned to **names(table_combined)** to change the variable names in **table_combined**.

```r
names(table_combined) <-
    c("Activity", "Subject",
        read.table("features.txt", stringsAsFactors = F)[, 2]
    )
```

## Selecting only variables containing a mean or a standard deviation of a measurement

**names** is used to get a vector with all variable names in **table_combined**. This vector is passed to **grep** and then *regular expressions* are used for finding variable names that contain either **mean()** (a mean value) or **std()** (a standard deviation), as described in the file "*features_info.txt*"

There are variables in the data set that contain **meanFreq()** in their name. These will be ignores in this script. For this project, it's requested to get the variables withe **mean** and **standard deviation** values of each feature, **meanFreq()** is a different measurement to these two, as described in "*features_info.txt*".

With this in mind, **grep** is called, with a pattern that finds either **mean()** or **std()** in the variable names and the parameter **value = TRUE**, so it returns a vector of characters instead of positions of values, as it is the default for this function. 

This results in a vector that contains all variable names corresponding to means and standard deviations.

Like in a previous step, **Activity** and **Subject** are kept as variable names by adding them to the vector resulting of the **grep** call.

This vector is then used to subset **table_combined** with bracket notation, taking advantage of bracket notation allowing to subset columns by name. This way only the columns named **Activity**, **Subject**, and all the variable names containing a **mean()** or **std()** are retained.

The resulting data set is then assigned to **table_combined**.

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

This is not a required procedure, but makes this data set a bit easier to understand at a glance. 

**order** is called on **table_combined** with two arguments, **table_combined[, "Activity"]** and **table_combined[, "Subject"]**, to sort the data set by **Activity** and then by **Subject**.

The results are then assigned to **table_combined**.

```r
table_combined <-
    table_combined[order(table_combined[, "Activity"], table_combined[, "Subject"]), ]
```

## Recode the values in the column Activity to descriptive ones

The file "*activity_labels.txt*" has the references to label the values contained in our **Activity** variable.

Each numeric value from 1 to 6 corrresponds to one particular activity, so they are replaced accordingly in our **Activity** variable. The new values will be of class **character**.

```r
table_combined["Activity"][table_combined["Activity"] == 1] <- "WALKING"
table_combined["Activity"][table_combined["Activity"] == 2] <- "WALKING_UPSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 3] <- "WALKING_DOWNSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 4] <- "SITTING"
table_combined["Activity"][table_combined["Activity"] == 5] <- "STANDING"
table_combined["Activity"][table_combined["Activity"] == 6] <- "LAYING"
```

# Step 4. Appropriately label the data set with descriptive variable names.

##Renaming the variables in table_combined

The column names in **table_combined** are retrieved using **name** and assigned to the object **new_names**.

```r
new_names <- names(table_combined)
```

Regular expressions used to change the variable names contained in **new_names**, matching and replacing patterns one at a time.

The most important changes are the first two. These change the start of the variable names from "t.." to "AverageTime_..." and from "f..." to "AverageFrequency..". This is done to better reflect their final content, the average of measurements for each variable.

The prefix "t" meaning time and the prefix  "f" meaning frequency is described in the file "features_info.txt".

"mean()", "std()" and "-" are also changed to make them easier to read and manipulate. "BodyBody" is changed to "Body", to keep consistent variable names.

Changes done:

1. "t" at the start to "AverageTime_"
2. "f" at the start to "AverageFrequency_"
3. "-" to "_"
4. "mean()" to "Mean"
5. "std()" to "StandardDeviation"
6. "BodyBody" to "Body"

```r
new_names <- gsub(new_names, pattern = "^t", replacement = "AverageTime-")
new_names <- gsub(new_names, pattern = "^f", replacement = "AverageFrequency-")
new_names <- gsub(new_names, pattern = "_", replacement = "_")
new_names <- gsub(new_names, pattern = "mean\\(\\)", replacement = "Mean")
new_names <- gsub(new_names, pattern = "std\\(\\)", replacement = "StandardDeviation")
```

**names** is used to assign the new variable names contained in **new_names** to **table_combined**.

```r
names(table_combined) <- new_names
```

# Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Goal: a tidy data set

The observations in **table values** will be grouped by activity and then by subject. There are 6 activities and 30 subjects, this is 180 groups of activity and subject, or 6 * 30 = 180 rows.

There are 66 variables corresponding to measurements of a feature in **table_combined**, plus 1 column to identify activity, plus 1 column to identify subjects, this is 68 columns in total.

Then, for the average of each variable of a measurement, there must be a singular value for each group of activity and subject.

All this put together will be a **tidy data set** with 180 rows and 68 columns (180 * 68), where each row is a single observation, each column is a single variable, and each cell is a single value. 

## (Installing and) loading dplyr

The dplyr package is used to create groups in our data sets and to compute summary statistics for them.

**require** is used instead of **library** to load **dplyr** in our
enviroment.

When **require** is called it attempts to load a package, returning a **TRUE** value if succeeds in doing so, or a **FALSE** value if it fails, often because the solicited package is not installed.

Using an **if** statement to take advantage of these behavior, **require("dplyr")** will be called, if it returns
a **FALSE** value, then **install.packages** will be called to download and install **dplyr**.

```r
if(!require("dplyr")) install.packages("dplyr")
```

## Grouping and summarising the data

Once **dplyr** is loaded, **group_by** will be used to create groups in **table_combined** by **Activity** and then by **Subject**.

This grouped **table_combined** will be passed as the **tbl** argument to **summarise_each**.

**summarise_each** asks for a **funs** argument, this is a function for a summary statistic that will be computed for each columnn in a given data set. In this case, **mean** is called to compute average values.

In this case the **tbl** argument is a grouped data set, so the function **mean** is computed by group of activity and then subject, resulting in a tidy data set with 180 rows and 68 columns.

The results are assigned to a new object called **table_summary**.

```r
table_summary <-
    summarise_each(
        tbl = group_by(table_combined, Activity, Subject),
        funs(mean)
    )
```

## Writing our tidy data set to a file

**write.table** is used to write **summary_table** to a plain text file called **table_summary.txt**. The parameter **row.names = FALSE** is set to prevent writing an extra column with row numbers to this file.

```r
write.table(table_summary, file = "table_summary.txt", row.names = FALSE)
```

## Reading our tidy data set from a file

Once saved to a file, this tidy data set can be read using **read.table** with the parameter **header = TRUE** to properly read the column names.

```r
read.table("table_summary.txt", header = TRUE)
```
