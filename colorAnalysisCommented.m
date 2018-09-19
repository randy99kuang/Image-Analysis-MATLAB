%--------------------------------------------------------------------------
% PURDUE UNIVERSITY Flexilab
% Biomedical Engineering 
%--------------------------------------------------------------------------
% Author: Randy Kuang 
% Date: 7/27/2016
%--------------------------------------------------------------------------
% BASIC COLOR IDENTIFICATION AND ANALYSIS
% PART A: IDENTIFYING SAMPLE IN IMAGE
%   STEP 1: Reading in desired image 
%   STEP 2: Finding black spots 
%   STEP 3: Identifying two black Squares
%   STEP 4: Using 1 square to rotate image 
%   STEP 5: Using both squares to rotate a second time 
%   STEP 6: Crop image with respect to one square
%   
% PART B: COLOR ANALYSIS 
%   STEP 1: Use white control to determine brightness
%   STEP 2: Shift image colors based on brightness 
%   STEP 3: Find RBG Values of sample squares 
%   STEP 4: Analysis of Sample RGB Values 
%   STEP 5: Output from Analysis 
%   STEP 6: Creating Output Screenshot 
%--------------------------------------------------------------------------

%% PART A: IDENTIFYING SAMPLE IN IMAGE 
%% STEP 1: Reading in desired image
% Read in an image and determine the image height and
% width. The picture read in cannot be taken over a dark background, must
% have sufficient lighting, and not be taken from an angled camera. The
% orientation or zoom of the image do not matter. 
tic
clear 
clc 
a1 = imread('paper2.jpg');
height1 = size(a1,1); 
width1 = size(a1,2);  

%% STEP 2: Finding black spots 
% A for loop checks every pixel in the image. This look finds all pixels in
% the image that may be part of the two blue orientation squares. A pixel
% is determined to potentially be a part of one of these two squares if it
% has a small R value and a moderately high G and B value. 

blueSpots = [0 0]; 
blueCount = 1;

for x = 1:height1 
    for y = 1: width1 
        if a1(x,y,1) < 85 && a1(x,y,2) > 100 && a1(x,y,3) > 120
            blueSpots(blueCount,:) = [x y]; 
            blueCount = blueCount + 1; 
        end 
    end 
end 

%% STEP 3: Identifying two black squares 
% Of all the blue pixels contained in this matrix, the two calibration
% blue squares must be isolated. In order to accomplish this, the original
% image (a) is transformed into a binary image (aBinary) in which the blue
% pixels of the original image appear blue and every other pixel appears
% white.
aBinary = zeros(size(a1,1),size(a1,2)); 

for x = 1:size(blueSpots,1)
    aBinary(blueSpots(x,1),blueSpots(x,2)) = 1;
end 

% Then, the function "bwlabel" labels each black blob separately, where a
% "blob" is defined as any group of adjacent black pixels. The function
% "regionprops" then calculates the properties of every black "blob".
aGrey = rgb2gray(a1);
labeledBinaryImage = bwlabel(aBinary, 8);
blueSpotsProperties = regionprops(labeledBinaryImage, aGrey, 'all');

% The areas of the black blobs determined from "regionprops" are used to
% find the "labeledBinaryImage" index of the two largest black blobs, which
% are assumed to be the two blue squares.
blueSpotsAreas = [blueSpotsProperties.Area];

% The centroids of all the black bobs are also determined from
% "regionprops". The centroids of the two largest blobs are assumed to be
% the centers of the two blue squares 
blueSpotsCenters = [blueSpotsProperties.Centroid]; 

biggestBlueSpot = 0;
biggestBlueSpotIndex = 0; 

secondBiggestBlueSpot = 0;
secondBiggestBlueSpotIndex = 0; 

for x = 1:size(blueSpotsAreas,2)
    if blueSpotsAreas(x) > biggestBlueSpot
        biggestBlueSpot = blueSpotsAreas(x); 
        biggestBlueSpotIndex = x;
    end
end

for x = 1:size(blueSpotsAreas,2)
    if blueSpotsAreas(x) > secondBiggestBlueSpot && x ~= biggestBlueSpotIndex
        secondBiggestBlueSpot = blueSpotsAreas(x); 
        secondBiggestBlueSpotIndex = x; 
    end 
end 

% Once the indexes of the two largest black blobs are found, these two
% indexes are assumed to be those of the two blue squares. The two
% indexes are used to extract the x and y coordinates of the centers of the
% two blue squares from "blackSpotsCenters", the list of all centroids 
blueSquareCenter1a1 = [ blueSpotsCenters(2 * biggestBlueSpotIndex - 1) blueSpotsCenters(2 * biggestBlueSpotIndex) ];
blueSquareCenter2a1 = [ blueSpotsCenters(2 * secondBiggestBlueSpotIndex - 1) blueSpotsCenters(2 * secondBiggestBlueSpotIndex) ]; 

% The two "blackSquareCenter-" variables declared contained the x and y
% coordinates of the two black squares with respect to the top-left corner
% of the image, which is the default coordinate system of MATLAB. These
% values of the two variables are now transformed into what they would be
% on a Cartesian coordinate plane, and are renamed "blueSquareTrue-"
blueSquareTrue1a1 = [ (blueSquareCenter1a1(1) - width1 / 2) (height1 / 2 - blueSquareCenter1a1(2)) ];
blueSquareTrue2a1 = [ (blueSquareCenter2a1(1) - width1 / 2) (height1 / 2 - blueSquareCenter2a1(2)) ];
 

% The coordinates of the pixels in the largest blue square are
% added to a matrix (blackSquare) for later use 
bigBlueSquareFinalImage = ismember(labeledBinaryImage, biggestBlueSpotIndex); 
blueSquare = [0 0]; 
blueSquareCount = 1; 

for x = 1:height1 
    for y = 1:width1 
        if bigBlueSquareFinalImage(x,y,1) == 1
            blueSquare(blueSquareCount,:) = [x y]; 
            blueSquareCount = blueSquareCount + 1; 
        end 
    end 
end 

% Then, the coordinates of both blue squares are added to a matrix
% (bothBlackSquares) 
bothBlueSpotsIndexes = [ biggestBlueSpotIndex ; secondBiggestBlueSpotIndex ];
bothBlueSquaresFinalImage = ismember(labeledBinaryImage, bothBlueSpotsIndexes);

bothBlueSquares = [0 0]; 
bothBlueSquaresCount = 1;

for x = 1:height1 
    for y = 1:width1 
        if bothBlueSquaresFinalImage(x,y,1) == 1
            bothBlueSquares(bothBlueSquaresCount,:) = [x y]; 
            bothBlueSquaresCount = bothBlueSquaresCount + 1; 
        end 
    end 
end 

%% STEP 3: Using the bigger square to rotate the image 
% In order to determine the orientation offset of the image, the centroids
% of both orientation squares will be used.

% If either the x-coordinates or the y-coordinates of the centers of the 
% two squares are already less than 0.1% different, then STEP 3 is skipped 
% and the same centers of the squares found in STEP 2 are reused. 
% Otherwise, the centroids of the two centers are used to determine the
% angle of tilt. 
xProximity = abs(blueSquareCenter1a1(1) - blueSquareCenter2a1(1)) / width1 <= 0.001; 
yProximity = abs(blueSquareCenter1a1(2) - blueSquareCenter2a1(2)) / height1 <= 0.001;
if (xProximity) 
    a2 = a1;
    angle = 0; 
elseif (yProximity) 
    a2 = a1; 
    angle = 0; 
else 
    angle = atand( (blueSquareCenter1a1(1) - blueSquareCenter2a1(1)) / (blueSquareCenter1a1(2) - blueSquareCenter2a1(2)));
    a2 = imrotate(a1,-angle); 
end

%% STEP 5: Using both black squares to rotate a second time 
% The center pixel of each black square is found, and depending where the
% centers are located, the image is either not rotated, or rotated 90, 180,
% or 270 degrees 

