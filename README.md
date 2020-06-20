# Human-Action-Recognition
This is a research project carried out in the months of August-November 2019.

## Description
Human   Action   Recognition   (HAR)   is   the   process   of examining and recognizing the nature of the action performed by  humans  in  a  video  sequence.  The  innate  ability  of  ahuman  to  understand  another  person’s  activities  has  been  animportant  subject  of  study  in  the  field  of  computer  vision. HAR   methods   are   widely   applied   in   building   electronicsystems supported machine intelligence like intelligent policework,  human-machine  interaction,  biometrics,  health  care,and so on.
This project is a study on trajectory based, with structure and motion descriptors, human action recognition. Structural and motion descriptors are used as desriptors of the human actions. SVM is used for classification.



### Dataset
The dataset used is [KTH dataset](http://www.nada.kth.se/cvap/actions/).
Consists of six human action classes:walking, jogging, running, boxing, waving and clapping. Each action  is  performed  several  times  by  25  subjects.  The  sequences  were  recorded  in  four  different  scenarios:  outdoors,outdoors with scale variation, outdoors with different clothes, and  indoors.

## Methodology
1. Localizing the human using YOLO algorithm and obtain a bouding box
2. Extracting key points using Harris detector within the bounding box
3. Tracking the key points, along with their neighbourhood, using KLT tracker to obtain a 3D cube. Tracking is done for 15 frames and new key points are detected after every 15 frames.
4. Extracting descriptors like Histogram of Optical Flow, Motion Boundary Histogram, Center-symmetric Local Binary Patterns along with the displacement of the key points along the frames.
5. Feed the descriptors to kmeans to get the clusters. (Number of clusters can be varied and experimented with)
6. Obtain the bag of features using the descriptors and clusters
7. Provide the bag of features to Support Vector Machine (SVM) for classification

## Running the application
1. Run [feature_extraction.m](https://github.com/Shivmohith/Human-Action-Recognition/blob/master/Codes/feature_extraction.m) to perform the steps 1 to 4 explained in Methodology.