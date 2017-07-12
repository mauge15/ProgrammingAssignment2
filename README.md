## Study Design

The dataset used for this study is: [Human Activity Recognition](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Step 1 is reading all the data from .txt files with `read.table`:

    trainFeaturesData <- read.table(file = "UCI HAR Dataset/train/X_train.txt",header=FALSE,dec=".")
    testFeaturesData <- read.table(file = "UCI HAR Dataset/test/X_test.txt",header=FALSE,dec=".")
    …

Step 2 is merging in every table the Test and Train Data with `rbind`:

    featuresData <- rbind(trainFeaturesData, testFeaturesData)
    activityData <- rbind(trainActivityData, testActivityData)
    …  

And finally merging all the tables: Features + Activity Labels + Subjects with `mutate`:

    dataSet <- mutate(featuresData, idActivity = activityData$idActivity, idSubject = subjectData$idSubject)

Step 3 is cleaning the features names, removing non accepted characters and fixing some problem with duplicate names. We use `gsub` function for replacing characters.

    featuresName$name <- as.character(featuresName$name)
    featuresName$name <- gsub("\\-","_",featuresName$name)
    …

Step 4 is tidying the data and extracting mean and std measurements. We use the functions `gather` and `filter’ for this purpose.

    tidy <- dataSet %>% gather(signal, value, -idActivity, -idSubject)
    tidy1 <- tidy %>% filter(grepl('(_mean_|_std_)',signal))

Step 5 is setting descriptive Activity names. Changing the ids (1-6) for WALKING, LAYING, etc.

    tidy2 <- tidy1 %>% merge(activityLabels,by.x = "idActivity",by.y="id") %>% rename(activityName=name) %>% select(idSubject,activityName,signal,value)

Step 6 is creating the final tidy data set with the average of each variable for each activity and each subject. The function `group_by` helps us to acheive this.

    tidy3 <- tidy2 %>% group_by(activityName,idSubject,signal) %>% summarise(avg = mean(value))

Finally we write the file `tidy.txt`.

## Code book

### Variables

* `activityName`: Text value with the name of the activity.
* `idSubject`: Integer value with the id of the subject of the experiment.
* `signal`: Text value with the name of the feature measured.
* `average`: The mean value of the corresponding feature.
