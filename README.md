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

# Step 4. Appropriately label the data set with descriptive variable names.

##Setting descriptive names for the variables in table_combined

The columns names in **table_combined** are retrieved using **name** and assigned to the object **newNames**.

```r
new_names <- names(table_combined)
```

Regular expressions are used to change the variable names contained in **new_names**, matching and replacing patterns one at a time.

The key changes are the first two. These change the start of the variable names from "t.."to "AverageTime_..." and from "f..." to "AverageFrequency..". This is done to better reflect their final content, the average of measurements for each variable.

The prefix "t" meaning time and the prefix  "f" meaning frequency is described in the file "UCI HAR Dataset/features_info.txt".

Changes done:
* "t" at the start to "AverageTime_"
* "f" at the start to "AverageFrequency_"
* "-" to "_"
* "mean()" to "Mean"
* "std"()" to "StandardDeviation"

```r
new_names <- gsub(new_names, pattern = "^t", replacement = "AverageTime-")
new_names <- gsub(new_names, pattern = "^f", replacement = "AverageFrequency-")

new_names <- gsub(new_names, pattern = "mean\\(\\)", replacement = "Mean")
new_names <- gsub(new_names, pattern = "std\\(\\)", replacement = "StandardDeviation")

new_names <- gsub(new_names, pattern = "Acc", replacement = "_Acceleration")
```

**names** is used to assign the new variable names contained in **new_names** to **table_combined**.

```r
names(table_combined) <- new_names
```

# Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Goal: a tidy data set
A data set where each column represents average values for each variable, for each activity, and each subject. The average will be computed using **mean**. 

The observations in **table values will be grouped by activity and then by subject.

There are 6 activities and 30 subjects, this is 180 groups by activity and subject or 6 * 30 = 180 rows.

There are 66 variables corresponding to measurements of a feature in **table_combined**, plus 1 column to identify activity, plus 1 to identify  subjects, this is 68 columns. 

Then, for the average of each variable of a measurement, there will a singular value for each group of activity and subject. 

That is, a **tidy data set** with 180 rows and 68 columns (180 * 68), where each row is a single, unique observation, each column is a single, unique variable, and each cell is a single, unique value. 

## Loading (or installing) dplyr

The dplyr package will be used to create groups and to compute summary statistics for them.

**require** will be used instead of **library** to load **dplyr** in our
enviroment.

When **require** is called it attempts to load a package, returning a **TRUE** value if succeeds in doing so, or a **FALSE** value if it fails, often because the solicited package is not installed.

Using an **if** statement to take advantage of these behavior, **require("dplyr")** will be called, if it returns
a **FALSE** value, then **install.packages** will be called to download or install **dplyr**.

```r
if(!require("dplyr")) install.packages("dplyr")
```

## Grouping and summarising the data

Once dplyr is loaded, **group_by** will be used to create groups in **table_combined** by **Activity** and then by **Subject**.

This grouped **table_combined** will be passed as the **tbl** argument to **summarise_each**.

**summarise_each** asks for a **funs** argument, this is a function for a summary statistic that will be computed for each columnn in a given data set. In this case, **mean** is called to compute average values.

Since the **tbl** argument is a grouped data set, then **mean** is computed by group of activity and then subject, resulting in a tidy data set with 180 rows and 68 columns.

The results are assigned to a new object called **table_summary**.

```r
table_summary <-
    summarise_each(
        tbl = group_by(table_combined, Activity, Subject),
        funs(mean)
    )
```

## Writing our tidy data set to a file


**write.table** is used to write "summary_table" to a plain text file called **table_summary.txt**. The parameter **row.names = FALSE** is set to prevent writing an extra column with row numbers.

```r
write.table(table_summary, file = "table_summary.txt", row.names = FALSE)
```

## Reading our tidy data set from a file

Once saved to a file, this tidy data set can be read using **read.table** with the parameter **header = TRUE**, so to properly read the column names.

```r
read.table("table_summary.txt", header = TRUE)
```