% First the dimensions of the newly rotated image is found and named
% "height2" and "width2"
height2 = size(a2,1);
width2 = size(a2,2);

% New "blueSquareTrue-" x and y-coordinates are calculated for the centers
% of the two black squares after the rotation done in STEP 4
blueSquareTrue1a2 = [ (blueSquareTrue1a1(1) * cosd(-angle) - blueSquareTrue1a1(2) * sind(-angle)) (blueSquareTrue1a1(2) * cosd(-angle) + blueSquareTrue1a1(1) * sind(-angle)) ];
blueSquareTrue2a2 = [ (blueSquareTrue2a1(1) * cosd(-angle) - blueSquareTrue2a1(2) * sind(-angle)) (blueSquareTrue2a1(2) * cosd(-angle) + blueSquareTrue2a1(1) * sind(-angle)) ]; 

% The new "blueSquareTrue-" values are used to also assign the x and y
% coordinates of the two squares based on the MATLAB coordinate system
blueSquareCenter1a2 = [ (blueSquareTrue1a2(1) + width2 / 2) (height2 / 2 - blueSquareTrue1a2(2)) ];
blueSquareCenter2a2 = [ (blueSquareTrue2a2(1) + width2 / 2) (height2 / 2 - blueSquareTrue2a2(2)) ]; 


% The secondary rotation ensures that the sample is displayed landscape and
% the smaller square is on the left side while the larger square is on the
% right side 

% In order to find which orientation the image is curretly in, the height
% difference and the width difference of the two centers of the black
% squares are found
heightDifference = blueSquareCenter2a2(2) - blueSquareCenter1a2(2);
widthDifference = blueSquareCenter2a2(1) - blueSquareCenter1a2(1); 

% If the height difference is greater than the width difference, then the
% sample is inferred to be in a portrait orientation and if the width
% difference is greater than the height differece the sample is inferred to
% be in landscape orientation. Once in landscape orientation, the image is
% finalized if the smaller square is on the left side. 
rotateKey = 0; 
if abs(widthDifference) < abs(heightDifference)
    if heightDifference > 0 
        a3 = imrotate(a2,-90);
        rotateKey = 3;
    end
    
    if heightDifference < 0
        a3 = imrotate(a2,90); 
        rotateKey = 1;
    end 
    
elseif abs(widthDifference) > abs(heightDifference)
    if widthDifference > 0 
        a3 = imrotate(a2,180);
        rotateKey = 2;
    
    elseif widthDifference < 0 
        a3 = a2; 
        rotateKey = 0; 
    end
end

%% STEP 6: Crop image with respect to one square 
% The top left corner of the smaller square on the right side of the sample
% is used as a reference to cut out everything in the image outside of the
% sample

% Once again, the dimensions of the newly rotated image are found and
% called "height3" and "width3" 
height3 = size(a3,1);
width3 = size(a3,2);

% New values for "blueSquareTrue-" are found once again based on whether
% STEP 5 rotated the image 0, 90, 180, or 270 degrees. 
if rotateKey == 0 
    blueSquareTrue1a3 = [ blueSquareTrue1a2(1) blueSquareTrue1a2(2) ]; 
    blueSquareTrue2a3 = [ blueSquareTrue2a2(1) blueSquareTrue2a2(2) ];
elseif rotateKey == 1
    blueSquareTrue1a3 = [ -blueSquareTrue1a2(2) blueSquareTrue1a2(1) ]; 
    blueSquareTrue2a3 = [ -blueSquareTrue2a2(2) blueSquareTrue2a2(1) ]; 
elseif rotateKey == 2
    blueSquareTrue1a3 = [ -blueSquareTrue1a2(1) -blueSquareTrue1a2(2) ]; 
    blueSquareTrue2a3 = [ -blueSquareTrue2a2(1) -blueSquareTrue2a2(2) ];
elseif rotateKey == 3
    blueSquareTrue1a3 = [ blueSquareTrue1a2(2) -blueSquareTrue1a2(1) ]; 
    blueSquareTrue2a3 = [ blueSquareTrue2a2(2) -blueSquareTrue2a2(1) ]; 
end

% New "blueSquareCenter-" values are found from the "blueSquareTrue"
% values calculated in the previous step 
blueSquareCenter1a3 = [ (blueSquareTrue1a3(1) + width3 / 2) (height3 / 2 - blueSquareTrue1a3(2)) ];
blueSquareCenter2a3 = [ (blueSquareTrue2a3(1) + width3 / 2) (height3 / 2 - blueSquareTrue2a3(2)) ]; 


% The x and y coordinates of the left smaller black square are extracted
% from "blueSquareCenter2a3" 
LeftSquareY = blueSquareCenter2a3(2); 
LeftSquareX = blueSquareCenter2a3(1); 


% The distance between the centroids of the two squares is found and named
% "distanceBetweenSquares"
distanceBetweenSquares = abs(blueSquareCenter1a3(1) - blueSquareCenter2a3(1));

% The image is now cropped using the known ratio between
% distanceBetweenSquares, the width and height of the sample, and the
% location of the top left corner of the left smaller square 
cropLeftX = LeftSquareX - distanceBetweenSquares * (730 / 915); 
cropLeftY = LeftSquareY - distanceBetweenSquares * (100 / 915); 
cropWidth = distanceBetweenSquares * (2320 / 915); 
cropHeight = distanceBetweenSquares * (1520 / 915); 

cropRectangle = [cropLeftX cropLeftY cropWidth cropHeight];

a4 = imcrop(a3,cropRectangle);

%% PART A: IDENTIFYING SAMPLE IN IMAGE 
%% STEP 1: Using white control to determine brightness 
% Known white areas located on the sample are used to estimate the
% background brightness present when the image was taken 

% First, the dimensions of the newly cropped image are found and named
% "height4" and "width4" 
height4 = size(a4,1); 
width4 = size(a4,2); 

% The bounds of a white area are found based on "height4" and
% "width4" and the known dimensions of the sample 
whiteLeftBound = round(width4 * 89/232) - round(width4 * 2/232); 
whiteRightBound = round(width4 * 89/232) + round(width4 * 2/232); 
whiteTopBound = round(height4 * 1/2) - round(height4 * 30/232); 
whiteBotBound = round(height4 * 1/2) + round(height4 * 30/232); 

whiteRedValues = zeros(2,2); 
whiteGreenValues = zeros(2,2); 
whiteBlueValues = zeros(2,2); 

% The RGB pixel values of the white area pixels are found, then averaged to
% find the average red, green, and blue values of all the white pixels in
% the known control area 
for x = whiteTopBound:whiteBotBound 
    for y = whiteLeftBound:whiteRightBound
        whiteRedValues(x - (whiteTopBound - 1),y - (whiteLeftBound - 1)) = a4(x,y,1);
        whiteGreenValues(x - (whiteTopBound - 1),y - (whiteLeftBound - 1)) = a4(x,y,2);
        whiteBlueValues(x - (whiteTopBound - 1),y - (whiteLeftBound - 1)) = a4(x,y,3);
    end
end

whiteRedSum = sum(sum(whiteRedValues));
whiteRedFinal = whiteRedSum / (size(whiteRedValues,1) * size(whiteRedValues,2));

whiteGreenSum = sum(sum(whiteGreenValues));
whiteGreenFinal = whiteGreenSum / (size(whiteGreenValues,1) * size(whiteGreenValues,2)); 

whiteBlueSum = sum(sum(whiteBlueValues)); 
whiteBlueFinal = whiteBlueSum / (size(whiteBlueValues,1) * size(whiteBlueValues,2)); 

%% STEP 2: Shift image colors based on brightness 
% The average red, green, and blue values of the white control area are
% used to shift all pixel values in the image in order to adjust for
% brightness 
whiteMean = (whiteRedFinal + whiteGreenFinal + whiteBlueFinal) / 3; 
redScalarShift = whiteMean / whiteRedFinal; 
greenScalarShift = whiteMean / whiteGreenFinal; 
blueScalarShift = whiteMean / whiteBlueFinal; 

