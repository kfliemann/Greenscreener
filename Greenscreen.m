clc;
clear;
currentPath = cd;
cd Input;
%Image to edit
origin = imread("Original.png");
cd (currentPath);
cd Stock;
%Image to be inserted
stockPicture = imread("GenericStockImage.jpg");
cd (currentPath);


urMatrix = size(origin);
urH = urMatrix(1);
urW = urMatrix(2);


%Determination of the highest point
topy = urH;

%Determination of the leftmost point 
leftx = urW;

%Determination of the rightmost point
rightx = 0;

%Determination of the lowest point
boty = 0;

%Idea is that you first set on the opposite edge and move
%in each step "by cutting off" closer and closer to the actual point

%The following algorithm is used to determine the position of the green area,
%to select this section in the "sample image"


%Algorithm:
%Go through the columns row by row and check if (0,255,0) ( green value of the
%green screen pixels)
%On hit: check each position and update positions if needed

%MATRIXBUILDUP
%name(HEIGHT,WIDTH,DIMENSION)


%The inner loop iterates permanently over the width until height +1 is reached
%This loop is used to determine left / right, because if there is the same value in two
%lines is the same value, the variable is not overwritten each time.
for h = 1:urH
    for w = 1:urW
        %Test whether the pixel to be examined is 0,255,0 Green
        if( origin(h,w,1) == 0 && origin(h,w,2) == 255 && origin(h,w,3) == 0)
            
            %Update all limits if necessary
            
            %Left
            if(w < leftx)
                leftx = w;
            else
                %Do nothing so that for w = lefty is not permanently
                %updated
            end
            
            %Right
            if(w > rightx)
                rightx = w;
            else
                %Do nothing so that for w = righty is not permanently
                %updated
            end
             
        end
    end     
end

%This is the exact same loop as above just for height
for w = 1:urW
    for h = 1:urH
        
        if( origin(h,w,1) == 0 && origin(h,w,2) == 255 && origin(h,w,3) == 0)
            
            if(h < topy)
               topy = h;               
            end
            

            if(h > boty)
               boty = h;
            end
        end
    end     
end

%Determination of the green screen image crop rectangle
topleft = [topy leftx];
topright = [topy rightx];
botleft= [boty leftx];
botright = [boty rightx];

gWidth = rightx - leftx;
gHeigth = boty - topy;


%Create stock photo variables

stockMatrix = size(stockPicture);

stockHeight = stockMatrix(1);
stockWidth = stockMatrix(2);

%Check if the green screen cutout is too large for the stock image.
if(gHeigth > stockHeight)
    error('Height of the crop larger than the stock image height, select larger image.')
elseif(gWidth > stockWidth )
    error('Height of the crop larger than the stock image height, select larger image.')
end



%Split the stockpicture into the individual matrices
lR = stockPicture(:,:,1);
lG = stockPicture(:,:,2);
lB = stockPicture(:,:,3);

internalX = 1;
internalY = 1;

%Cutout an image which matches the size of the greenscreenbox created
%earlier

cutoutMatrixR = zeros(gHeigth,gWidth);
cutoutMatrixG = zeros(gHeigth,gWidth);
cutoutMatrixB = zeros(gHeigth,gWidth);

%Set an offset from the image origin top left (1,1)
%Maximum offset height = stockHeight - gHeigth
%Maximum offset Width = stockWidth - gWidth

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offsetHeight = 60;
offsetWidth = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(gHeigth+offsetHeight>stockHeight)
    error('Selected stock image crop exceeds the maximum height of the image. Choose a smaller height offset!')
elseif(gWidth+offsetWidth>stockWidth)
    error('Selected stock image crop exceeds the maximum width of the image. Choose a smaller width offset!')
end

for wi = 1:gWidth+1
    for he = 1:gHeigth+1
        cutoutMatrixR(internalY, internalX) = lR(he+offsetHeight,wi+offsetWidth);
        cutoutMatrixG(internalY, internalX) = lG(he+offsetHeight,wi+offsetWidth);
        cutoutMatrixB(internalY, internalX) = lB(he+offsetHeight,wi+offsetWidth);
            if(internalY <= gHeigth)
                internalY = internalY+1;
            else
                internalY = 1;
            end
    end
    if(internalX <=gWidth)
                internalX = internalX+1;
    else
        internalX = 1;
    end
end

ergebnis = cat(3, cutoutMatrixR, cutoutMatrixG, cutoutMatrixB);
internalX = 1;
internalY = 1;

%iterate over the greenscreenbox and insert pixels out of cropped image
for lastW = topleft(2):topleft(2)+gWidth
    for lastH = topleft(1):topleft(1)+gHeigth
               decider = 0; 
               if(origin(lastH,lastW,1) == 0 && origin(lastH,lastW,2) == 255 && origin(lastH,lastW,3) == 0)
                origin(lastH,lastW,1) = ergebnis(internalY,internalX,1);
                origin(lastH,lastW,2) = ergebnis(internalY,internalX,2);
                origin(lastH,lastW,3) = ergebnis(internalY,internalX,3);
                
               if(internalY <=gHeigth)
                    internalY = internalY+1;
                    decider = 1;
               else
                    internalY = 1;
                    decider = 1;
               end
               end
               if(decider == 0)
                   if(internalY <=gHeigth)
                    internalY = internalY+1;
                    else
                    internalY = 1;
                   end
               end
               
    end
    
    if(internalX <gWidth)
                internalX = internalX+1;
    else

    end
end

imshow(origin);
cd Result;
imwrite(origin,"Result.png");
cd (currentPath);