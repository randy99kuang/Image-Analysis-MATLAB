%--------------------------------------------------------------------------
% PURDUE UNIVERSITY Flexilab
% Biomedical Engineering 
%--------------------------------------------------------------------------
% Author: Randy Kuang 
% Date: 9/27/2016
%--------------------------------------------------------------------------
% rgbAnalysis.m

% This function is used to find which output the RGB values of each of the
% 10 sample squares corresponds the most closely to. 
function c = rgbAnalysis( observed , expected )

minimum = 0; 
minimumIndex = 0;

% The algorithm used finds the value of (expectedValue -
% observedValue)^2 for red, green, and blue, then adds these three values
% to find a final sum. The smallest sum corresponds to the output for that
% given parameter. 
for x = 1:size(expected,1)
    rgbA = ((observed(1) - expected(x,1))^2 + (observed(2) - expected(x,2))^2 + (observed(3) - expected(x,3))^2);
    if x == 1
        minimum = rgbA;
        minimumIndex = x; 
    elseif rgbA < minimum 
        minimum = rgbA;
        minimumIndex = x; 
    end     
end 

c = minimumIndex; 

return 

