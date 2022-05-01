%clear all varibles and the command window before starting
% clear; clc;
%load the data set
load Sample_1.mat;

fprintf('<strong> <<< Project A - Heart Rate Monitor >>> </strong> \n');

%% Plot before Filtering
%plot the data in a sub plot for the peaks to be plotted in the second sub
%plot
figure('Name', 'Heart Rate Monitor'); %naming the figure
subplot(2,1,1);
%Orig_Sig is the varible that holds the data in the sample
data = Orig_Sig;
plot(data);
xlabel('Samples (360 samples/s)'); %the x-axis represents the samples, not the seconds, with a rate of 360 samples/s
ylabel('Amplitude (mV)');
title('Original ECG Signal');
xlim([0 3650]);
hold on;

%Find the min and max y points for the graph window to be appropriate
miny = min(data);

%% Filtering data using a lowpass filter
data = lowpass(Orig_Sig,0.01); % 0.01 is the passband frequency

%% Plot after Filtering
subplot(2,1,2);
plot(data);
hold on;
xlabel('Samples');
ylabel('Amplitude (mV)');
hold off;

%Find the maximum y value for the graph window to be appropriate
maxy = max(data);

%% Finding the peaks of the filtered data and plotting it
subplot(2,1,2);
plot(data);
findpeaks(data, 'MinPeakProminence',140);
xlabel('Samples (360 samples/s)');
ylabel('Amplitude (mV)');
title('Filterd ECG Signal');
ylim([miny-100 maxy+100]);
xlim([0 3650]);
hold off;

% find the peaks and their locations and store the values in peaks and locs
[peaks, locs] = findpeaks(data, 'MinPeakProminence',140);

% calculating the heart beat
% peak difference is in terms of samples NOT ms or s
% The conversion to (beats per minute) is calculated via:
% time in sec is found by using the sample rate that is 360 samples per
% second which results in 10 seconds in total. The conversion is as
% follows:
PeakDiff = mean(diff(locs));
sPerBeat = PeakDiff*10/3600;
% heartbeat in bpm = 60 / (time in s)
heartBeat = 60/sPerBeat;
% display the heartbeat to 2 decimal places
fprintf('The heartbeat of this sample is: %.2f bpm.\n', heartBeat');