% ELEC-C5341 SASP

%{
    This is a function for applying a FDN echo onto any input signal. The
    function requires the following inputs:
        wav: the audio recording to which echo is to be applied
        A: feedback matrix of the FDN system
        b: vector containing gains b_i of the FDN system
        c: vector containing gains c_i of the FDN system
        g: vector containing gains g_i of the FDN system
        delays: array containing the delays of each feedback echo
    The function also accepts two optional inputs:
        lowpass_mode: determines if lowpass filtering is used.
            'none' (default): no lowpass filtering
            'lowpass': regular lowpass filtering
            'MA': lowpass filtering by moving average
        f_c: cutoff frequency for lowpass filter. Defaults to 3400 (Hz) if no
        value is given.
    Proper use of this function requires that A is an N x N matrix, and
    each of the gain and delay vectors should have length N.   
%}

function echo_audio = FDN_func(wav, fs, A, b, c, g, delays, lowpass_mode, f_c)
    [sz_A_1, sz_A_2] = size(A);
    sz_b = length(b);
    sz_c = length(c);
    sz_g = length(g);
    sz_delays = length(delays);
    assert(sz_A_1 == sz_A_2 && sz_A_2 == sz_b && sz_b == sz_c && sz_c == sz_g && sz_g == sz_delays, 'Array lengths must be equal');
    
    if(~exist('lowpass_mode', 'var'))
        lowpass_mode = 'none';
    end
    if(~exist('f_c', 'var'))
       f_c = 3400; 
    end
    
    N = sz_b;
    L = length(wav);
    max_delay = max(delays); % reverbation sound takes longer time than 
    
    A = A/max(A, [], 'all');        % normalized feedback matrix

    X = zeros(L+max_delay,N);         % initialize delay lines
    
    if(strcmp(lowpass_mode, 'lowpass') || strcmp(lowpass_mode, 'MA'))
        [filt_b, filt_a] = butter(1, f_c/(fs/2));
        for i = 1:N
            X(1:L,i) = lpfilt(X(1:L,i) + b(i)*wav(1:L), filt_b, filt_a);
            for k = 1:N
                X(delays(k)+1:delays(k)+L,k) = X(delays(k)+1:delays(k)+L,k) + 0.5*X(1:L,i)*A(i,k);
            end
        end
    else
        for j = 1:L
            for i = 1:N
                X(j,i) = X(j,i) + b(i)*wav(j);
                for k = 1:N
                    index = j+delays(k);
                    X(index, k) = X(index, k) + X(j,i)*g(i)*A(i,k);
                end
            end
        end
    end

    echo_audio = sum(c.*X, 2)/N;
end