% Transforms signal into noise
% Question: Is it useful to keep looking into this?
clear all;
close all;
addpath('../Measures/')
% Load audio signal
[original,Fs] = audioread('Sounds/maleVoice.wav');
[train, Fst] = audioread('Sounds/Train-noise.wav');
Fn = Fs/2;
n = length(original);

% Resample and resize train noise
train = resample(train, Fs, Fst);
train = train(:,1);
m = length(train);
train = [train; zeros((n-m), 1)];
train = train .* 0.6;

% Fourrier transforms
T = fft(train);
T = fftshift(T);
t = linspace(0, (n/Fs), n);
Omega = pi*[-1 : 2/n : 1-1/n];
f = Omega*Fs/(2*pi);
O = fft(original);
O = fftshift(O);

%%%%%%%%%%%%%%%%%%%%%%%%
% Option 1: constant SNR
SNR1 = abs(O) ./ abs(T);

a = sqrt(abs(T)) ./ sqrt(abs(O));
improved = original .* a;

b = sum(abs(original)) / sum(abs(improved));
improved = improved .* b;

I = fft(improved);
I = fftshift(I);

SNR2 = abs(I) ./ abs(T);

improved = improved + train;
d = stoi(original, improved, Fs);

figure;
sgtitle('Constant SNR STOI = ' + string(d));

subplot(2,2,1);
plot(f, abs(T));
hold on;
plot(f, abs(O));
title('original');

subplot(2,2,2);
plot(f, abs(T));
hold on;
plot(f, abs(I));
title('improved');

subplot(2,2,3);
plot(f, SNR1);

subplot(2,2,4);
plot(f, SNR2);

%sound(improved, Fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Option 2: don't compete with noise
% Most noise power is between 0 and 800 Hz
improved = bandpass(original, [800 4000], Fs);

% Normalize power
b = sum(abs(original)) / sum(abs(improved));
improved = improved .* b;

I = fft(improved);
I = fftshift(I);

SNR2 = abs(I) ./ abs(T);

improved = improved + train;
d = stoi(original, improved, Fs);

figure;
sgtitle('Dont compete STOI = ' + string(d));

subplot(2,2,1);
plot(f, abs(T));
hold on;
plot(f, abs(O));
title('original');

subplot(2,2,2);
plot(f, abs(T));
hold on;
plot(f, abs(I));
title('improved');

subplot(2,2,3);
plot(f, SNR1);

subplot(2,2,4);
plot(f, SNR2);

%sound(improved, Fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Option 3: remove unneccessary frequency bands
% Most noise power is between 0 and 800 Hz
% Gender identification is tussen 3kHz en 7kHz (klopt waarschijnlijk niet)
improved = bandpass(original, [800 4000], Fs);
improved = bandstop(improved, [3000 4000], Fs);

% Normalize power
b = sum(abs(original)) / sum(abs(improved));
improved = improved .* b;

I = fft(improved);
I = fftshift(I);

SNR2 = abs(I) ./ abs(T);

improved = improved + train;
d = stoi(original, improved, Fs);

figure;
sgtitle('Remove bands STOI = ' + string(d));

subplot(2,2,1);
plot(f, abs(T));
hold on;
plot(f, abs(O));
title('original');

subplot(2,2,2);
plot(f, abs(T));
hold on;
plot(f, abs(I));
title('improved');

subplot(2,2,3);
plot(f, SNR1);

subplot(2,2,4);
plot(f, SNR2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Option 4: boost first 3 formants
f1 = bandpass(original, [650 1500], Fs);
f2 = bandpass(original, [2300 2800], Fs);
f3 = bandpass(original, [3450 4000], Fs);
improved = f1 + f2 + f3;

% Normalize power
b = sum(abs(original)) / sum(abs(improved));
improved = improved .* b;

I = fft(improved);
I = fftshift(I);

SNR2 = abs(I) ./ abs(T);

improved = improved + train;
d = stoi(original, improved, Fs);

figure;
sgtitle('Formant amplification STOI = ' + string(d));

subplot(2,2,1);
plot(f, abs(T));
hold on;
plot(f, abs(O));
title('original');

subplot(2,2,2);
plot(f, abs(T));
hold on;
plot(f, abs(I));
title('improved');

subplot(2,2,3);
plot(f, SNR1);

subplot(2,2,4);
plot(f, SNR2);

sound(improved, Fs);