linearShift = whiteMean - 200; 

a4red = a4(:,:,1); 
a4green = a4(:,:,2); 
a4blue = a4(:,:,3); 

a5red = uint8(double(a4red) * redScalarShift); 
a5green = uint8(double(a4green) * greenScalarShift); 
a5blue = uint8(double(a4blue) * blueScalarShift);

a5 = cat(3, a5red, a5green, a5blue); %- linearShift;

% Even though the size of "a5" is the same as "a4", the variables are
% redefined for clarity 
height5 = size(a5,1); 
width5 = size(a5,2);  

%% STEP 3: Find RBG values of sample squares 
% Now, the RBG pixel values of the ten sample squares are found 

% Colorimetric Identification #1 (Bilirubin) 
% The bounds of the first sample square are found using "height4" and
% "width4"
leftbound1 = round(width5 * (107/232)) - round(width5 * 2/232);
rightbound1 = round(width5 * (107/232)) + round(width5 * 2/232);
upperbound1 = round(height5 * (19/152)) - round(height5 * 2/152); 
lowerbound1 = round(height5 * (19/152)) + round(height5 * 2/152); 

% "samplePicture-" is the name of an image of just the sample square. This
% image will be pasted onto the output that will eventually be returned to
% the user. 
samplePicture1 = imcrop(a5,[leftbound1 upperbound1 20 20]);

redValues1 = zeros(2,2); 
greenValues1 = zeros(2,2); 
blueValues1 = zeros(2,2); 

for x = upperbound1:lowerbound1
    for y = leftbound1:rightbound1
        redValues1(x - (upperbound1 - 1),y - (leftbound1 - 1)) = a5(x,y,1);
        greenValues1(x - (upperbound1 - 1),y - (leftbound1 - 1)) = a5(x,y,2);
        blueValues1(x - (upperbound1 - 1),y - (leftbound1 - 1)) = a5(x,y,3);
    end
end

% The loop shown below draws a red square on the area analyzed by the code.
% This is only done for troubleshooting purposes. 
for x = upperbound1:lowerbound1
    for y = leftbound1:rightbound1
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

% The pixel values are added together to find an average and a standard
% deviation or "error" 
redSum1 = sum(sum(redValues1));
redFinal1 = redSum1 / (size(redValues1,1) * size(redValues1,2));
redError1 = std2(redValues1);

greenSum1 = sum(sum(greenValues1));
greenFinal1 = greenSum1 / (size(greenValues1,1) * size(greenValues1,2));
greenError1 = std2(greenValues1);

blueSum1 = sum(sum(blueValues1));
blueFinal1 = blueSum1 / (size(blueValues1,1) * size(blueValues1,2));
blueError1 = std2(blueValues1); 
error1 = [ redError1 greenError1 blueError1 ]; 
        
% Colorimetric Identification #2 (Glucose)
% The code for finding the average RGB values is the same for all 10 sample
% squares, refer to the comments written for sample square #1. 
leftbound2 = round(width5 * (129/232)) - round(width5 * 2/232);
rightbound2 = round(width5 * (129/232)) + round(width5 * 2/232);
upperbound2 = round(height5 * (19/152)) - round(height5 * 2/152); 
lowerbound2 = round(height5 * (19/152)) + round(height5 * 2/152); 
samplePicture2 = imcrop(a5,[leftbound2 upperbound2 20 20]);

redValues2 = zeros(2,2); 
greenValues2 = zeros(2,2); 
blueValues2 = zeros(2,2); 

for x = upperbound2:lowerbound2
    for y = leftbound2:rightbound2
        redValues2(x - (upperbound2 - 1),y - (leftbound2 - 1)) = a5(x,y,1);
        greenValues2(x - (upperbound2 - 1),y - (leftbound2 - 1)) = a5(x,y,2);
        blueValues2(x - (upperbound2 - 1),y - (leftbound2 - 1)) = a5(x,y,3);
    end
end

for x = upperbound2:lowerbound2
    for y = leftbound2:rightbound2
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum2 = sum(sum(redValues2));
redFinal2 = redSum2 / (size(redValues2,1) * size(redValues2,2));
redError2 = std2(redValues2);

greenSum2 = sum(sum(greenValues2));
greenFinal2 = greenSum2 / (size(greenValues2,1) * size(greenValues2,2));
greenError2 = std2(greenValues2);

blueSum2 = sum(sum(blueValues2));
blueFinal2 = blueSum2 / (size(blueValues2,1) * size(blueValues2,2));
blueError2 = std2(blueValues2); 
error2 = [ redError2 greenError2 blueError2 ]; 

% Colorimetric Identification #3
leftbound3 = round(width5 * (107/232)) - round(width5 * 2/232);
rightbound3 = round(width5 * (107/232)) + round(width5 * 2/232);
upperbound3 = round(height5 * (50/152)) - round(height5 * 2/152); 
lowerbound3 = round(height5 * (50/152)) + round(height5 * 2/152); 
samplePicture3 = imcrop(a5,[leftbound3 upperbound3 20 20]);

redValues3 = zeros(2,2); 
greenValues3 = zeros(2,2); 
blueValues3 = zeros(2,2); 

for x = upperbound3:lowerbound3
    for y = leftbound3:rightbound3
        redValues3(x - (upperbound3 - 1),y - (leftbound3 - 1)) = a5(x,y,1);
        greenValues3(x - (upperbound3 - 1),y - (leftbound3 - 1)) = a5(x,y,2);
        blueValues3(x - (upperbound3 - 1),y - (leftbound3 - 1)) = a5(x,y,3);
    end
end

for x = upperbound3:lowerbound3
    for y = leftbound3:rightbound3
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum3 = sum(sum(redValues3));
redFinal3 = redSum3 / (size(redValues3,1) * size(redValues3,2));
redError3 = std2(redValues3); 

greenSum3 = sum(sum(greenValues3));
greenFinal3 = greenSum3 / (size(greenValues3,1) * size(greenValues3,2));
greenError3 = std2(greenValues3); 

blueSum3 = sum(sum(blueValues3));
blueFinal3 = blueSum3 / (size(blueValues3,1) * size(blueValues3,2));
blueError3 = std2(blueValues3); 
error3 = [ redError3 greenError3 blueError3 ]; 

% Colorimetric Identifcation #4
leftbound4 = round(width5 * (129/232)) - round(width5 * 2/232);
rightbound4 = round(width5 * (129/232)) + round(width5 * 2/232);
upperbound4 = round(height5 * (50/152)) - round(height5 * 2/152); 
lowerbound4 = round(height5 * (50/152)) + round(height5 * 2/152); 
samplePicture4 = imcrop(a5,[leftbound4 upperbound4 20 20]);

redValues4 = zeros(2,2); 
greenValues4 = zeros(2,2); 
blueValues4 = zeros(2,2); 

for x = upperbound4:lowerbound4
    for y = leftbound4:rightbound4
        redValues4(x - (upperbound4 - 1),y - (leftbound4 - 1)) = a5(x,y,1);
        greenValues4(x - (upperbound4 - 1),y - (leftbound4 - 1)) = a5(x,y,2);
        blueValues4(x - (upperbound4 - 1),y - (leftbound4 - 1)) = a5(x,y,3);
    end
end

for x = upperbound4:lowerbound4
    for y = leftbound4:rightbound4
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum4 = sum(sum(redValues4));
redFinal4 = redSum4 / (size(redValues4,1) * size(redValues4,2));
redError4 = std2(redValues4); 

greenSum4 = sum(sum(greenValues4));
greenFinal4 = greenSum4 / (size(greenValues4,1) * size(greenValues4,2));
greenError4 = std2(greenValues4); 

