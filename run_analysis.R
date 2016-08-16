download.file(
    url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
    destfile = "raw_dataset.zip")

unzip(zipfile = "raw_dataset.zip")

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

names(table_combined) <-
    c("Activity", "Subject",
        read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F)[, 2]
    )

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

table_combined <-
    table_combined[order(table_combined[, "Activity"], table_combined[, "Subject"]), ]

table_combined["Activity"][table_combined["Activity"] == 1] <- "WALKING"
table_combined["Activity"][table_combined["Activity"] == 2] <- "WALKING_UPSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 3] <- "WALKING_DOWNSTAIRS"
table_combined["Activity"][table_combined["Activity"] == 4] <- "SITTING"
table_combined["Activity"][table_combined["Activity"] == 5] <- "STANDING"
table_combined["Activity"][table_combined["Activity"] == 6] <- "LAYING"

if(!require("dplyr")) install.packages("dplyr")

table_summary <-
    summarise_each(
        tbl = group_by(table_combined, Activity, Subject),
        funs(mean)
    )

newNames <- names(table_summary)

newNames <- gsub(newNames, pattern = "^t", replacement = "AverageTime-")
newNames <- gsub(newNames, pattern = "^f", replacement = "AverageFrequency-")
newNames <- gsub(newNames, pattern = "mean\\(\\)", replacement = "Mean")
newNames <- gsub(newNames, pattern = "std\\(\\)", replacement = "StandardDeviation")
newNames <- gsub(newNames, pattern = "Acc", replacement = "_Acceleration")

names(table_summary) <- newNames

write.table(table_summary, file = "table_summary.txt", row.names = FALSE)

#To read the tidy data from file uncomment the next line.
#read.table("table_summary.txt", header = TRUE)
