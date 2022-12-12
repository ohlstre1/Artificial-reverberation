clear all; close all;

[wav, fs] = audioread('testTrack.wav');

N = 16;                                 % number of interconnected delay lines
A = randn(N);                           % feedback matrix, i.e. eye(N), magic(N), hadamard(N) or randn(N)
T60 = 1;                                % reverberation time
g_dB = -60/(T60 * fs);
g_lin = power(10, (g_dB/20));

b_gains = rand(1, N);
c_gains = 1./b_gains;
m_delays = randi([2000, 10000],[1,N]);  % For randomised delay values between [2000, 10000]
g_gains = power(g_lin, m_delays);       % g_gains calculated by given equation

lowpass_mode = 'lowpass'; % Lowpass filter mode. No filtering: 'none', lowpass: 'lowpass', butterworth: 'butter', moving average: 'MA'

if(strcmp(lowpass_mode, 'MA'))
    y = FDN_func(wav, fs, A, b_gains, c_gains, m_delays, lowpass_mode);
    impulse_response = plotImpulseResponse(fs, A, b_gains, c_gains, m_delays, lowpass_mode);
else
    if(strcmp(lowpass_mode, 'lowpass'))
        final_parameter = T60;
    elseif(strcmp(lowpass_mode, 'butter'))
        final_parameter = 800; % Cutoff frequency for butterworth lowpass filter
    else
        final_parameter = g_gains;
    end
    y = FDN_func(wav, fs, A, b_gains, c_gains, m_delays, lowpass_mode, final_parameter);
    impulse_response = plotImpulseResponse(fs, A, b_gains, c_gains, m_delays, lowpass_mode, final_parameter);
end

soundsc(y, fs)
