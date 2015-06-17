# Getting and Cleaning Data Course Project

The script has been created to work with data collected from the accelerometers from the Samsung Galaxy S II smartphone. 
These data has been generated on the project "Human Activity Recognition Using Smartphones" and is the Version 1.0.

## Description of the experiments
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing the smartphone on the waist. 
Using its accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz were captured. 
The obtained dataset has been randomly partitioned into two sets: 
70% of the volunteers was selected for generating the training data. 
30% of the volunteers was selected for generating the test data. 

For each record, the following is provided: 

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

## Description of measurements

- t or f means the time or frequency in the measurements
- Body: means the body movement
- Gravity: means the acceleration of gravity
- Acc: means the measurements carried out by the accelerometer
- Gyro: means the measurements undertaken by the gyroscope
- Jerk: means a quick acceleration
- Mag: means the magnitude of the movement
- For every subject and activity, mean and std (standard deviation) are calculated.

## Files included in the folder
                                 
- test/Inertial Signals/body_acc_x_test.txt  
- test/Inertial Signals/body_acc_y_test.txt   
- test/Inertial Signals/body_acc_z_test.txt   
- test/Inertial Signals/body_gyro_x_test.txt  
- test/Inertial Signals/body_gyro_y_test.txt  
- test/Inertial Signals/body_gyro_z_test.txt  
- test/Inertial Signals/total_acc_x_test.txt  
- test/Inertial Signals/total_acc_y_test.txt  
- test/Inertial Signals/total_acc_z_test.txt  
- train/Inertial Signals/body_acc_x_train.txt 
- train/Inertial Signals/body_acc_y_train.txt 
- train/Inertial Signals/body_acc_z_train.txt 
- train/Inertial Signals/body_gyro_x_train.txt
- train/Inertial Signals/body_gyro_y_train.txt
- train/Inertial Signals/body_gyro_z_train.txt
- train/Inertial Signals/total_acc_x_train.txt
- train/Inertial Signals/total_acc_y_train.txt
- train/Inertial Signals/total_acc_z_train.txt
- test/subject_test.txt (used to extract data)         
- train/subject_train.txt (used to extract data)                   
- train/X_train.txt (used to extract data)                           
- train/y_train.txt (used to extract data)
- test/X_test.txt (used to extract data)                            
- test/y_test.txt (used to extract data) 
- activity_labels.txt (used for naming)                                                   
- features.txt (used for naming) 
- features_info.txt                           
- README.txt

## Script 
This script assumes the dataset is downloaded into a folder called datos and the file called Dataset.zip is unzipped.
To download and unzip, the code is included below: 

Download the data into the folder called "datos".
if(!file.exists("./datos")){dir.create("./datos")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./datos/Dataset.zip")

Unzip the folder in datos.
unzip(zipfile="./datos/Dataset.zip",exdir="./datos")

Load the required packages.
	library("dplyr", lib.loc="C:/Users/beatriz/Documents/R/win-library/3.1")
	library("data.table", lib.loc="C:/Users/beatriz/Documents/R/win-library/3.1")
	library("tidyr", lib.loc="C:/Users/beatriz/Documents/R/win-library/3.1")

Store in local variables file path for test & train data.
	rootDataPath <- file.path("./datos" , "UCI HAR Dataset")
	TestDataPath <- file.path("./datos" , "UCI HAR Dataset", "test")
	TrainDataPath <- file.path("./datos" , "UCI HAR Dataset", "train")

Read test data and train data.
	dataTestSubject <-read.table(file.path(TestDataPath,"subject_test.txt"))
	dataTestActivity <-read.table(file.path(TestDataPath,"Y_test.txt"))
	dataTestMeasures <-read.table(file.path(TestDataPath,"X_test.txt"))

	dataTrainSubject <-read.table(file.path(TrainDataPath,"subject_train.txt"))
	dataTrainActivity <-read.table(file.path(TrainDataPath,"Y_train.txt"))
	dataTrainMeasures <-read.table(file.path(TrainDataPath,"X_train.txt"))

### Merge each of the test,train datasets to obtain global datasets per regions.
Each dataset will be one column section of the final data set.
	dataSubject <- rbind(dataTestSubject,dataTrainSubject)
	dataActivity <- rbind(dataTestActivity,dataTrainActivity)
	dataMeasures <- rbind(dataTestMeasures,dataTrainMeasures)

	dataSubAct <- cbind(dataSubject,dataActivity)
	dataAll <- cbind(dataSubAct,dataMeasures)

Naming of each column of the global dataset (dataAll).
	dataMeasuresLabels <- read.table(file.path(rootDataPath, "features.txt"))
	dataAllLabels <- c("subject","activity",paste(dataMeasuresLabels$V2))

Apply the names to the global data set. dataAll is one labelled data set containing all test+train values.
	names(dataAll) <- dataAllLabels

### Extract measurements on the mean and standard deviation:
Filter mean and standard deviation values from all column definitions.
	dataMeanStdLabels <- grep("mean\\(\\)|std\\(\\)", dataMeasuresLabels$V2,value=TRUE)

Generate the filtering vector for all data columns (subject, activity and data measurements colums to be used).
	dataMeanStdFilter <- c("subject", "activity",dataMeanStdLabels)

Apply the filtering vector to the global dataset to extract selected values.
	dataSetMeanStdFiltered <- subset(dataAll,select=dataMeanStdFilter)

### Use descriptive names for Activity values in the dataset:
Load activity labels from file.
	dataActivityLabels <- read.table(file.path(rootDataPath, "activity_labels.txt"))
	names(dataActivityLabels) <- c("activity","activityDesc")

Merge data using the labels read and the filtered data set.
Activity name is added as the final column per each row (can be ordered if needed when tidying the data set).
	dataSetMeanStdFiltNamed <- merge(dataSetMeanStdFiltered, dataActivityLabels, by="activity")

### Final dataset labelling with human-readable variable names.
	names(dataSetMeanStdFiltNamed)<-gsub("Mag", "Magnitude", names(dataSetMeanStdFiltNamed))
	names(dataSetMeanStdFiltNamed)<-gsub("BodyBody", "Body", names(dataSetMeanStdFiltNamed))
	names(dataSetMeanStdFiltNamed)<-gsub("Acc", "Accelerometer", names(dataSetMeanStdFiltNamed))
	names(dataSetMeanStdFiltNamed)<-gsub("Gyro", "Gyroscope", names(dataSetMeanStdFiltNamed))
	names(dataSetMeanStdFiltNamed)<-gsub("^t", "Time", names(dataSetMeanStdFiltNamed))
	names(dataSetMeanStdFiltNamed)<-gsub("^f", "Frequency", names(dataSetMeanStdFiltNamed))

### Create a second independent tidy data set ("tidyDataSet.txt") with the average of each variable for each activity and each subject.

Obtain the mean (average) data per subject and activity (identified with code + desc)
	dataFinalAggregate <- aggregate(. ~ subject + activity + activityDesc, dataSetMeanStdFiltNamed, mean)

Order the Final data set with the aggregated data
	dataFinalAggregate <- dataFinalAggregate[order(dataFinalAggregate$subject, dataFinalAggregate$activity),]

Writing the tidy Data set requested (removing the row number)
	write.table(dataFinalAggregate, file = "tidyDataSet.txt",row.name=FALSE)