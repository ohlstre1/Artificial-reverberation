% ELEC-C5341 SASP

%{
    This is a function that applies a lowpass filter onto signal.
    The function requires the following inputs:
        input: a window of the signal, whose last element needs to be passed
        through the lowpass filter.
    
    The function has two optional inputs:
        filter_b: filter transfer function b coefficients.
        filter_a: filter transfer function a coefficients.
    
    If one or more of the optional inputs is missing, the function applies
    a lowpass filter by applying a moving average filter of size 5.
    
    The function has only one output:
        lowpass_value: the final element of the filtered window.
%}

function lowpass_value = lpfilt(input, filt_b, filt_a)
    
    if(exist('filt_b', 'var') && exist('filt_a', 'var'))
        lowpass_value = filter(filt_b, filt_a, input);
    else
        lowpass_value = MA(input, 5);
    end
end

%{
    Function for calculating moving average filter.
    This code was written and submitted as part of assignment 1 during the
    course.

    The function requires the following inputs:
        input: the signal to be filtered.
        k: the size of the moving average filter.

    The function only has one output:
        output: vector of same length as input, where each element is the
        average of the surrounding k.

%}

function [output] =  MA(input, k)
    n = length(input);
    last_k = []; % array keeps track of last k elements
    output = zeros(1,n); % initialize output array
    for i = 1:n
        last_k = cat(1, last_k, input(i)); % append input element to last_k
        if (length(last_k) > k) % if last_k is larger than k...
            last_k = last_k(2:end); % remove first element from last_k
        end
        output(i) = sum(last_k)/length(last_k); % sum last_k and divide by length
    end
end