function lowpass_signal = lpfilt(input, filter_b, filter_a)
    lowpass_window = filter(filter_b, filter_a, input);
    lowpass_signal = lowpass_window(end);
end