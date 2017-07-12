library(tidyr)
library(dplyr)


#1 Merging training and the test sets to create one data set.
#1.1 Reading data from CSV
trainFeaturesData <- read.table(file = "UCI HAR Dataset/train/X_train.txt",header=FALSE,dec=".")
testFeaturesData <- read.table(file = "UCI HAR Dataset/test/X_test.txt",header=FALSE,dec=".")
trainActivityData <- read.table(file ="UCI HAR Dataset/train/y_train.txt",header=FALSE, dec=".")
testActivityData <- read.table(file ="UCI HAR Dataset/test/y_test.txt",header=FALSE, dec=".")
testSubjectData <- read.table(file ="UCI HAR Dataset/test/subject_test.txt",header=FALSE, dec=".",col.names=c("idSubject"))
trainSubjectData <- read.table(file ="UCI HAR Dataset/train/subject_train.txt",header=FALSE, dec=".",col.names=c("idSubject"))
featuresName <- read.table(file = "UCI HAR Dataset/features.txt",header=FALSE,dec=".",col.names=c("id","name"))
activityLabels <- read.table(file = "UCI HAR Dataset/activity_labels.txt", header=FALSE, col.names=c("id","name"))


#1.2 Merging train and test sets
#Features Data
featuresData <- rbind(trainFeaturesData, testFeaturesData) 
colnames(featuresData) <- seq(1,length(featuresData)) #Naming columns from 1:561
#Labels Data
activityData <- rbind(trainActivityData, testActivityData) 
colnames(activityData) <- c("idActivity")
#Subject Data
subjectData <- rbind(trainSubjectData,testSubjectData) 
subjectData$idObs <- seq.int(nrow(subjectData))

#1.3 Merging Features + Labels + Subject 
dataSet <- mutate(featuresData, idActivity = activityData$idActivity, idSubject = subjectData$idSubject)

#3. Appropriately labels the data set with descriptive variable names.
#3.1 Cleaning variables name
featuresName$name <- as.character(featuresName$name)
featuresName$name <- gsub("\\-","_",featuresName$name)
featuresName$name <- gsub("\\(\\)","",featuresName$name)
featuresName$name <- gsub("\\)","",featuresName$name)
featuresName$name <- gsub("\\(",".",featuresName$name)
dup <- duplicated(featuresName$name)
only_dup <- featuresName$name[dup]
temp <- cbind(only_dup,seq(1:length(only_dup)))
x <- apply(temp,1,function(x){
  ret <- gsub("[0-9]+[0-9]*,[0-9]+[0-9]*",x[2],x[1])
  ret
  })
featuresName$name[dup] <- x
colnames(dataSet)[1:561] <- featuresName$name

tidy <- dataSet %>% 
  gather(signal, value, -idActivity, -idSubject)

#2 Extracting measurements on the mean and std for each measurement.
tidy1 <- tidy %>% filter(grepl('(_mean_|_std_)',signal))

#3 Setting descriptive activity names to name the activities in the data set
tidy2 <- tidy1 %>% merge(activityLabels,by.x = "idActivity",by.y="id") %>% rename(activityName=name) %>% select(idSubject,activityName,signal,value)

#5 Creating a tidy data set with the average of each variable for each activity and each subject
tidy3 <- tidy2 %>% group_by(activityName,idSubject,signal) %>% summarise(avg = mean(value))
write.table(tidy3, file = "tidy.txt", sep = " ", quote=FALSE, row.names=FALSE)