blueSum4 = sum(sum(blueValues4));
blueFinal4 = blueSum4 / (size(blueValues4,1) * size(blueValues4,2));
blueError4 = std2(blueValues4); 
error4 = [ redError4 greenError4 blueError4 ]; 

% Colorimetric Identification #5
leftbound5 = round(width5 * (107/232)) - round(width5 * 2/232);
rightbound5 = round(width5 * (107/232)) + round(width5 * 2/232);
upperbound5 = round(height5 * (79/152)) - round(height5 * 2/152); 
lowerbound5 = round(height5 * (79/152)) + round(height5 * 2/152); 
samplePicture5 = imcrop(a5,[leftbound5 upperbound5 20 20]);

redValues5 = zeros(2,2); 
greenValues5 = zeros(2,2); 
blueValues5 = zeros(2,2); 

for x = upperbound5:lowerbound5
    for y = leftbound5:rightbound5
        redValues5(x - (upperbound5 - 1),y - (leftbound5 - 1)) = a5(x,y,1);
        greenValues5(x - (upperbound5 - 1),y - (leftbound5 - 1)) = a5(x,y,2);
        blueValues5(x - (upperbound5 - 1),y - (leftbound5 - 1)) = a5(x,y,3);
    end
end

for x = upperbound5:lowerbound5
    for y = leftbound5:rightbound5
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum5 = sum(sum(redValues5));
redFinal5 = redSum5 / (size(redValues5,1) * size(redValues5,2));
redError5 = std2(redValues5);

greenSum5 = sum(sum(greenValues5));
greenFinal5 = greenSum5 / (size(greenValues5,1) * size(greenValues5,2));
greenError5 = std2(greenValues5);

blueSum5 = sum(sum(blueValues5));
blueFinal5 = blueSum5 / (size(blueValues5,1) * size(blueValues5,2));
blueError5 = std2(blueValues5); 
error5 = [ redError5 greenError5 blueError5 ]; 

% Colorimetric Identification #6
leftbound6 = round(width5 * (129/232)) - round(width5 * 2/232);
rightbound6 = round(width5 * (129/232)) + round(width5 * 2/232);
upperbound6 = round(height5 * (79/152)) - round(height5 * 2/152); 
lowerbound6 = round(height5 * (79/152)) + round(height5 * 2/152); 
samplePicture6 = imcrop(a5,[leftbound6 upperbound6 20 20]);

redValues6 = zeros(2,2); 
greenValues6 = zeros(2,2); 
blueValues6 = zeros(2,2); 

for x = upperbound6:lowerbound6
    for y = leftbound6:rightbound6
        redValues6(x - (upperbound6 - 1),y - (leftbound6 - 1)) = a5(x,y,1);
        greenValues6(x - (upperbound6 - 1),y - (leftbound6 - 1)) = a5(x,y,2);
        blueValues6(x - (upperbound6 - 1),y - (leftbound6 - 1)) = a5(x,y,3);
    end
end

for x = upperbound6:lowerbound6
    for y = leftbound6:rightbound6
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum6 = sum(sum(redValues6));
redFinal6 = redSum6 / (size(redValues6,1) * size(redValues6,2));
redError6 = std2(redValues6);

greenSum6 = sum(sum(greenValues6));
greenFinal6 = greenSum6 / (size(greenValues6,1) * size(greenValues6,2));
greenError6 = std2(greenValues6);

blueSum6 = sum(sum(blueValues6));
blueFinal6 = blueSum6 / (size(blueValues6,1) * size(blueValues6,2));
blueError6 = std2(blueValues6); 
error6 = [ redError6 greenError6 blueError6 ]; 

% Colorimetric Identification #7
leftbound7 = round(width5 * (107/232)) - round(width5 * 2/232);
rightbound7 = round(width5 * (107/232)) + round(width5 * 2/232);
upperbound7 = round(height5 * (108/152)) - round(height5 * 2/152); 
lowerbound7 = round(height5 * (108/152)) + round(height5 * 2/152); 
samplePicture7 = imcrop(a5,[leftbound7 upperbound7 20 20]);

redValues7 = zeros(2,2); 
greenValues7 = zeros(2,2); 
blueValues7 = zeros(2,2); 

for x = upperbound7:lowerbound7
    for y = leftbound7:rightbound7
        redValues7(x - (upperbound7 - 1),y - (leftbound7 - 1)) = a5(x,y,1);
        greenValues7(x - (upperbound7 - 1),y - (leftbound7 - 1)) = a5(x,y,2);
        blueValues7(x - (upperbound7 - 1),y - (leftbound7 - 1)) = a5(x,y,3);
    end
end

for x = upperbound7:lowerbound7
    for y = leftbound7:rightbound7
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum7 = sum(sum(redValues7));
redFinal7 = redSum7 / (size(redValues7,1) * size(redValues7,2));
redError7 = std2(redValues7);

greenSum7 = sum(sum(greenValues7));
greenFinal7 = greenSum7 / (size(greenValues7,1) * size(greenValues7,2));
greenError7 = std2(greenValues7);

blueSum7 = sum(sum(blueValues7));
blueFinal7 = blueSum7 / (size(blueValues7,1) * size(blueValues7,2));
blueError7 = std2(blueValues7); 
error7 = [ redError7 greenError7 blueError7 ]; 

% Colorimetric Identification #8
leftbound8 = round(width5 * (129/232)) - round(width5 * 2/232);
rightbound8 = round(width5 * (129/232)) + round(width5 * 2/232);
upperbound8 = round(height5 * (108/152)) - round(height5 * 2/152); 
lowerbound8 = round(height5 * (108/152)) + round(height5 * 2/152); 
samplePicture8 = imcrop(a5,[leftbound8 upperbound8 20 20]);

redValues8 = zeros(2,2); 
greenValues8 = zeros(2,2); 
blueValues8 = zeros(2,2); 

for x = upperbound8:lowerbound8
    for y = leftbound8:rightbound8
        redValues8(x - (upperbound8 - 1),y - (leftbound8 - 1)) = a5(x,y,1);
        greenValues8(x - (upperbound8 - 1),y - (leftbound8 - 1)) = a5(x,y,2);
        blueValues8(x - (upperbound8 - 1),y - (leftbound8 - 1)) = a5(x,y,3);
    end
end

for x = upperbound8:lowerbound8
    for y = leftbound8:rightbound8
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum8 = sum(sum(redValues8));
redFinal8 = redSum8 / (size(redValues8,1) * size(redValues8,2));
redError8 = std2(redValues8);

greenSum8 = sum(sum(greenValues8));
greenFinal8 = greenSum8 / (size(greenValues8,1) * size(greenValues8,2));
greenError8 = std2(greenValues8);

blueSum8 = sum(sum(blueValues8));
blueFinal8 = blueSum8 / (size(blueValues8,1) * size(blueValues8,2));
blueError8 = std2(blueValues8); 

error8 = [ redError8 greenError8 blueError8 ]; 

% Colorimetric Identification #9
leftbound9 = round(width5 * (107/232)) - round(width5 * 2/232);
rightbound9 = round(width5 * (107/232)) + round(width5 * 2/232);
upperbound9 = round(height5 * (137/152)) - round(height5 * 2/152); 
lowerbound9 = round(height5 * (137/152)) + round(height5 * 2/152); 
samplePicture9 = imcrop(a5,[leftbound9 upperbound9 20 20]);

redValues9 = zeros(2,2); 
greenValues9 = zeros(2,2); 
blueValues9 = zeros(2,2); 

for x = upperbound9:lowerbound9
    for y = leftbound9:rightbound9
        redValues9(x - (upperbound9 - 1),y - (leftbound9 - 1)) = a5(x,y,1);
        greenValues9(x - (upperbound9 - 1),y - (leftbound9 - 1)) = a5(x,y,2);
        blueValues9(x - (upperbound9 - 1),y - (leftbound9 - 1)) = a5(x,y,3);
    end
end

