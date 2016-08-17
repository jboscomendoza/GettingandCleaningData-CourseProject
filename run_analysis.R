download.file(
    url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
    destfile = "raw_dataset.zip")

unzip(zipfile = "raw_dataset.zip")

setwd("UCI HAR Dataset/")

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

names(table_combined) <-
    c("Activity", "Subject",
        read.table("features.txt", stringsAsFactors = F)[, 2]
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

new_names <- names(table_summary)

new_names <- gsub(new_names, pattern = "^t", replacement = "AverageTime_")
new_names <- gsub(new_names, pattern = "^f", replacement = "AverageFrequency_")
new_names <- gsub(new_names, pattern = "-", replacement = "_")
new_names <- gsub(new_names, pattern = "mean\\(\\)", replacement = "Mean")
new_names <- gsub(new_names, pattern = "std\\(\\)", replacement = "StandardDeviation")

names(table_summary) <- new_names

write.table(table_summary, file = "table_summary.txt", row.names = FALSE)

#To read the tidy data from file uncomment the next line.
#read.table("table_summary.txt", header = TRUE)
