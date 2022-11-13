clear all; close all;

[wav, fs] = audioread('testTrack.wav');
%soundsc(wav, fs);
L = length(wav);

N = 3;                          % number of interconnected delay lines
b_gains = [1.0, 4.0, 8.0];      % gains b_i
c_gains = [2.0, 1.0, 0.5];      % gains c_i
g_gains = [0.3, 0.5, 0.2];      % gains g_i
m_delays = [2000, 4000, 8000];  % delay amounts (in samples)
max_delay = max(m_delays);      % maximum amount of delay

A = eye(N);                     % feedback matrix
A = A/max(A, [], 'all');        % normalized feedback matrix 

X = zeros(L+2*max_delay,N);         % initialize delay lines
X(1+max_delay,:) = b_gains*wav(1);  % initialize first elements of delay line starting at max index

for j = 2+max_delay:L
    for i = 1:N
        X(j,i) = X(j,i) + b_gains(i)*wav(j-max_delay);
        for k = 1:N
            X(j+m_delays(k), k) = X(j+m_delays(k), k) + X(j,i)*g_gains(i)*A(i,k);
        end
    end
end

y = sum(X, 2);

soundsc(y, fs)