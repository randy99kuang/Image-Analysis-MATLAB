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
        
%% STEP 4: Analysis of Sample RGB Values 
% The average red, green, and blue values of the sample areas are used to
% analyze the concentrations of various substances in the urine sample

% These matrices contain the expected values of the sample's RGB values for
% difference concentrations of substances. Each entry in each matrice
% represents a certain concentration for its respective substance. These
% values are calculated from averages from a scalar algorithm done on
% control images. 
expectedBil = [ 175.7260772 154.2071637 115.3576112  ; 179.7443577 149.0207338 118.1224221 ; 153.3233903 133.8504049 104.1221184 ; 145.7204101 119.3480671 101.6856958 ]; 

% In order to determine which value of each matrix best matches the
% samples' RGB values, the function "rbgAnalysis" is used. This function is
% contained within a different m-file and is explained in its own file.
% This function returns the index number of the matrix value that best
% corresponds with the samples' RGB values. 
bilIndex = rgbAnalysis( [ redFinal1 greenFinal1 blueFinal1 ] , expectedBil);

% Additionally, the samples' RBG value errors that were calculated earlier
% are used to determine the amount of total error in the picture taken.
% Whenever the standard deviation of an average RBG value is over 4,
% "rgbErrorCount" increases by 1. If "rgbErrorCount" is too high, then no
% output is returned and the user is asked to retake the image under better
% lighting conditions. 
rgbErrorCount = 0; 
SDmatrix = [ redError1 greenError1 blueError1 ];
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
                bilOutput = '-';
            case 2
                bilOutput = '1(17)+';
            case 3
                bilOutput = '2(35)++';
            case 4 
                bilOutput = '4(70)+++';
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

% The pictures of the analysis area on each of the 10 sample squares are
% now resized so they fit on the final image output properly. 
samplePicture1F = imresize(samplePicture1,3);

% The background of the output image is read in and the sample image
% analysis areas are pasted on it. 
blankBackground = imread('finished0.jpg'); 
blankBackground = blankBackground * 0;  

sampleBackground = blankBackground; 
for x= 1:63
    for y = 1:63
        sampleBackground(200+y,100+x,:) = samplePicture1F(y,x,:); 
    end
end

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
    text0{1} = 'name: John Purdue';
    text0{2} = [date1 ' ' date2]; 
    celltext0 = cellstr(text0); 
    position0 = [ 10 50 ; 75 100 ]; 
    textImage0 = insertText(sampleBackground,position0,celltext0,'FontSize',30,'BoxOpacity',0,'Textcolor','white'); 

    position1 = [ 200 210 ]; 
    text1{1} = 'bilirubin';
    BoxColor = [ bilColor ];  
    celltext1 = cellstr(text1);
    textImage1 = insertText(textImage0,position1,celltext1,'FontSize',30,'BoxColor',BoxColor,'BoxOpacity',0.4,'Textcolor','white'); 
    
    position2 = [ 450 185 ]; 
    text2{1} = bilOutput; 
    celltext2 = cellstr(text2);
    textImage2 = insertText(textImage1,position2,celltext2,'FontSize',20,'BoxOpacity',0,'Textcolor','white'); 
    
    position3 = [ 450 235 ]; 
    text3{1} = 'none'; 
    celltext3 = cellstr(text3);
    textImage3 = insertText(textImage2,position3,celltext3,'FontSize',20,'BoxColor',[50 50 205],'BoxOpacity',0.4,'Textcolor','white');    
end

% The final step is adding in the check, warning, and error pictures to
% each parameter. 
signImage = textImage3; 
for x = 1:60
    for y = 1:60     
        signImage(200+y,20+x,:) = bilImage(y,x,:); 
    end
end

toc