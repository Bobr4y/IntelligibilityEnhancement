clear all;
close all

% Load audio signal
[x,fs] = audioread('maleVoice.wav');
noise = 0.03*randn(length(x), 1);
n = length(x);

[g converge error] = SIIB_Gain(x, noise, fs, 150);

figure;
plot(converge, 'o');
xlabel('Iteration Step');
ylabel('Determined Gain');

figure;
plot(error, 'o');
xlabel('Iteration Step');
ylabel('Absolute Error [bits/s]');

return;

g = SIIB_Gain(x, noise, fs, 120);

SIIB_Gauss(g*x, g*x+noise, fs)

return;

t = linspace(0, n/fs, n);
amp = linspace(0.01, 0.1, 10);

siib = [];
siib_old = [];
snr = [];
for i = 1:length(amp)
    i = 1;
    amp(i) = 0.02;
    Is = sii_opt(x, noise*amp(i), fs);
    siib(i) = SIIB_Gauss(Is, Is+noise*amp(i), fs);
    siib_old(i) = SIIB_Gauss(x, x+noise*amp(i), fs);
    snr(i) = 10*log(sum(abs(fftshift(fft(Is)))) / sum(abs(fftshift(fft(noise*amp(i))))));
end

figure;
plot(snr, siib_old);
hold on;
plot(snr, siib);
title('SIIB\_Opt vs SNR');
xlabel('SNR [dB]');
ylabel('SIIB\_Gauss [bits/s]');
legend('Original', 'SIIB\_Opt');

return;

figure;
plot(t, Is);
hold on;
plot(t, x);
title('SIIB\_Gauss Optimized');
xlabel('Time [s]');
ylabel('Amplitude');
legend('SIIB\_Opt', 'Original');

return;




It = Transient(x, fs);

X = fftshift(fft(x));
T = fftshift(fft(It));

t = linspace(0, n/fs, n);
Omega = pi*[-1 : 2/n : 1-1/n];
f = Omega*fs/(2*pi);

figure;
subplot(2,1,1);
plot(f, abs(X));
title('Spectrum Original');
xlabel('Frequency [Hz]');
ylabel('Amplitude');
subplot(2,1,2);
plot(f, abs(T));
title('Spectrum Transient Amplified');
xlabel('Frequency [Hz]');
ylabel('Amplitude');

figure;
subplot(2,1,1);
title('Original');
xlabel('Time [s]');
ylabel('Amplitude');
plot(t,x);
subplot(2,1,2);
title('Transient Amplified');
xlabel('Time [s]');
ylabel('Amplitude');
plot(t,It);

return;

% SIIB original
% siib_original = SIIB_Gauss(original, original+noise, Fs);
% 
% %% SIIB optimization
% Is = sii_opt(original, noise, Fs);
% siib_sii_opt = SIIB_Gauss(Is, Is+noise, Fs);


%% Lombard
clear all;
close all

% Load audio signal
[x,fs] = audioread('maleVoice.wav');
noise = 0.1*randn(3*length(x), 1);
n = length(x);

siib_lombard = [];
stretch = linspace(1,3,20);
for i = 1:length(stretch)
    Il = Lombard(x, fs, 0, stretch(i), 0, 0);
    noise_lombard = noise(1:length(Il));
    snr_need = -4.6902;
    px = sqrt(sum(Il.^2));
    pn = px/10^(snr_need/10);
    noise_lombard = pn/sqrt(sum(noise_lombard.^2))*noise_lombard;
    snr(i) = 10*log10(px/ pn);
    siib_lombard(i) = SIIB_Gauss(Il, Il+noise_lombard, fs);
end
plot(stretch, siib_lombard)
xlabel('Vowel stretch factor'); ylabel('SIIB^{Gauss} [bits/s]');

%%
clear all;
close all

% Load audio signal
[x,fs] = audioread('ButcherBlock.wav');

xstretched = Lombard(x, fs, 0, 2, 0, 0);
xtilted = Lombard(x, fs, 0, 1, 0.8, 0);
xcompress = Lombard(x, fs, 0, 1, 0, 30);

n = length(x);
t = linspace(0, n/fs, n);
Omega = pi*[-1 : 2/n : 1-1/n];
f = Omega*fs/(2*pi);
ts = linspace(0, length(xstretched)/fs, length(xstretched));

X = fftshift(fft(x));
Xt = fftshift(fft(xtilted));

figure
plot(t, x)
hold on
plot(ts,xstretched)
xlabel('Time [s]'); ylabel('Amplitude');

figure
plot(f, abs(Xt),'color',[0.8500 0.3250 0.0980])
hold on
plot(f, abs(X),'color',[0 0.4470 0.7410])
xlabel('Frequency [Hz]'); ylabel('Magnitude');

figure
plot(t,x)
hold on
plot(t,xcompress)
xlabel('Time [s]'); ylabel('Amplitude');

% ext = linspace(1, 3, 20);

% mod = [];
% siib_lombard = [];
% prompt = {'Bob', 'Ellen'};
% for i = 1:length(ext)
%     Il = Lombard(x, fs, 0, ext(i), 0, 10);
%     noise = 0.07*randn(length(Il), 1);
%     ext(i)
%     siib_lombard(i) = SIIB_Gauss(Il, Il+noise, fs)
%     soundsc(Il + noise, fs);
%     pause;
%     if (i ~= 0)
%         duration = length(Il)/fs;
%         answer = inputdlg(prompt);
%         mod(i) = (str2num(answer{1})/duration + str2num(answer{2})/duration)/2;
%     end
% end

return;
%%
imp = [];
imp(1) = mod(1);
for i = 2:length(mod)
    imp(i) = mod(i)+imp(i-1);
end

figure;
plot(ext, mod*50);
hold on;
plot(ext, siib_lombard);
title('Listening test vowel extension');
xlabel('Vowel Extension');
ylabel('Intelligibility');
legend('Listening Test', 'SIIB');



%% Transient
It = Transient(original, Fs);
siib_transient = SIIB_Gauss(It, It+noise, Fs);

%% Plot 
figure
plot(abs(fftshift(fft(Il))))
figure
plot(original)
hold on
plot(Il)
% figure;
% plot(tilt, siib_lombard);
% title('SIIB flattening spectral tilt');
% xlabel('Filter coefficient');ylabel('SIIB [bits/s]')