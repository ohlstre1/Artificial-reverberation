% ELEC-C5341 SASP

%{
    This is a function for applying a FDN echo onto any input signal. The
    function requires the following inputs:
        wav: the audio recording to which echo is to be applied.
        fs: sample rate of recording.
        A: feedback matrix of the FDN system.
        b: vector containing gains b_i of the FDN system.
        c: vector containing gains c_i of the FDN system.
        delays: array containing the delays of each feedback echo.
        lowpass_mode: determines what filtering is used.
            'none' (default): no filtering. Pass g_i as varargin argument.
            'lowpass': low-pass filter. Pass T_60 as varargin argument.
            'butter': butterworth filter. Pass cutoff frequency as varargin
            argument.
            'MA': moving average filter. Leave varargin empty.
        varargin: optional argument required for certain filters (see
        lowpass_mode argument).

    Proper use of this function requires that A is an N x N matrix, and
    each of the gain and delay vectors should have length N.   
%}

function echo_audio = FDN_func(wav, fs, A, b, c, delays, feedback_type, varargin)
    [sz_A_1, sz_A_2] = size(A);
    sz_b = size(b);
    sz_c = size(c);
    sz_delays = size(delays);
    assert(sz_A_1 == sz_A_2 && length(A) == length(b) && isequal(sz_b, sz_c) && isequal(sz_c, sz_delays), 'Array lengths must be equal');
    
    N = sz_A_1;
    L = length(wav);
    max_delay = max(delays);
    
    if(strcmp(feedback_type, 'lowpass')) % Lowpass mode selected
        assert(nargin == 8, 'Low-pass filtering expects eight input variables.');
        T_60_0 = varargin{1}; % final input is T_60 value
        assert(isa(T_60_0, 'double') && isequal(size(T_60_0),[1,1]), 'T_60 value must be scalar of type double.')
        T_60 = @(frequency)(0.1+T_60_0/(100+frequency));
        g_i = power(10, -3*delays/fs/T_60(0));
        a_i = log(10)/4*log10(g_i)*(1-1/(T_60(fs/2)/T_60(0)));
        filt_b = (g_i.*(1-a_i)).'; % transfer function numerator g_i*(1-a_i)
        filt_a = [ones(1, N); -a_i].';% transfer function denominator 1-a_i*z^(-1)
    elseif(strcmp(feedback_type, 'butter')) % Butterworth filtering selected
        assert(nargin == 8, 'Butterworth filtering expects eight input variables.');
        f_c = varargin{1};% final input is cutoff frequency
        assert(isa(f_c, 'double') && isequal(size(f_c),[1,1]), 'Cutoff frequency must be scalar of type double.')
        [filt_b, filt_a] = butter(1, f_c/(fs/2)); % butterworth filter coefficients
        filt_a = repmat(filt_a, [N,1]); % every delay line uses identical filters
    elseif(strcmp(feedback_type, 'MA')) % Moving average filtering selected
        assert(nargin == 7, 'Moving average filtering expects eight input variables.');
        filt_b = 0;
        filt_a = zeros(N, 2);
    else % default to this mode if no other mode is given
        assert(nargin == 8, 'FDN_func.m expects eight input variables.');
        g = varargin{1}; % final input is g_i coefficients
        assert(isequal(size(g), sz_b), 'Array lengths must be equal')
    end
    
    A = A/max(A, [], 'all');        % normalized feedback matrix

    X = zeros(L+max_delay,N);         % initialize delay lines
    
    if(any(strcmp(feedback_type, {'lowpass', 'butter', 'MA'}))) % if using filtering...
        for i = 1:N
            X(1:L,i) = lpfilt(X(1:L,i) + b(i)*wav(1:L), filt_b, filt_a(i,:)); % read in and filter new data from input signal
            for k = 1:N
                X(delays(k)+1:delays(k)+L,k) = X(delays(k)+1:delays(k)+L,k) + lpfilt(X(1:L,i)*A(i,k), filt_b, filt_a(k,:));
                % filter and add current delay line to all other delay lines
            end
        end
    else % if not using filtering...
        for j = 1:L % for each sample in input signal
            for i = 1:N % for each delay line...
                X(j,i) = X(j,i) + b(i)*wav(j); % read new input from input signal
                for k = 1:N % for each delay line...
                    index = j+delays(k); 
                    X(index, k) = X(index, k) + X(j,i)*g(i)*A(i,k); % add value from delay line i multiplied by g_i and A_ik to delay line k
                end
            end
        end
    end

    echo_audio = sum(c.*X, 2)/N; % sum all columns of X for final signal
end