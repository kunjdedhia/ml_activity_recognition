import numpy as np 
import csv
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix
import pandas as pd


def getTrainData(filteredData):
    xData = np.nan_to_num(filteredData[:, :-2])
    yData = np.nan_to_num(filteredData[:, -2])
    return xData, yData

def splitStudentData(data, id):
    sId = data[:, -1]
    allIdx = np.where(sId == id)[0]
    testData = data[allIdx[0]:allIdx[-1]+1, :]
    trainData =  np.delete(data,np.s_[allIdx[0]:allIdx[-1]+1],axis=0)
    return trainData, testData

def kNN(xTrain, yTrain, xTest, yTest):
    print('Running K-Nearest Neighbor Classifier...')
    neigh = KNeighborsClassifier()
    neigh.fit(xTrain, yTrain)
    predict = neigh.predict(xTest)
    cM = getConfusionMat(predict, yTest)
    getResults(cM)


def randomForest(xTrain, yTrain, xTest, yTest):
    print('Running Random Forest Classifier...')
    rf = RandomForestClassifier()
    rf.fit(xTrain, yTrain)
    predict = rf.predict(xTest)
    return getConfusionMat(predict, yTest)


def division(x, y):
    if y == 0 or not y:
        return 0
    return x / y


def getConfusionMat(yPred, yTrue):
    return confusion_matrix(yTrue, yPred, labels=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10])


def getResults(confusionMat):
    print('Total Confusion Matrix:\n')
    colNames = []
    rowNames = []
    scores = []
    act = []
    for i in range(0, len(confusionMat)):
        colNames.append('Pred Activ ' + str(i+1))
        rowNames.append('Act Activ ' + str(i+1))
        act.append('Activ ' + str(i+1))
    df = pd.DataFrame(confusionMat, columns=colNames, index=rowNames)
    print(df)
    sumCM = confusionMat.sum()
    for i in range(0, len(confusionMat)):
        tp = confusionMat[i, i]
        fn = np.sum(confusionMat[i, :]) - tp
        fp = np.sum(confusionMat[:, i]) - tp
        tn = sumCM - tp - fn - fp
        recall = division(tp, tp + fn) * 100
        precision = division(tp, tp + fp) * 100
        accuracy = (tp + tn)/sumCM * 100
        f1 = 2 * division(recall * precision, recall + precision)
        scores.append([round(recall, 2), round(precision, 2), round(accuracy, 2), round(f1, 2)])
        print('\nConfusion Matrix for Activity ' + str(i+1) + ':\n')
        df = pd.DataFrame(np.array([[tp, fn], [fp, tn]]), columns=['Pred Activ ' + str(i+1), 'Pred Else'], index=['Act Activ ' + str(i+1), ' Act Else'])
        print(df)
        print('\nRecall: ' + str(round(recall, 2)))
        print('Precision: ' + str(round(precision, 2)))
        print('Accuracy: ' + str(round(accuracy, 2)))
        print('F1: ' + str(round(f1, 2)) + '\n\nSummary of Scores: \n')
    df = pd.DataFrame(np.asarray(scores), columns=['Recall', 'Precision', 'Accuracy', 'F1'], index=act)
    print(df)
    
# train on everyone else's data
# test on my data
my_data = np.genfromtxt('features_all.csv', delimiter=',')
print('Test Student ID: 0')
trainData, testData = splitStudentData(my_data, 0)
xTrain, yTrain = getTrainData(trainData)
xTest, yTest = getTrainData(testData)
kNN(xTrain, yTrain, xTest, yTest)
randomForest(xTrain, yTrain, xTest, yTest)

# cross validation
sumConfusionMat = np.zeros((10, 10))
my_data = np.genfromtxt('features_all.csv', delimiter=',')
for i in range(0, 34):
    print('Test Student ID: ' + str(i))
    trainData, testData = splitStudentData(my_data, i)
    xTrain, yTrain = getTrainData(trainData)
    xTest, yTest = getTrainData(testData)
    cM = randomForest(xTrain, yTrain, xTest, yTest)
    sumConfusionMat = np.add(sumConfusionMat, cM)

getResults(sumConfusionMat)


