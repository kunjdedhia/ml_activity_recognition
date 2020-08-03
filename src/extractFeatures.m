function featureVector = extractFeatures(file_name)

load(file_name)

featureVector = [];
activityLabel = [];
% Here we are extracting the magnitude of the 3D accelerometer values
y_accel_mag = sqrt(raw_data_vector(:,1).^2 + raw_data_vector(:,2).^2 + raw_data_vector(:,3).^2);
% Here we are extracting the barometer data from the 4th column of the
% raw_data_vector
y_bar_value =  raw_data_vector(:,4);
k = 1;
for i = 1:64:size(raw_data_vector,1)-320

    y_accel_mag_vals = y_accel_mag(i:i+320-1);
    y_bar_value_vals = y_bar_value(i:i+320-1);
    
    % extract 20 time domain (TD) features (10 accel mag TD features and 10 barometer TD features)
    %median 
    y_accel_mag_median = median(y_accel_mag_vals);
    y_bar_value_median = median(y_bar_value_vals);
    
    %standard deviation
    y_accel_mag_std = std(y_accel_mag_vals);
    y_bar_value_std = std(y_bar_value_vals);
    
    %skewness
    y_accel_mag_skewness = skewness(y_accel_mag_vals);
    y_bar_value_skewness = skewness(y_bar_value_vals);
    
    %mean crossing rate
    y_accel_mag_threshold = mean(y_accel_mag_vals);
    y_bar_value_threshold = mean(y_bar_value_vals);
    
    y_accel_mag_mcr = length(find(diff((y_accel_mag_vals) > y_accel_mag_threshold)))/320;
    y_bar_value_mcr = length(find(diff((y_bar_value_vals) > y_bar_value_threshold)))/320;
    
    %slope
    y_accel_mag_linearFit = polyfit(transpose(i:i+320-1),(y_accel_mag_vals),1);
    y_bar_value_linearFit = polyfit(transpose(i:i+320-1),(y_bar_value_vals),1);
    
    y_accel_mag_slope = y_accel_mag_linearFit(1);
    y_bar_value_slope = y_bar_value_linearFit(1);
    
    %interquartile range
    y_accel_mag_iqr = iqr(y_accel_mag_vals);
    y_bar_value_iqr = iqr(y_bar_value_vals);
    
    %25th percentile
    y_accel_mag_quarter = prctile(y_accel_mag_vals, 25);
    y_bar_value_quarter = prctile(y_bar_value_vals, 25);
    
    %number of peaks
    [y_accel_mag_peaks, y_accel_mag_locs] = findpeaks(y_accel_mag_vals);
    [y_bar_value_peaks, y_bar_value_locs] = findpeaks(y_bar_value_vals);
    
    y_accel_mag_peaksNum = length(y_accel_mag_peaks);
    y_bar_value_peaksNum = length(y_bar_value_peaks);
    
    %mean of peaks
    y_accel_mag_peaksMean = mean(y_accel_mag_peaks);
    y_bar_value_peaksMean = mean(y_bar_value_peaks);
    
    %mean of peak distances
    y_accel_mag_peaksDist = mean(diff(y_accel_mag_locs));
    y_bar_value_peaksDist = mean(diff(y_bar_value_locs));
    
    % extract 10 frequency domain (FD) features (5 accel mag FD features and 5 barometer FD features)
    fs = 32;
    FFTLen = 1024;

    hamming_accel = y_accel_mag_vals - mean(y_accel_mag_vals);
    hamming_accel = hann(320).*(hamming_accel);
    hamming_bar = y_bar_value_vals - mean(y_bar_value_vals);
    hamming_bar = hann(320).*(hamming_bar);

    fft_accel = abs(fft(hamming_accel,FFTLen));
    fft_accel = fft_accel(1:FFTLen/2+1);
    fft_bar = abs(fft(hamming_bar,FFTLen));
    fft_bar = fft_bar(1:FFTLen/2+1);

    freq_bins = [0:FFTLen/2]*fs/FFTLen;

    %spectral centroid
    y_accel_mag_specCentroid = (freq_bins*fft_accel)/sum(fft_accel);
    y_bar_value_specCentroid = (freq_bins*fft_bar)/sum(fft_bar);

    %spectral spread
    y_accel_mag_specSpread = (((freq_bins - y_accel_mag_specCentroid).^2 * fft_accel)/sum(fft_accel))^0.5;
    y_bar_value_specSpread = (((freq_bins - y_bar_value_specCentroid).^2 * fft_bar)/sum(fft_bar))^0.5;

    %spectral roll off 75
    spec_sum_75th = sum(fft_accel) * 0.75;
    acc = 0;
    for j=1:FFTLen
        if (acc > spec_sum_75th)
            break
        end
        acc = acc + fft_accel(j);
    end
    y_accel_mag_specRollOff = freq_bins(j);
    
    spec_sum_75th = sum(fft_bar) * 0.75;
    acc = 0;
    for j=1:FFTLen
        if (acc > spec_sum_75th)
            break
        end
        acc = acc + fft_bar(j);
    end
    y_bar_value_specRollOff = freq_bins(j);

    %filter bank
    y_accel_mag_bank1 = trapz(fft_accel(1: floor(length(fft_accel)/2)));
    y_bar_value_bank1 = trapz(fft_bar(1: floor(length(fft_bar)/2)));

    y_accel_mag_bank2 = trapz(fft_accel(floor(length(fft_accel)/2) + 1: length(fft_accel)));
    y_bar_value_bank2 = trapz(fft_bar(floor(length(fft_bar)/2) + 1: length(fft_bar)));

    % Make sure that you have added all the features to the featureVector
    % matrix
    featureVector(k,:) = [y_accel_mag_median y_bar_value_median, y_accel_mag_std y_bar_value_std, y_accel_mag_skewness y_bar_value_skewness, y_accel_mag_mcr y_bar_value_mcr, y_accel_mag_slope y_bar_value_slope, y_accel_mag_iqr y_bar_value_iqr, y_accel_mag_quarter y_bar_value_quarter, y_accel_mag_peaksNum y_bar_value_peaksNum, y_accel_mag_peaksMean y_bar_value_peaksMean, y_accel_mag_peaksDist y_bar_value_peaksDist, y_accel_mag_specCentroid y_bar_value_specCentroid, y_accel_mag_specSpread y_bar_value_specSpread, y_accel_mag_specRollOff y_bar_value_specRollOff, y_accel_mag_bank1 y_bar_value_bank1, y_accel_mag_bank2 y_bar_value_bank2];
    activityLabel = [activityLabel; mode(raw_data_label(i:i+319,1))];
    
    k = k + 1;
end


featureVector = [featureVector,activityLabel];% Adding activityLabel in the last column of the featureVector