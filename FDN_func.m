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
    Proper use of this function requires that A is an N x N matrix, and
    each of the gain and delay vectors should have length N.

    The function outputs a single vector that is the original recording
    with applied artificial echo.

    The system is not causal, as it writes some values into the future.
    This works fine with prerecorded audio recordings, but may cause issues
    during real time echo application.
%}

function echo_audio = FDN_func(wav, A, b, c, g, delays)
    [sz_A_1, sz_A_2] = size(A);
    sz_b = length(b);
    sz_c = length(c);
    sz_g = length(g);
    sz_delays = length(delays);
    assert(sz_A_1 == sz_A_2 && sz_A_2 == sz_b && sz_b == sz_c && sz_c == sz_g && sz_g == sz_delays, 'Array lengths must be equal');
    N = sz_b;
    L = length(wav);
    max_delay = max(delays); % reverbation sound takes longer time than 
    
    %A = A/max(A, [], 'all');        % normalized feedback matrix 

    X = zeros(L+max_delay,N);         % initialize delay lines
    X(1,:) = b*wav(1);        % initialize first elements of delay line starting at max index

    for j = 1:L
        for i = 1:N
            X(j,i) = X(j,i) + b(i)*wav(j);
            for k = 1:N
                X(j+delays(k), k) = X(j+delays(k), k) + X(j,i)*g(i)*A(i,k);
            end
        end
    end

    echo_audio = sum(c.*X, 2);
end