for x = upperbound9:lowerbound9
    for y = leftbound9:rightbound9
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum9 = sum(sum(redValues9));
redFinal9 = redSum9 / (size(redValues9,1) * size(redValues9,2));
redError9 = std2(redValues9);

greenSum9 = sum(sum(greenValues9));
greenFinal9 = greenSum9 / (size(greenValues9,1) * size(greenValues9,2));
greenError9 = std2(greenValues9);

blueSum9 = sum(sum(blueValues9));
blueFinal9 = blueSum9 / (size(blueValues9,1) * size(blueValues9,2));
blueError9 = std2(blueValues9); 
error9 = [ redError9 greenError9 blueError9 ]; 

% Colorimetric Identification #10
leftbound10 = round(width5 * (129/232)) - round(width5 * 2/232);
rightbound10 = round(width5 * (129/232)) + round(width5 * 2/232);
upperbound10 = round(height5 * (137/152)) - round(height5 * 2/152); 
lowerbound10 = round(height5 * (137/152)) + round(height5 * 2/152); 
samplePicture10 = imcrop(a5,[leftbound10 upperbound10 20 20]);

redValues10 = zeros(2,2); 
greenValues10 = zeros(2,2); 
blueValues10 = zeros(2,2); 

for x = upperbound10:lowerbound10
    for y = leftbound10:rightbound10
        redValues10(x - (upperbound10 - 1),y - (leftbound10 - 1)) = a5(x,y,1);
        greenValues10(x - (upperbound10 - 1),y - (leftbound10 - 1)) = a5(x,y,2);
        blueValues10(x - (upperbound10 - 1),y - (leftbound10 - 1)) = a5(x,y,3);
    end
end

for x = upperbound10:lowerbound10
    for y = leftbound10:rightbound10
        a5(x,y,1) = 255;
        a5(x,y,2) = 0; 
        a5(x,y,3) = 0; 
    end
end

redSum10 = sum(sum(redValues10));
redFinal10 = redSum10 / (size(redValues10,1) * size(redValues10,2));
redError10 = std2(redValues10);

greenSum10 = sum(sum(greenValues10));
greenFinal10 = greenSum10 / (size(greenValues10,1) * size(greenValues10,2));
greenError10 = std2(greenValues10);

blueSum10 = sum(sum(blueValues10));
blueFinal10 = blueSum10 / (size(blueValues10,1) * size(blueValues10,2));
blueError10 = std2(blueValues10); 

error10 = [ redError10 greenError10 blueError10 ];  
final10 = [ redFinal10 greenFinal10 blueFinal10 ];

%% STEP 4: Analysis of Sample RGB Values 
% The average red, green, and blue values of the sample areas are used to
% analyze the concentrations of various substances in the urine sample

% These matrices contain the expected values of the sample's RGB values for
% difference concentrations of substances. Each entry in each matrice
% represents a certain concentration for its respective substance. These
% values are calculated from averages from a scalar algorithm done on
% control images. 
expectedBil = [ 175.7260772 154.2071637 115.3576112  ; 179.7443577 149.0207338 118.1224221 ; 153.3233903 133.8504049 104.1221184 ; 145.7204101 119.3480671 101.6856958 ]; 
expectedGlu = [ 99.82335256 137.0023329 121.5599569 ; 103.2244256 138.3126377 96.3283991 ; 87.59694771 117.4156797 62.7527473 ; 107.3440896 95.99506706 48.7551387 ; 110.5725637 79.70751833 40.05624701 ; 99.68885179 63.54184231 46.45631705 ];
expectedSG = [ 23.67963822 49.7797193 55.33765935 ; 41.07399629 70.12139392 57.58203572 ; 68.24263004 83.53094016 51.57590904 ; 93.94080065 92.08997317 44.21398582 ; 114.4519254 105.3652884 45.00790176 ; 128.9536354 108.3806351 48.30919575 ; 149.5610537 120.667385 46.53507043 ]; 
expectedKet = [ 161.3295037 136.5648682 117.9568263 ; 159.3971513 121.0626138 111.3383228 ; 154.6116324 99.26403518 110.2743268 ; 126.3585005 61.11013505 76.99179975 ; 123.6583869 47.29066389 68.63918768 ; 87.45524101 45.88827836 57.04939732 ]; 
expectedpH = [ 193.9583577 104.4497284 45.10172813 ; 179.6503849 133.9030842 63.15553753 ; 142.2246738 121.5597621 33.68270143 ; 124.7759053 135.5996836 46.82747972 ; 92.75029577 115.0824533 54.97307469 ; 89.86630575 121.4564648 77.03181905 ; 53.2125206 87.66105604 90.45278952 ]; 
expectedBlo = [ 181.6260295 136.5813655 45.07946028 ; 160.1951029 135.5860998 55.93898089 ; 116.8525116 119.6797202 55.30438123 ; 75.26855977 90.64117376 55.25439728 ; 29.49023295 51.49625201 43.39962352 ]; 
expectedUro = [ 201.0658 145.0658 120.0658 ; 202.4422 138.7143 135.898 ; 183.3379 123.8957 130.78 ; 180.542 107.9615 130.2517 ; 181.3832 99.6372 118.2177 ; 160.1406 91.8753 112.9252 ]; 
expectedPro = [ 170.1497 158.551 96.3515 ; 142.3991 154.3107 93.195 ; 119.356 142.1882 98.4172 ; 100.7596 128.5964 113.5964 ; 84.3469 120.3469 119.0544 ; 70.5079 105.0952 107.0952 ]; 
expectedLeu = [ 198.0091 184.8798 155.5896 ; 181.1701 171.9909 156.4172 ; 166.61 147.0658 141.3379 ; 121.6893 90.1179 109.1655 ; 95.8163 75.8163 103.8163 ]; 
expectedNit = [ 202.2766 191.2766 170.1338 ; 207.5442 181.5442 165.8957 ; 174.0091 78.3651 120.5533 ]; 

% In order to determine which value of each matrix best matches the
% samples' RGB values, the function "rbgAnalysis" is used. This function is
% contained within a different m-file and is explained in its own file.
% This function returns the index number of the matrix value that best
% corresponds with the samples' RGB values. 
bilIndex = rgbAnalysis( [ redFinal1 greenFinal1 blueFinal1 ] , expectedBil);
gluIndex = rgbAnalysis( [ redFinal2 greenFinal2 blueFinal2 ] , expectedGlu); 
sgIndex = rgbAnalysis( [ redFinal3 greenFinal3 blueFinal3 ] , expectedSG);
ketIndex = rgbAnalysis( [ redFinal4 greenFinal4 blueFinal4 ] , expectedKet); 
pHIndex = rgbAnalysis( [ redFinal5 greenFinal5 blueFinal5 ] , expectedpH); 
bloIndex = rgbAnalysis( [ redFinal6 greenFinal6 blueFinal6 ] , expectedBlo); 
uroIndex = rgbAnalysis( [ redFinal7 greenFinal7 blueFinal7 ] , expectedUro);
proIndex = rgbAnalysis( [ redFinal8 greenFinal8 blueFinal8 ] , expectedPro);
leuIndex = rgbAnalysis( [ redFinal9 greenFinal9 blueFinal9 ] , expectedLeu);
nitIndex = rgbAnalysis( [ redFinal10 greenFinal10 blueFinal10 ] , expectedNit); 

% Additionally, the samples' RBG value errors that were calculated earlier
% are used to determine the amount of total error in the picture taken.
% Whenever the standard deviation of an average RBG value is over 4,
% "rgbErrorCount" increases by 1. If "rgbErrorCount" is too high, then no
% output is returned and the user is asked to retake the image under better
% lighting conditions. 
rgbErrorCount = 0; 
SDmatrix = [ redError1 greenError1 blueError1 ;
    redError2 greenError2 blueError2 ; 
    redError3 greenError3 blueError3 ; 
    redError4 greenError4 blueError4 ; 
    redError5 greenError5 blueError5 ; 
    redError6 greenError6 blueError6 ; 
    redError7 greenError7 blueError7 ; 
    redError8 greenError8 blueError8 ; 
    redError9 greenError9 blueError9 ; 
    redError10 greenError10 blueError10 ];
