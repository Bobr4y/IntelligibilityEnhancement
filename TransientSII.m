clear all;
close all;

% Load audio signal
[original,Fs] = audioread('maleVoice.wav');
[train, Fst] = audioread('Train-noise.wav');
Fn = Fs/2;
n = length(original);

train = resample(train, Fs, Fst);
train = train(:,1);
m = length(train);
train = [train; zeros((n-m), 1)];
train = train .* 0.9;

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

% listening test data
S50 = 15.1/100; % parameters for speech-shaped noise (see [3])
L50 = -7.3;
intelligibility = [0.01 20:20:80 99]' % percentage of words correct
SNRdB =  L50-log((100-intelligibility)./intelligibility) / (4*S50) % invert Kjems psychometric curve to find the required SNR [3]

d = [];
siib_gauss=zeros(size(intelligibility));
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
    improved = improved + train;
    %original = original + train;

    for i = 1:length(improved(end,:))
        d(i,j) = SIIB_Gauss(original, improved(:,i), Fs);
        % compute SIIB^Gauss for different stimuli
        %siib_gauss(i) = SIIB_Gauss(x,y,fs);
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
title('SIIB Improved Signal');
xlabel('Transient Amplification');
ylabel('Intelligibility [%]');
legend('BW 20', 'BW 50', 'BW 100', 'BW 300', 'BW 500', 'BW 700');