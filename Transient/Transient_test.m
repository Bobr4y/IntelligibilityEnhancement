clear all;
close all

% Load audio signal
[x,fs] = audioread('maleVoice.wav');
n = length(x);
Omega = pi*[-1 : 2/n : 1-1/n];
f = Omega*fs/(2*pi);
noise = 0.02*randn(n, 1);
px = sqrt(sum(x.^2));
Pn = sqrt(sum(noise.^2));
Pneed = px/(10^(-4.7/10));
noise = (Pneed/Pn) .* noise;

trans = transient_process(x, fs, 505);
enhanced = transient_amplify(x, trans, 10);

filter = Transient_static(enhanced, x);
X = fft(x);
static_enhanced = ifft(X.*filter);

siib_old = SIIB_Gauss(x, x+noise, fs);
siib_trans = SIIB_Gauss(enhanced, enhanced+noise, fs);
siib_static = SIIB_Gauss(static_enhanced, static_enhanced+noise, fs);

Ps = sqrt(sum(enhanced.^2));
Pn = sqrt(sum(noise.^2));

snr = 10*log10(Ps/Pn);

return;

E = fftshift(fft(enhanced));
X = fftshift(fft(x));

SIIB_old = SIIB_Gauss(x, x+noise', fs);
SIIB_new = SIIB_Gauss(enhanced, enhanced+noise', fs);

S = sqrt(sum(enhanced.^2));
N = sqrt(sum(noise.^2));
SNR = 10*log10(S/N);

% figure;
% subplot(2,1,1);
% plot(f, 2*abs(X));
% title('Original Speech');
% xlabel('Frequency [Hz]');
% ylabel('Magnitude');
% xlim([0 4000]);
% subplot(2,1,2);
% plot(f, 2*abs(E));
% title('Enhanced Speech');
% xlabel('Frequency [Hz]');
% ylabel('Magnitude');
% xlim([0 4000]);