errorCheck = 0; 
for x = 1:numel(SDmatrix)
    if SDmatrix(x) > 4 
        rgbErrorCount = rgbErrorCount + 1; 
    end 
end

%% STEP 5: Output from Analysis 
% The substance index values calculated in STEP 3 are now used to create
% output strings that the user will receive. 

% As stated near the end of STEP 3, the user will receive instructions to
% retake the image if "rgbErrorCount" is too high. If "rbgErrorCount" isn't
% sufficiently high, then the program will start converting substance index
% values into string outputs. 
if (rgbErrorCount > 15)
    disp('reading error, please retake picture with more consistent lighting')
    errorCheck = 1; 
else
    if (mean(error1) > 5)
        bilOutput = 'bilirubin reading error';
    else
        switch bilIndex 
            case 1
                bilOutput = '0';
            case 2
                bilOutput = '1+';
            case 3
                bilOutput = '2++';
            case 4 
                bilOutput = '4+++';
        end
    end
    
    if (mean(error2) > 5)
        gluOutput = 'glucose reading error';
    else
        switch gluIndex 
        case 1 
            gluOutput = '0';
        case 2 
            gluOutput = [ '100', char(177) ]; 
        case 3 
            gluOutput = '250+';
        case 4 
            gluOutput = '500++';
        case 5 
            gluOutput = '1000+++';
        case 6 
            gluOutput = '>2000++++';
        end
    end
    
    if (mean(error3) > 5)
        sgOutput = 'specific gravity reading error';
    else
        switch sgIndex 
        case 1 
            sgOutput = '1.000';
        case 2 
            sgOutput = '1.005'; 
        case 3 
            sgOutput = '1.010';
        case 4 
            sgOutput = '1.015';
        case 5 
            sgOutput = '1.020';
        case 6 
            sgOutput = '1.025';
        case 7 
            sgOutput = '1.030';        
        end
    end
    
    if (mean(error4) > 5)
        ketOutput = 'ketone reading error';
    else
        switch ketIndex
        case 1
            ketOutput = '0';
        case 2 
            ketOutput = [ '5', char(177) ];
        case 3 
            ketOutput = '15+';
        case 4 
            ketOutput = '40++';
        case 5 
            ketOutput = '80+++';
        case 6 
            ketOutput = '160++++';
        end   
    end
    
    if (mean(error5) > 5)
        pHOutput = 'pH reading error';
    else
        switch pHIndex 
            case 1
                pHOutput = '5.0';
            case 2
                pHOutput = '6.0';
            case 3
                pHOutput = '6.5';
            case 4 
                pHOutput = '7.0';
            case 5 
                pHOutput = '7.5';
            case 6 
                pHOutput = '8.0';
            case 7 
                pHOutput = '9.0';
        end
    end
    
    if (redError6 > 16 && greenError6 > 16 && blueError6 > 16)
        bloOutput = [ '50 Ery/' , char(181) ];
        bloIndex = 6;
    elseif (redError6 > 11 && greenError6 > 11 && blueError6 > 11)
        bloOutput = [ '5-10 Ery/' , char(181) ];
        bloIndex = 7;
    elseif (redError6 < 4 && blueError6 < 4 && greenError6 < 4)
        switch bloIndex
            case 1 
                bloOutput = '0';
            case 2
                bloOutput = ['', char(177)];
            case 3
                bloOutput = '+';
            case 4
                bloOutput = '++';
            case 5
                bloOutput = '+++';
        end 
    else
        bloOutput = 'hemoglobin reading error';
        disp(bloOutput)
    end
    
    if (mean(error1) > 7)
        uroOutput = 'urobilinogen reading error';
    else
        switch uroIndex
        case 1
            uroOutput = '0.2';
        case 2 
            uroOutput = '1';
        case 3 
            uroOutput = '2';
        case 4 
            uroOutput = '4';
        case 5 
            uroOutput = '8';
        case 6 
            uroOutput = '12';
        end   
    end
    
    if (mean(error1) > 8)
        proOutput = 'protein reading error';
    else
        switch proIndex
        case 1
            proOutput = '0';
        case 2 
            proOutput = [ '15', char(177) ];
        case 3 
            proOutput = '30+';
        case 4 
            proOutput = '100++';
        case 5 
            proOutput = '300+++';
        case 6 
            proOutput = '2000++++';
        end   
    end
    
    if (mean(error1) > 9)
        leuOutput = 'leukocytes reading error';
    else
        switch leuIndex
        case 1
            leuOutput = '0';
        case 2 
            leuOutput = [ '15', char(177) ];
        case 3 
            leuOutput = '70+';
        case 4 
            leuOutput = '125++';
        case 5 
            leuOutput = '500+++';
        end   
    end
    
    if (mean(error1) > 10)
        nitOutput = 'nitrite reading error';
    else
        switch nitIndex
        case 1
            nitOutput = '0';
        case 2 
            nitOutput = '+';
        case 3 
            nitOutput = '+';
        end   
    end
end

%% STEP 6: Creating Output Screenshot 
% In essence, this final step takes all the data generated in the previous
% steps and creates an image that is returned to a user's phone. The image
% will contain the results of the urinalysis as well as warnings if the
% results indicate anything unusual. 

% Firstly, images of a check mark, warning sign, and error sign are read
% in.
correct = imread('check mark.png');
wrong = imread('wrong mark.png');
warning = imread('warning mark.png'); 

% Then these images are resized so that they have identical dimensions. 
correctFinal0 = imresize(correct,0.08276);
correctFinal = correctFinal0(:,1:60,:);
wrongFinal = imresize(wrong,0.1); 
warningFinal = imresize(warning,0.06666666); 

% The results from each of the 10 parameters are classified as either out
% of range (wrong), close to the appropriate range (warning), or in range
% (correct). Based on whether each parameter is in range, close to range,
% or outside range, a color (green,yellow, red respectively) and an image
% will be assigned to that parameter for use in the final image output. 
if bilIndex == 3 || bilIndex == 4 
    bilColor = [ 205 50 50 ]; 
    bilImage = wrongFinal;  
elseif bilIndex == 2
    bilColor = [ 250 250 0 ]; 
    bilImage = warningFinal; 
elseif bilIndex == 1
    bilColor = [ 50 205 50 ]; 
    bilImage = correctFinal; 
end

if gluIndex == 3 || gluIndex == 4 || gluIndex == 5 || gluIndex == 6 
    gluColor = [ 205 50 50 ]; 
    gluImage = wrongFinal; 
elseif gluIndex == 2
    gluColor = [ 250 250 0 ]; 
    gluImage = warningFinal; 
elseif gluIndex == 1
    gluColor = [ 50 205 50 ]; 
    gluImage = correctFinal; 
end

if sgIndex == 1 
    sgColor = [ 250 250 0 ]; 
    sgImage = warningFinal;
elseif sgIndex == 2 || sgIndex == 3 || sgIndex == 4 || sgIndex == 5 || sgIndex == 6 || sgIndex == 7 
    sgColor = [ 50 205 50 ]; 
    sgImage = correctFinal;  
end

if ketIndex == 4 || ketIndex == 5 || ketIndex == 6
    ketColor = [ 205 50 50 ]; 
    ketImage = wrongFinal; 
elseif ketIndex == 2 || ketIndex == 3
    ketColor = [ 250 250 0 ]; 
    ketImage = warningFinal; 
elseif ketIndex == 1 
    ketColor = [ 50 205 50 ]; 
    ketImage = correctFinal; 
end

if pHIndex == 1 || pHIndex == 6 || pHIndex == 7 
    pHColor = [ 205 50 50 ]; 
    pHImage = wrongFinal; 
