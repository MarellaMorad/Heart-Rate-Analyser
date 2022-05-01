%clear all varibles and the command window before starting
clear; clc;
%load the data set
load Sample_1.mat;

fprintf('<strong> <<< Project B - Heart Rate Analyser >>> </strong> \n');

%% Plot before Filtering
%plot the data in a sub plot for the peaks to be plotted in the second sub
%plot
figure('Name', 'Heart Rate Analyser');
subplot(2,1,1);
% Orig_Sig is the varible that holds the data in the sample
data = Orig_Sig;
hndl = plot(data);
xlabel('Samples (360 samples/s)');
ylabel('Amplitude (mV)');
title('Original ECG Signal');
xlim([0 3650]);
hold on;

%Find the minimum y point for the graph window to be appropriate
miny = min(data);

%% Filtering data using a lowpass filter
data = lowpass(Orig_Sig,0.07); % 0.07 is the passband frequency, different from Project A!

%Find all peaks in the signal
[peaks, locs] = findpeaks(data);

%find the peaks and their locations and store the values in peaks_R and
%locs_R (only the R-peaks)
[peaks_R, locs_R] = findpeaks(data, 'MinPeakProminence',170); %Power point slides explaination

%Plot after Filtering
subplot(2,1,2);
plot(data);
hold on;

%Match find the R-peaks indicies in the matrix that holds all the peaks to
%be able to use it as a reference point
matchIdx = ismember(peaks, peaks_R); %logical varible that returns 1 or 0, 1 if the value is found and 0 if not found
R_Peaks_Match = find(matchIdx); %collecting the values that are equal to 1 and storing them in R_Peaks_Match

%% Looping through the data and using the R peaks as a refernece, since all
%the other attributes are related to it
for n = 1:length(locs_R)
    %% plotting the R peaks, with an upward red triangular marker
    plot(locs_R(n),peaks_R(n),'v','MarkerSize', 7.5, 'MarkerEdgeColor','r');
    hold on;
    
    %% Find and plot Q-peaks
    current_Q = locs_R(n); %assigning a varible for the R-peak that will be used a reference point
    previous_Q = current_Q - 2; %the Q-peak is before the R-peak, so lowering the value by 2
    % looping through the data based on the indicies current_Q and
    % previous_Q until finding a point where the current_Q is lower than
    % the previous_Q
    while data(current_Q) >= data(previous_Q)
        current_Q = previous_Q;
        previous_Q = previous_Q - 2;
    end
    %plotting the Q peaks, with a green squared marker
    plot(current_Q,data(current_Q),'s','MarkerSize', 7.5, 'MarkerEdgeColor','g');
    hold on; 

    %% Find and plot the S-peaks 
    %similar procedure is used to find the S peaks, except I am adding to
    %the current_S (index) since the S peak is after the R peak
    current_S = locs_R(n);
    if current_S < 3598
        next_S = current_S + 2;
        while data(current_S) >= data(next_S)
            if current_S < 3597
                current_S = next_S;
                next_S = next_S + 2;
            else
                break;
            end
        end
        plot(current_S,data(current_S),'x','MarkerSize', 7.5, 'MarkerEdgeColor','k');
        hold on;
    end
    
    %% Finding the P wave starting point
    for k = 1:3
        p_peaks(k) = locs(R_Peaks_Match(n) - k);
        p_max = max(data(p_peaks));
        p_max_index = find(data==p_max);
    end
    
	%Find and plot turning point of P_wave
    if p_max_index < 10
        current_TP_P = p_peaks(2);
    else
        current_TP_P = p_max_index;
    end
    
    previous_TP_P = current_TP_P - 2;
    while data(current_TP_P) >= data(previous_TP_P)
        if current_TP_P > 4
            current_TP_P = previous_TP_P;
            previous_TP_P = previous_TP_P - 2;
        else
            break;
        end
    end
    plot(current_TP_P,data(current_TP_P),'ro','MarkerSize', 7.5, 'MarkerEdgeColor','b');
    hold on;
    
    %% Finding the T-wave ending point
    if R_Peaks_Match(n) <= length(locs) - 4
        for l = 1:4
            t_peaks(l) = locs(R_Peaks_Match(n) + l);
            t_max = max(data(t_peaks));
            t_max_index = find(data==t_max);
        end
    end
    
	% Find and plot turning point of T_wave
    current_TP_T = t_max_index;
	if current_TP_T < 3598
        next_TP_T = current_TP_T + 2;
        while data(current_TP_T) >= data(next_TP_T)
            if current_TP_T < 3597
                current_TP_T = next_TP_T;
                next_TP_T = next_TP_T + 2;
            else
                break;
            end
        end
    plot(current_TP_T,data(current_TP_T),'d','MarkerSize', 7.5, 'MarkerEdgeColor','m');
    hold on;
    end
    
	xlabel('Samples (360 samples/s)');
    ylabel('Amplitude (mV)');
    title('Filterd ECG Signal');
    ylim([miny-50 max(peaks_R)+50]);
    xlim([0 3650]);
    hold on;
    
	%% Recording the requested values
    PR_Interval(n) = current_Q - current_TP_P;
    
    QT_Interval(n) = current_TP_T - current_Q;
    
    QRS_Duration(n) = current_S - current_Q;
end    

%% Calculating Average Values
%Average PR and PR inteval in sec
Ave_PR = mean(PR_Interval);
PR_s = Ave_PR*10/3600;

%Average QT and QT inteval in sec
Ave_QT = mean(QT_Interval);
QT_s = Ave_QT*10/3600;

%Average QRS and QRS Complex in sec
Ave_QRS = mean(QRS_Duration);
QRS_s = Ave_QRS*10/3600;

%% Displaying the average time intervals
fprintf('P-R interval: %.4f seconds \n', PR_s);
fprintf('Q-T interval: %.4f seconds \n', QT_s);
fprintf('QRS duration: %.4f seconds \n', QRS_s);

%% Comparing to the normal range and displaying the outcomes
if PR_s <= 0.20 && PR_s >= 0.12
    fprintf('Your PR Interval is <strong>IN</strong> the normal range! <strong>[That is between 0.12 and 0.20 seconds]</strong> \n');
else
    fprintf('Your PR Interval is <strong>OUT</strong> of the normal range! <strong>[That is between 0.12 and 0.20 seconds]</strong> \n');
end

if QT_s < 0.38
    fprintf('Your QT Interval is <strong>IN</strong> the normal range! <strong>[That is less than 0.38 seconds]</strong> \n');
else
    fprintf('Your QT Interval is <strong>OUT</strong> of the normal range! <strong>[That is less than 0.38 seconds]</strong> \n');
end

if QRS_s < 0.1
    fprintf('Your QRS duration is <strong>IN</strong> the normal range! <strong>[That is less than 0.1 seconds]</strong> \n');
else
    fprintf('Your QRS duration is <strong>OUT</strong> of the normal range! <strong>[That is less than 0.1 seconds]</strong> \n');
end