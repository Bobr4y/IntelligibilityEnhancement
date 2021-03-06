% Performance of Transient amplification according to STOI measure for
% different amplification factors
% Question: Is this a useful measure for us?
clear all;
close all;

% Load audio signal
[original,Fs] = audioread('clean_speech.wav');
[train, Fst] = audioread('Train-noise.wav');
Fn = Fs/2;
n = length(original);

train = resample(train, Fs, Fst);
train = train(:,1);
m = length(train);
train = [train; zeros((n-m), 1)];
train = train .* 0.4;

O = fft(original);
O = fftshift(O);

[hps, hpf] = highpass(original,700,Fs,'Steepness',0.95);
H = fft(hps);
H = fftshift(H);
t = linspace(0, (n/Fs), n);
Omega = pi*[-1 : 2/n : 1-1/n];
f = Omega*Fs/(2*pi);

%fvtool(hpf);

% figure;
% subplot(2,2,1);
% plot(original);
% title('malevoice.wav');
% 
% subplot(2,2,2);
% plot(hps);
% title('hps');
% 
% subplot(2,2,3);
% plot(f,abs(O));
% title('frequency spectrum');
% xlim([0 4000]);
% 
% subplot(2,2,4);
% plot(f,abs(H));
% title('frequency spectrum hps');
% xlim([0 4000]);

%Hfit = abs(H);
%freq = fit(transpose(f),Hfit,'cubicinterp');
%freq = freq(0:4000);
%freq = smoothdata(freq, 'movmedian', 800);

d = [];
center = [1000 2550 3700];
bw = [20 50 100 300 500 700];
for j = 1:6
    q1 = bandpass(hps, [(center(1) - (bw(j)/2)) (center(1) + (bw(j)/2))], Fs);
    q2 = bandpass(hps, [(center(2) - (bw(j)/2)) (center(2) + (bw(j)/2))], Fs);
    q3 = bandpass(hps, [(center(3) - (bw(j)/2)) (center(3) + (bw(j)/2))], Fs);
    
    trans = hps - q1 - q2 - q3;
    amplification = linspace(0, 25, 25);
    trans = trans .* amplification;
    improved = original + trans;
    
    % Normalize the improved signal power
    Po = sum(abs(original));
    Pi = sum(abs(improved));
    a = Po ./ Pi;
    improved = improved .* a;
    
    % Near-end noise
    noisy = improved + train;
    %original = original + train;

    for i = 1:length(noisy(end,:))
        d(i,j) = stoi(improved(:,i), noisy(:,i), Fs);
    end
end





% I = fft(improved);
% I = fftshift(I);

% figure;
% subplot(2,1,1);
% plot(improved, 'm');
% hold on;
% plot(original, 'b');
% xlim([2.655e5 2.95e5]);
% title('Transient Enhanced Speech Signal');
% xlabel('Time [s]');
% ylabel('Amplitude');
% legend('Enhanced speech', 'Original speech');
% 
% subplot(2,1,2);
% plot(f, abs(O), 'b');
% hold on;
% plot(f, abs(I), 'm');
% title('Frequency spectrum');
% xlim([0 4000]);
% xlabel('Frequency [Hz]');
% ylabel('Amplitude');

figure;
plot(amplification, d(:,1));
hold on;
for i = 2:length(d(end,:))
    plot(amplification, d(:,i));
end
hold off;
title('STOI Improved Signal');
xlabel('Transient Amplification');
ylabel('Intelligibility [%]');
legend('BW 20', 'BW 50', 'BW 100', 'BW 300', 'BW 500', 'BW 700');