1. extractFeatures.m: This contains the code for extracting the Time domain and Frequency domain features.

2. main_student.m: This script processes all the raw data from /allData/ to extract features as defined in extractFeatures.m and outputs a csv file with labels and student ids.

3. classifiers.py: This python script reads the csv, processes it to output training and testing data. This data is then use to build and test the kNN and Random Forest Classifiers. It also handles leaving out a subject to test the trained model for crossvalidation

4. feature_all.csv: This contains data, labels and student ids with all the time and frequency domain features

5. feature_time_domain.csv: This contains data, labels and student ids with only time domain features

6. feature_freq_domain.csv: This contains data, labels and student ids with only frequency domain features