elseif pHIndex == 2 || pHIndex == 5
    pHColor = [ 250 250 0 ]; 
    pHImage = warningFinal; 
elseif pHIndex == 3 || pHIndex == 4 
    pHColor = [ 50 205 50 ]; 
    pHImage = correctFinal; 
end

if bloIndex == 6 || bloIndex == 7
    bloColor = [ 205 50 50 ]; 
    bloImage = wrongFinal; 
elseif bloIndex == 3 || bloIndex == 4 || bloIndex == 5
    bloColor = [ 250 250 0 ]; 
    bloImage = warningFinal; 
elseif bloIndex == 1 || bloIndex == 2
    bloColor = [ 50 205 50 ]; 
    bloImage = correctFinal; 
end

if uroIndex == 5 || uroIndex == 6
    uroColor = [ 205 50 50 ]; 
    uroImage = wrongFinal; 
elseif uroIndex == 3 || uroIndex == 4
    uroColor = [ 250 250 0 ]; 
    uroImage = warningFinal; 
elseif uroIndex == 1 || uroIndex == 2
    uroColor = [ 50 205 50 ]; 
    uroImage = correctFinal; 
end

if proIndex == 3 || proIndex == 4 || proIndex == 5 || proIndex == 6 
    proColor = [ 205 50 50 ]; 
    proImage = wrongFinal; 
elseif proIndex == 2
    proColor = [ 250 250 0 ]; 
    proImage = warningFinal; 
elseif proIndex == 1
    proColor = [ 50 205 50 ]; 
    proImage = correctFinal; 
end

if leuIndex == 4 || leuIndex == 5
    leuColor = [ 205 50 50 ]; 
    leuImage = wrongFinal; 
elseif leuIndex == 3
    leuColor = [ 250 250 0 ]; 
    leuImage = warningFinal; 
elseif leuIndex == 1 || leuIndex == 2
    leuColor = [ 50 205 50 ]; 
    leuImage = correctFinal; 
end

if nitIndex == 3 
    nitColor = [ 205 50 50 ]; 
    nitImage = wrongFinal; 
elseif nitIndex == 2
    nitColor = [ 250 250 0 ]; 
    nitImage = warningFinal; 
elseif nitIndex == 1 
    nitColor = [ 50 205 50 ]; 
    nitImage = correctFinal; 
end

% The pictures of the analysis area on each of the 10 sample squares are
% now resized so they fit on the final image output properly. 
samplePicture1F = imresize(samplePicture1,3);
samplePicture2F = imresize(samplePicture2,3);
samplePicture3F = imresize(samplePicture3,3);
samplePicture4F = imresize(samplePicture4,3);
samplePicture5F = imresize(samplePicture5,3);
samplePicture6F = imresize(samplePicture6,3);
samplePicture7F = imresize(samplePicture7,3);
samplePicture8F = imresize(samplePicture8,3);
samplePicture9F = imresize(samplePicture9,3);
samplePicture10F = imresize(samplePicture10,3);

for x = 1:63
    for y = 1:2
        samplePicture1F(x,y,:) = [0 0 0]; 
        samplePicture2F(x,y,:) = [0 0 0]; 
        samplePicture3F(x,y,:) = [0 0 0]; 
        samplePicture4F(x,y,:) = [0 0 0]; 
        samplePicture5F(x,y,:) = [0 0 0]; 
        samplePicture6F(x,y,:) = [0 0 0]; 
        samplePicture7F(x,y,:) = [0 0 0]; 
        samplePicture8F(x,y,:) = [0 0 0]; 
        samplePicture9F(x,y,:) = [0 0 0]; 
        samplePicture10F(x,y,:) = [0 0 0]; 
        
        samplePicture1F(y,x,:) = [0 0 0]; 
        samplePicture2F(y,x,:) = [0 0 0];
        samplePicture3F(y,x,:) = [0 0 0];
        samplePicture4F(y,x,:) = [0 0 0];
        samplePicture5F(y,x,:) = [0 0 0];
        samplePicture6F(y,x,:) = [0 0 0];
        samplePicture7F(y,x,:) = [0 0 0];
        samplePicture8F(y,x,:) = [0 0 0];
        samplePicture9F(y,x,:) = [0 0 0];
        samplePicture10F(y,x,:) = [0 0 0];
        
        samplePicture1F(x,64-y,:) = [0 0 0];
        samplePicture2F(x,64-y,:) = [0 0 0];
        samplePicture3F(x,64-y,:) = [0 0 0];
        samplePicture4F(x,64-y,:) = [0 0 0];
        samplePicture5F(x,64-y,:) = [0 0 0];
        samplePicture6F(x,64-y,:) = [0 0 0];
        samplePicture7F(x,64-y,:) = [0 0 0];
        samplePicture8F(x,64-y,:) = [0 0 0];
        samplePicture9F(x,64-y,:) = [0 0 0];
        samplePicture10F(x,64-y,:) = [0 0 0];
        
        samplePicture1F(64-y,x,:) = [0 0 0];
        samplePicture2F(64-y,x,:) = [0 0 0];
        samplePicture3F(64-y,x,:) = [0 0 0];
        samplePicture4F(64-y,x,:) = [0 0 0];
        samplePicture5F(64-y,x,:) = [0 0 0];
        samplePicture6F(64-y,x,:) = [0 0 0];
        samplePicture7F(64-y,x,:) = [0 0 0];
        samplePicture8F(64-y,x,:) = [0 0 0];
        samplePicture9F(64-y,x,:) = [0 0 0];
        samplePicture10F(64-y,x,:) = [0 0 0];
    end
end

% The background of the output image is read in and the sample image
% analysis areas are pasted on it. 
blankBackground = imread('background3.bmp');
blankBackground1 = imresize(blankBackground, 0.875); 

% First, all of the sample images of the 10 substances are placed on the
% blankBackground1
sampleBackground = blankBackground1; 
for x= 1:63
    for y = 1:63
        sampleBackground(200+y,76+x,:) = samplePicture1F(y,x,:); 
        sampleBackground(290+y,76+x,:) = samplePicture2F(y,x,:);
        sampleBackground(380+y,76+x,:) = samplePicture3F(y,x,:);
        sampleBackground(470+y,76+x,:) = samplePicture4F(x,y,:); 
        sampleBackground(560+y,76+x,:) = samplePicture5F(x,y,:);
        sampleBackground(650+y,76+x,:) = samplePicture6F(x,y,:);
        sampleBackground(740+y,76+x,:) = samplePicture7F(x,y,:);
        sampleBackground(830+y,76+x,:) = samplePicture8F(x,y,:);
        sampleBackground(920+y,76+x,:) = samplePicture9F(x,y,:);
        sampleBackground(1010+y,76+x,:) = samplePicture10F(x,y,:);
    end
end

% Then logos and other sponsor images are included 
purdue = imread('purdue2.png'); 
purdueF = imresize(purdue,0.2); 
for x = 1:126
    for y = 1:68
        if purdueF(y,x,1) ~= 0 || purdueF(y,x,2) ~= 0 || purdueF(y,x,3) ~= 0
            sampleBackground(25+y,500+x,:) = purdueF(y,x,:); 
        end
    end
end
iconBackground2 = sampleBackground; 

% Now text and other output values are pasted onto the background. If
% "errorCheck" equals 1, then the standard deviations of the RGB values
% from the 10 sample images are too high and only a request to retake the
% image is given to the user 
if errorCheck == 1
    textImage = insertText(sampleBackground,[200 350],'reading error','FontSize',30,'BoxOpacity',0,'Textcolor','white'); 

