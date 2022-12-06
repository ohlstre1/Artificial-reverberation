clear all; close all;

[wav, fs] = audioread('testTrack.wav');
unitimpulse = zeros(1e5,1);
unitimpulse(1) = 1;

N = 32;                                % number of interconnected delay lines
A = randn(N);                          % feedback matrix, i.e. eye(N), magic(N), hadamard(N) or randn(N)
T60 = 0.30;                            % reverberation time
g_dB = -60/(T60 * fs);
g_lin = power(10, (g_dB/20));

b_gains = rand(1, N);        % Gains b_i are random
c_gains = rand(1, N);        % Gains c_i are random
m_delays = randi([2000, 10000],[1,N]);   % For randomised delay values between [2000, 10000]
g_gains = power(g_lin, m_delays);       % g_gains calculated by given equation

lowpass_mode = 'MA'; % Lowpass filter mode. No filtering (default): 'none', lowpass: 'lowpass', moving average: 'MA'
cutoff_frequency = 3000;
y = FDN_func(wav, fs, A, b_gains, c_gains, g_gains, m_delays, lowpass_mode, cutoff_frequency);
impulse_response = FDN_func(unitimpulse, fs, A, b_gains, c_gains, g_gains, m_delays, lowpass_mode, cutoff_frequency);

soundsc(y, fs)

L = length(impulse_response);
stem(linspace(1, L, L), 10*log10(abs(impulse_response)), 'Marker', 'none', 'BaseValue', -Inf)
grid on
xlim([-1e4, L])
ylim([-Inf, 10])
xlabel('Samples')
ylabel('Amplitude [dB]')
title('FDN system impulse response')