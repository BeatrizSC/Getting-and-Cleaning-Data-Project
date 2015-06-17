# Download the data into the folder called "datos".
#if(!file.exists("./datos")){dir.create("./datos")}
#fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(fileUrl,destfile="./datos/Dataset.zip")

#Unzip the folder in datos.
#unzip(zipfile="./datos/Dataset.zip",exdir="./datos")

# Load the required packages.
library("dplyr", lib.loc="C:/Users/beatriz/Documents/R/win-library/3.1")
library("data.table", lib.loc="C:/Users/beatriz/Documents/R/win-library/3.1")
library("tidyr", lib.loc="C:/Users/beatriz/Documents/R/win-library/3.1")

# Store in local variables file path for test & train data
rootDataPath <- file.path("./datos" , "UCI HAR Dataset")
TestDataPath <- file.path("./datos" , "UCI HAR Dataset", "test")
TrainDataPath <- file.path("./datos" , "UCI HAR Dataset", "train")

# Read test data and train data

dataTestSubject <-read.table(file.path(TestDataPath,"subject_test.txt"))
dataTestActivity <-read.table(file.path(TestDataPath,"Y_test.txt"))
dataTestMeasures <-read.table(file.path(TestDataPath,"X_test.txt"))

dataTrainSubject <-read.table(file.path(TrainDataPath,"subject_train.txt"))
dataTrainActivity <-read.table(file.path(TrainDataPath,"Y_train.txt"))
dataTrainMeasures <-read.table(file.path(TrainDataPath,"X_train.txt"))

# Merge each of the test,train datasets to obtain global datasets per regions
# Each dataset will be one column section of the final data set

dataSubject <- rbind(dataTestSubject,dataTrainSubject)
dataActivity <- rbind(dataTestActivity,dataTrainActivity)
dataMeasures <- rbind(dataTestMeasures,dataTrainMeasures)

dataSubAct <- cbind(dataSubject,dataActivity)
dataAll <- cbind(dataSubAct,dataMeasures)

# Naming of each column of the global dataset (dataAll)

dataMeasuresLabels <- read.table(file.path(rootDataPath, "features.txt"))
dataAllLabels <- c("subject","activity",paste(dataMeasuresLabels$V2))

# Apply the names to the global data set. dataAll is one labelled data set containing all test+train values
names(dataAll) <- dataAllLabels

# Extract measurements on the mean and standard deviation

# Filter mean and standard deviation values from all column definitions
dataMeanStdLabels <- grep("mean\\(\\)|std\\(\\)", dataMeasuresLabels$V2,value=TRUE)

# Generate the filtering vector for all data columns (subject, activity and data measurements colums to be used)

dataMeanStdFilter <- c("subject", "activity",dataMeanStdLabels)

# Apply the filtering vector to the global dataset to extract selected values
dataSetMeanStdFiltered <- subset(dataAll,select=dataMeanStdFilter)

# Use descriptive names for Activity values in the dataset

# Load activity labels from file
dataActivityLabels <- read.table(file.path(rootDataPath, "activity_labels.txt"))
names(dataActivityLabels) <- c("activity","activityDesc")

# Merge data using the labels read and the filtered data set
# Activity name is added as the final column per each row (can be ordered if needed when tidying the data set)
dataSetMeanStdFiltNamed <- merge(dataSetMeanStdFiltered, dataActivityLabels, by="activity")

# Final dataset labelling with human-readable names
names(dataSetMeanStdFiltNamed)<-gsub("Mag", "Magnitude", names(dataSetMeanStdFiltNamed))
names(dataSetMeanStdFiltNamed)<-gsub("BodyBody", "Body", names(dataSetMeanStdFiltNamed))
names(dataSetMeanStdFiltNamed)<-gsub("Acc", "Accelerometer", names(dataSetMeanStdFiltNamed))
names(dataSetMeanStdFiltNamed)<-gsub("Gyro", "Gyroscope", names(dataSetMeanStdFiltNamed))
names(dataSetMeanStdFiltNamed)<-gsub("^t", "Time", names(dataSetMeanStdFiltNamed))
names(dataSetMeanStdFiltNamed)<-gsub("^f", "Frequency", names(dataSetMeanStdFiltNamed))

#Calculate variable for each activity and generate the tidy data set

#Obtain the mean (average) data per subject and activity (identified with code + desc)
dataFinalAggregate <- aggregate(. ~ subject + activity + activityDesc, dataSetMeanStdFiltNamed, mean)

#Order the Final data set with the aggregated data
dataFinalAggregate <- dataFinalAggregate[order(dataFinalAggregate$subject, dataFinalAggregate$activity),]

#Writing the tidy Data set requested (removing the row number)
write.table(dataFinalAggregate, file = "tidyDataSet.txt",row.name=FALSE)
