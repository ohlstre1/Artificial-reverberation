clear all; close all;

[wav, fs] = audioread('testTrack.wav');

N = 16;                             % number of interconnected delay lines
A = eye(N);                         % feedback matrix equals to identity matrix
T60 = 2;                            % Reverberation time -- higher value brings more echo ]1, 4[, for best results
g_dB = -60/(T60 * fs);
g_lin = power(10, (g_dB/20));

b_gains = rand(N,1);                % Randomised values between [0, 1] for input gains b_gains
c_gains = rand(1, N);               % Randomised values between [0, 1] for output gains c_gains
g_gains = ones(1, N);               % Setting all g_gain values to one
m_delays = randi([500,2000],[1,N]); % For randomised delay values between [500, 2000]

for i=1:16                          % g_gains calculated by given equation
    g_gains(i) = power(g_lin, m_delays(i));
end

y = FDN_func(wav, A, b_gains, c_gains, g_gains, m_delays);

soundsc(y, fs)