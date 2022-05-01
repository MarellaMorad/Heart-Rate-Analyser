%Project B

load Sample_1;
Sample=Orig_Sig;

%Project B reuses some elements of Project A, which have been
%%%'simplified' here
[num,loc]=findpeaks(Sample,'MinPeakHeight',max(Sample)-220,'MinPeakProminence',170);
numPeaks = numel(loc);
loc_p1=loc(1);
loc_p2=loc(numel(loc));
BPM=21600*(numel(loc)-1)/(loc_p2-loc_p1);
fprintf('The BPM is %3.0f\n',BPM)

%Displaying orginal ECG and filtered ECG wave
%recording digitised at 360 samples per second
length(Sample)=3600;
D=1:3600;
t=D./360;
Fs=360;

%plotting noisy signal
figure
subplot(2,1,1)
plot(t,Sample);
title('Original ECG Signal');
xlabel('Time(s)');
ylabel('Amplitude');
hold on
plot(loc/360,num,'ro')

%lowpass butterworth filter 
%cutofffrequency=18, fs=360; fNorm = cutofffreq /(fs/2) = 1/10;
[b,a]=butter(10,1/10,'low');
y=filtfilt(b,a,Sample);

%plotting filtered signal with R peaks 
subplot(2,1,2);
plot(t,y)
ylim([min(Sample)-50, max(Sample)+50]);
hold on
[num_y,loc_y]=findpeaks(y,'MinPeakHeight',0.797*max(y),'MinPeakProminence',100);
plot(t(loc_y),y(loc_y),'ro')

%finding Q points
for q=1:numel(loc_y)
    current_q = loc_y(q);
    next = current_q - 2;
        while y(current_q) >= y(next)
        current_q = next;
        next = next - 2;
        end
    plot(t(current_q),y(current_q),'co')
    loc_q(q) = current_q;   
end

%finding S points
for s=1:numel(loc_y)
    current_s = loc_y(s);
    next = current_s + 1;
        while y(current_s) >= y(next)
        current_s = next;
        next = next + 1;
        end
    plot(t(current_s),y(current_s),'bo')
    loc_s(s) = current_s; 
end

%finding P peaks %%%%%%%%%%%%%%%%%
for p1=1:numel(loc_q)
    current_p1 = loc_q(p1);
    next = current_p1 - 1;
        while y(current_p1) <= y(next)
        current_p1 = next;
        next = next - 1;
        end
    loc_p1(p1) = current_p1;   
end
%finding P points
for p =1:numel(loc_p1)
    current_p = loc_p1(p);
    next = current_p - 1;
        while y(current_p) >= y(next)
        current_p = next;
        next = next - 1;
        end
    plot(t(current_p),y(current_p),'go')
    loc_p(p) = current_p;   
end

%finding T peaks %%%%%%%%%%%%%%%%%
for t1=1:numel(loc_s)
    current_t1 = loc_s(t1);
    next = current_t1 + 1;
        while y(current_t1) <= y(next)
        current_t1 = next;
        next = next + 1;
        end
    loc_t1(t1) = current_t1;   
end
%finding T points
for t2 =1:numel(loc_t1)
    current_t2 = loc_t1(t2);
    next = current_t2 + 1;
        while y(current_t2) >= y(next)
        current_t2 = next;
        next = next + 1;
        end
    plot(t(current_t2),y(current_t2),'mo')
    loc_t2(t2) = current_t2;   
end


%FOR P-R INTERVAL
interval_PR = (loc_q-loc_p)/360;
avint_PR = mean(interval_PR);
fprintf('P-R Interval: %.4f\n',avint_PR)
if avint_PR<0.12 | avint_PR>0.20
    disp('P-R Interval is outside the normal range of 0.12 to 0.20 seconds')
end


%FOR Q-T INTERVAL
interval_QT = (loc_t2-loc_s)/360;
avint_QT = mean(interval_QT);
fprintf('Q-T Interval: %.4f\n',avint_QT)
if avint_QT>=0.38
    disp('Q-T Interval is outside the normal range of <0.38 seconds')
end


%FOR QRS INTERVAL 
interval_QRS = (loc_s-loc_q)/360;
avint_QRS = mean(interval_QRS);
fprintf('QRS duration: %.4f\n',avint_QRS)
if avint_QRS>=0.1
    disp('QRS duration is outside the normal range of <0.1 seconds')
end



