clear all; close all;

[wav, fs] = audioread('testTrack.wav');
unitimpulse = zeros(1e5,1);
unitimpulse(1) = 1;

N = 128;                                % number of interconnected delay lines
A = randn(N);                           % feedback matrix
T60 = 0.6;                              % reverberation time
g_dB = -60/(T60 * fs);
g_lin = power(10, (g_dB/20));

b_gains = rand(1, N);        % Randomised values between [0, 1] for input gains b_gains
c_gains = rand(1, N);        % Randomised values between [0, 1] for output gains c_gains
m_delays = randi([2000, 10000],[1,N]);   % For randomised delay values between [2000, 10000]
g_gains = power(g_lin, m_delays);       % g_gains calculated by given equation

y = FDN_func(wav, A, b_gains, c_gains, g_gains, m_delays);
impulse_response = FDN_func(unitimpulse, A, b_gains, c_gains, g_gains, m_delays);

soundsc(y, fs)

L = length(impulse_response);
stem(linspace(1, L, L), 10*log10(abs(impulse_response)), '|', 'BaseValue', -Inf)
grid on
xlim([-1e4, L])
ylim([-Inf, 10])
xlabel('Samples')
ylabel('Amplitude [dB]')
title('FDN system impulse response')