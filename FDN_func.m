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
            'lowpass': lowpass filter. Pass T_60 as varargin argument.
            'butter': butterworth filter. Pass cutoff frequency as varargin
            argument.
            'MA': moving average filter. Leave varargin empty.
        varargin: optional argument required for certain filters (see
        lowpass_mode argument).

    Proper use of this function requires that A is an N x N matrix, and
    each of the gain and delay vectors should have length N.   
%}

function echo_audio = FDN_func(wav, fs, A, b, c, delays, lowpass_mode, varargin)
    [sz_A_1, sz_A_2] = size(A);
    sz_b = size(b);
    sz_c = size(c);
    sz_delays = size(delays);
    assert(sz_A_1 == sz_A_2 && length(A) == length(b) && isequal(sz_b, sz_c) && isequal(sz_c, sz_delays), 'Array lengths must be equal');
    
    N = sz_A_1;
    L = length(wav);
    max_delay = max(delays);
    
    if(~exist('lowpass_mode', 'var'))
        lowpass_mode = 'none';
    end
    
    if(strcmp(lowpass_mode, 'lowpass'))
        assert(nargin == 8, 'Lowpass filtering expects eight input variables.');
        T_60_0 = varargin{1};
        assert(isa(T_60_0, 'double') && isequal(size(T_60_0),[1,1]), 'T_60 value must be scalar of type double.')
        T_60 = @(frequency) 1e5*(0.1+T_60_0/(100+frequency));
        g_i = power(10, -3*delays/T_60(0));
        a_i = log(10)/4*log10(g_i)*(1-1/(T_60(fs/2)/T_60(0)));
        filt_b = (g_i.*(1-a_i)).';
        filt_a = [ones(1, N); -a_i].';
    elseif(strcmp(lowpass_mode, 'butter'))
        assert(nargin == 8, 'Butterworth filtering expects eight input variables.');
        f_c = varargin{1};
        assert(isa(f_c, 'double') && isequal(size(f_c),[1,1]), 'Cutoff frequency must be scalar of type double.')
        [filt_b, filt_a] = butter(1, f_c/(fs/2));
        filt_a = repmat(filt_a, [N,1]);
    elseif(strcmp(lowpass_mode, 'MA'))
        assert(nargin == 7, 'Moving average filtering expects eight input variables.');
        filt_b = 0;
        filt_a = zeros(N, 2);
    else
        assert(nargin == 8, 'FDN_func.m expects eight input variables.');
        g = varargin{1};
        assert(isequal(size(g), sz_b), 'Array lengths must be equal')
    end
    
    A = A/max(A, [], 'all');        % normalized feedback matrix

    X = zeros(L+max_delay,N);         % initialize delay lines
    
    if(any(strcmp(lowpass_mode, {'lowpass', 'butter', 'MA'})))
        for i = 1:N
            X(1:L,i) = lpfilt(X(1:L,i) + b(i)*wav(1:L), filt_b, filt_a(i,:));
            for k = 1:N
                X(delays(k)+1:delays(k)+L,k) = X(delays(k)+1:delays(k)+L,k) + lpfilt(X(1:L,i)*A(i,k), filt_b, filt_a(k,:));
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