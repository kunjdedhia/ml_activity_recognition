clear;
close all;
warning off
 
 
%put your netid here
my_netid = 'kdedhia'; %<---------- input your net id

% location of data directory
dataDir = [pwd,'/allData/'];

dataDirNames = dir(dataDir);
 
k = 1;
featureMartix = [];
phone_position = []; %1 hand, 0 for pocket
subjectIds = {};
for i = 1:length(dataDirNames)
           
    %goes through all of the directories representing all imei addresses
    if exist([dataDir dataDirNames(i).name],'dir') == 7 && dataDirNames(i).name(1) ~= '.'
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % assign subject id
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(dataDirNames(i).name,my_netid)
            index = 0; %assign zero index to you (with specified netid)
        else
            index = k;
            subjectIds{k,1} = dataDirNames(i).name; %assign subejctId
            k = k + 1;
        end
        fprintf('Processing directory %s\n',dataDirNames(i).name);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute raw data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        dirName = [dataDir dataDirNames(i).name '/']; %specify where data is in the folder
        
        %
        % raw_data_vector: N*4 dimensional. Contains raw accelerometer and
        %       barometer data. First 3 dimensions represent the 3 axes of
        %       accelerometer.
        % raw_data_label: Contains labels for data points in raw_data_vector
        % bar_ts: has timestamp data for barometric pressure. This works
        %       as timestamps for raw_data_vector and raw_data_label
        %
        [raw_data_vector,raw_data_label, bar_ts] = computeRawData( dirName ); %do a visualize on or off
        save([dataDir 'data_' dataDirNames(i).name '.mat'],'raw_data_vector','raw_data_label','bar_ts');
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute the features
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        load([dataDir 'data_' dataDirNames(i).name '.mat'])
        
        %
        %CORRECTION:
        % featureVector : N*16 dimensional.
        %       Column 1 to 14 are different features computed. Look at
        %           'print_top_five_features.m' file for a complete
        %           description of the features
        %       Last column of featureVector is
        %           subjectId. 0 represent your data if you set the right imei
        %       2nd to last column of featureVector is labels
        %
        
        featureVector = extractFeatures([dataDir 'data_' dataDirNames(i).name '.mat'] );
        featureVector = [featureVector  index*ones(size(featureVector,1),1)]; %last column is subject id, 2nd to last column is activity label
        save([dataDir 'data_' dataDirNames(i).name '.mat'],'raw_data_vector','raw_data_label','bar_ts','featureVector');
 
        
        
        %load into feature martrix
        featureMartix = [ featureMartix  ; featureVector ];
    end
end
 
writematrix(featureMartix, "features.csv");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%        visulaize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%load your data to visualize
load([dataDir 'data_' my_netid '.mat']);
load label_names
fprintf('Visualizeing raw data and features\n');
 
addpath('./libs/')
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot raw data
% visualizes raw data to get a sense what features might work
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
activity_names_indexed=activity_names_indexed(1:7,1);
%compute accelerometer magnitude
accel_mag = sqrt(raw_data_vector(:,1).^2 + raw_data_vector(:,2).^2 + raw_data_vector(:,3).^2);
%activity_names_indexed=activity_names_indexed(1:7,1);
%plot raw data
figure(1)
subplot(312)
plot(accel_mag) %accelerometer magnitude
axis tight
ylim([0 30])
xlabel('accelerometer magnitude')
grid on
subplot(313)
plot(raw_data_vector(:,4)) %barometric pressure
axis tight
xlabel('barometeric pressure')
grid on
subplot(311)
plot(featureVector(:,end-1))
axis tight
set(gca,'ytick',1:length(activity_names_indexed));
set(gca,'yticklabel',activity_names_indexed);
grid on
xlabel('labels')
ylim([0 length(activity_names_indexed)+1])
title('data')
 
% plot the top features
% visualize discriminating features
figure(2)
subplot(312)
plot((featureVector(:,2))) % variance of accelerometer magnitude
axis tight
ylim([0 70])
xlabel('accel magnitude variance')
subplot(313)
plot(featureVector(:,end-2)) %bar_slope
axis tight
xlabel('barometer slope')
subplot(311)
plot(featureVector(:,end-1))
axis tight
set(gca,'ytick',1:length(activity_names_indexed));
set(gca,'yticklabel',activity_names_indexed);
grid on
xlabel('labels')
ylim([0 length(activity_names_indexed)+1])
title('feature view')
 
 
