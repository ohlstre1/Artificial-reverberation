%{
    This is a function for plotting the impulse response of an FDN system.
    The function requires the following inputs:
        fs: sample rate.
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

    The function plots the impulse response of the specified filter.
    The function has one output:
        impulse_response: the impulse response of the system. This is
        purely for testing purposes and this value is not used elsewhere in
        our program.
%}

function impulse_response = plotImpulseResponse(fs, A, b, c, delays, lowpass_mode, varargin)
    unit_impulse = zeros(fs*5,1);
    unit_impulse(1) = 1;
    if(strcmp(lowpass_mode, 'MA'))
        impulse_response = FDN_func(unit_impulse, fs, A, b, c, delays, lowpass_mode);
    else
        impulse_response = FDN_func(unit_impulse, fs, A, b, c, delays, lowpass_mode, varargin{1});
    end
    L = length(impulse_response);
    figure()
    stem(linspace(1, L, L), 10*log10(abs(impulse_response)), 'Marker', 'none', 'BaseValue', -Inf)
    grid on
    xlim([-L/10, L])
    ylim([-Inf, 10])
    xlabel('Samples')
    ylabel('Amplitude [dB]')
    title('FDN system impulse response')
end