clear all; close all;

[wav, fs] = audioread('testTrack.wav');

N = 3;                          % number of interconnected delay lines
A = eye(N);                     % feedback matrix
b_gains = [1.0, 4.0, 8.0];      % gains b_i
c_gains = [2.0, 1.0, 0.5];      % gains c_i
g_gains = [0.3, 0.5, 0.2];      % gains g_i
m_delays = [2000, 4000, 8000];  % delay amounts (in samples)

y = FDN_func(wav, A, b_gains, c_gains, g_gains, m_delays);

soundsc(y, fs)