%Otherwise, the code starts adding output to the output image. It first
%adds a name and date, followed by the 10 parameters, then the values of
%the 10 parameters, then finally the correct ranges of the 10 parameters.
elseif errorCheck == 0 
    date1 = 'date:';
    date2 = datestr(now,'mmmm dd, yyyy HH:MM AM'); 
    dateF = [date1 ' ' date2]; 
    
    textImage0 = insertText(iconBackground2,[10 20],'name: John Purdue','FontSize',35,'BoxOpacity',0,'Textcolor','white','Font','Lucida Sans Demibold Italic');
    textImage0 = insertText(textImage0,[10 100],dateF,'FontSize',35,'BoxOpacity',0,'Textcolor','white');
    
    %

    position1 = [ 150 203 ; 150 293 ; 150 383 ; 150 473 ; 150 563 ; 150 653 ; 150 743 ; 150 833 ; 150 923 ; 150 1013 ]; 
    
    text1{1} = 'bilirubin';
    text1{2} = 'glucose';
    text1{3} = 'specific gravity';
    text1{4} = 'ketone';
    text1{5} = 'pH';
    text1{6} = 'blood';
    text1{7} = 'urobilinogen';
    text1{8} = 'protein'; 
    text1{9} = 'leukocytes';
    text1{10} = 'nitrite'; 
    BoxColor = [ bilColor ; gluColor ; sgColor ; ketColor ; pHColor ; bloColor ; uroColor ; proColor ; leuColor ; nitColor ];  
    celltext1 = cellstr(text1);
    
    for x = 1:10 
        if BoxColor(x,1) == 205 && BoxColor(x,2) == 50 && BoxColor(x,3) == 50
            textColor(x,:) = [255 255 255]; 
        elseif BoxColor(x,1) == 250 && BoxColor(x,2) == 250 && BoxColor(x,3) == 0
            textColor(x,:) = [0 0 0]; 
        elseif BoxColor(x,1) == 50 && BoxColor(x,2) == 205 && BoxColor(x,3) == 50
            textColor(x,:) = [0 0 0]; 
        end
    end  
        
    textImage1 = insertText(textImage0,position1,celltext1,'FontSize',31,'BoxColor',BoxColor,'BoxOpacity',0.8,'Textcolor',textColor,'Font','LucidaSansDemiBold'); 
    
    %
    
    position2 = [ 420 204 ; 420 294 ; 420 384 ; 420 474 ; 420 564 ; 420 654 ; 420 744 ; 420 834 ; 420 924 ; 420 1014 ]; 
    
    text2{1} = bilOutput;
    text2{2} = gluOutput;
    text2{3} = sgOutput;
    text2{4} = ketOutput;
    text2{5} = pHOutput;
    text2{6} = bloOutput;
    text2{7} = uroOutput;
    text2{8} = proOutput; 
    text2{9} = leuOutput;
    text2{10} = nitOutput; 
    celltext2 = cellstr(text2);

    textImage2 = insertText(textImage1,position2,celltext2,'FontSize',30,'BoxColor',[50 50 205],'BoxOpacity',0.8,'Textcolor','white'); 
    
    %
    
    position3 = [ 420 254 ; 420 344 ; 420 434 ; 420 524 ; 420 614 ; 420 704 ; 420 794 ; 420 884 ; 420 974 ; 420 1064 ]; 
 
    text3{1} = 'mg/dL'; 
    text3{2} = 'mg/dL';
    text3{3} = 'ratio';
    text3{4} = 'mg/dL';
    text3{5} = '1-14';
    text3{6} = ['ery/' , char(0181) , 'L'];
    text3{7} = 'mg/dL';
    text3{8} = 'mg/dL'; 
    text3{9} = ['Leu/' , char(0181) , 'L'];
    text3{10} = 'none';
    
    celltext3 = cellstr(text3);
    
    textImage3 = insertText(textImage2,position3,celltext3,'FontSize',20,'BoxOpacity',0,'Textcolor','white','Font','Lucida Sans Demibold Italic');
    
    %
    
    position4 = [ 515 204 ; 515 294 ; 515 384 ; 515 474 ; 515 564 ; 515 654 ; 515 744 ; 515 834 ; 515 924 ; 515 1014 ]; 
 
    text4{1} = 'MAX: 0'; 
    text4{2} = 'MAX: 140';
    text4{3} = 'MAX: 1.035';
    text4{4} = 'MAX: 40';
    text4{5} = 'MAX: 7.25';
    text4{6} = 'MAX: 3';
    text4{7} = 'MAX: 1';
    text4{8} = 'MAX: 10'; 
    text4{9} = 'MAX: 20';
    text4{10} = 'MAX: 0';
    
    celltext4 = cellstr(text4);
    
    textImage4 = insertText(textImage3,position4,celltext4,'FontSize',20,'BoxOpacity',0.8,'Textcolor','white','BoxColor',BoxColor,'TextColor',textColor);
    
    %
    
    position5 = [ 515 244 ; 515 334 ; 515 424 ; 515 514 ; 515 604 ; 515 694 ; 515 784 ; 515 874 ; 515 964 ; 515 1054 ]; 
 
    text5{1} = 'MIN: 0'; 
    text5{2} = 'MIN: 0';
    text5{3} = 'MIN: 1.002';
    text5{4} = 'MIN: 0';
    text5{5} = 'MIN: 6.5';
    text5{6} = 'MIN: 0';
    text5{7} = 'MIN: 0';
    text5{8} = 'MIN: 0'; 
    text5{9} = 'MIN: 0';
    text5{10} = 'MIN: 0';
    
    celltext5 = cellstr(text5);
    
    textImage5 = insertText(textImage4,position5,celltext5,'FontSize',20,'BoxOpacity',0.8,'Textcolor','white','BoxColor',BoxColor,'TextColor',textColor);
    
    end

% The final step is adding in the check, warning, and error pictures to
% each parameter. 
signImage = textImage5; 
for x = 1:60
    for y = 1:60
        
        if bilImage(y,x,1) ~= 0 || bilImage(y,x,2) ~= 0 || bilImage(y,x,3) ~= 0
            signImage(200+y,5+x,:) = bilImage(y,x,:); 
        end
        
        if gluImage(y,x,1) ~= 0 || gluImage(y,x,2) ~= 0 || gluImage(y,x,3) ~= 0
            signImage(290+y,5+x,:) = gluImage(y,x,:); 
        end
        
        if sgImage(y,x,1) ~= 0 || sgImage(y,x,2) ~= 0 || sgImage(y,x,3) ~= 0
            signImage(380+y,5+x,:) = sgImage(y,x,:); 
        end
        
        if ketImage(y,x,1) ~= 0 || ketImage(y,x,2) ~= 0 || ketImage(y,x,3) ~= 0
            signImage(470+y,5+x,:) = ketImage(y,x,:); 
        end
        
        if pHImage(y,x,1) ~= 0 || pHImage(y,x,2) ~= 0 || pHImage(y,x,3) ~= 0
            signImage(560+y,5+x,:) = pHImage(y,x,:); 
        end
        
        if bloImage(y,x,1) ~= 0 || bloImage(y,x,2) ~= 0 || bloImage(y,x,3) ~= 0
            signImage(650+y,5+x,:) = bloImage(y,x,:); 
        end
        
        if uroImage(y,x,1) ~= 0 || uroImage(y,x,2) ~= 0 || uroImage(y,x,3) ~= 0
            signImage(740+y,5+x,:) = uroImage(y,x,:); 
        end
        
        if proImage(y,x,1) ~= 0 || proImage(y,x,2) ~= 0 || proImage(y,x,3) ~= 0
            signImage(830+y,5+x,:) = proImage(y,x,:); 
        end
        
        if leuImage(y,x,1) ~= 0 || leuImage(y,x,2) ~= 0 || leuImage(y,x,3) ~= 0
            signImage(920+y,5+x,:) = leuImage(y,x,:); 
        end
        
        if nitImage(y,x,1) ~= 0 || nitImage(y,x,2) ~= 0 || nitImage(y,x,3) ~= 0
            signImage(1010+y,5+x,:) = nitImage(y,x,:); 
        end
    end
end

imshow(signImage); 
toc