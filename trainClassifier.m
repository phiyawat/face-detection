faceSize = 2429;
noneFaceSize = 4547;
selectT = 50;

%integral face images
face = cell(1,faceSize);
error = 0;

fprintf('Integral face images\n');
for faceNum = 1:faceSize
    str = 'trainClassifier/Face/';
    f = int2str(faceNum);
    fullPath = strcat(str,f,'.pgm');
    f = imread(fullPath);
    f = 255*im2double(f);
    [r] = size(f,1);
    [c] = size(f,2);
    a = zeros(r,c);
    count = 0;
    k = 1;
    k2 = 1;
    
for i=1:r
    for j=1:c
            k = i;
            k2 = j;
               while k > 0 
                   while k2 > 0
                       count = f(k,k2)+count;
                       k2 = k2-1;
                   end
                   k = k-1;
                   k2 = j;
               end
           k = 1;
           k2 = 1;
           a(i,j) = count;
           count = 0;
    end
end
face{faceNum} = a;
end

%integral noneFace images
fprintf('Integral noneFace images\n');
noneFace = cell(1,noneFaceSize);

for noneFaceNum = 1:noneFaceSize
    str = 'trainClassifier/noneFace/';
    f = int2str(noneFaceNum);
    fullPath = strcat(str,f,'.pgm');
    f = imread(fullPath);
    f = 255*im2double(f);
    [r] = size(f,1);
    [c] = size(f,2);
    a = zeros(r,c);
    count = 0;
    k = 1;
    k2 = 1;
    
for i=1:r
    for j=1:c
            k = i;
            k2 = j;
               while k > 0 
                   while k2 > 0
                       count = f(k,k2)+count;
                       k2 = k2-1;
                   end
                   k = k-1;
                   k2 = j;
               end
           k = 1;
           k2 = 1;
           a(i,j) = count;
           count = 0;
    end
end
noneFace{noneFaceNum} = a;
end


%feature eyes
fprintf('Create feature eyes\n');
black = zeros(r,c);
white = zeros(r,c); 
wb = zeros(r,c);
maskSize = 4; % 2x2 pixel

%harr like feature --> Face
%{
 1 1 
 0 0 
%}
faceHaar = cell(1,faceSize);
for faceNum = 1:faceSize
   a = face{faceNum};
for i=1:r-maskSize+1
    for j=1:c-maskSize+1
        if i == 1 && j == 1
            white(i,j) = a(maskSize,maskSize)-a(maskSize/2,maskSize);
            black(i,j) = a(maskSize/2,maskSize);
            wb(i,j) = white(i,j)-black(i,j);   
        elseif i == 1
            white(i,j) = a(maskSize,maskSize+(j-1))-a(maskSize/2,maskSize+(j-1))-a(maskSize,j-1)+a(maskSize/2,j-1);   
            black(i,j) = a(maskSize/2,maskSize+(j-1))-a(maskSize/2,j-1);
            wb(i,j) = white(i,j)-black(i,j);
        elseif j == 1
            white(i,j) = a(maskSize+(i-1),maskSize)-a((maskSize/2)+(i-1),maskSize);
            black(i,j) = a((maskSize/2)+(i-1),maskSize)-a(i-1,maskSize);
            wb(i,j) = white(i,j)-black(i,j); 
        else
            white(i,j) = a(maskSize+(i-1),maskSize+(j-1))-a((maskSize/2)+(i-1),maskSize+(j-1))-a(maskSize+(i-1),j-1)+a((maskSize/2)+(i-1),j-1);
            black(i,j) = a((maskSize/2)+(i-1),maskSize+(j-1))-a(i-1,maskSize+(j-1))-a((maskSize/2)+(i-1),j-1)+a(i-1,j-1);
            wb(i,j) = white(i,j)-black(i,j);
        end
    end
end
faceHaar{faceNum} = wb;
end

%faceMean,Min,Max in pixel such as (1,1)
faceMean = zeros(faceSize,1);
mean = zeros(r,c);
faceMax = zeros(r,c);
faceMin = zeros(r,c);

faceMeanHaar = cell(1,3);
faceMaxHaar = cell(1,3);
faceMinHaar = cell(1,3);

for i = 1:r
    for j = 1:c
        k = 1;
        while k <= faceSize
            b = faceHaar{k};
            c2 = b(i,j);
            faceMean(k) = c2; 
            k = k+1;
        end
        mean(i,j) = sum(faceMean)/faceSize;
        faceMax(i,j) = max(faceMean);
        faceMin(i,j) = min(faceMean);
        k = 1;
    end
end

faceMeanHaar{1} = mean;
faceMaxHaar{1} = faceMax;
faceMinHaar{1} = faceMin;

%harr like feature --> noneFace
%{
 1 1 
 0 0 
%}
noneFaceHaar = cell(1,noneFaceSize);
for noneFaceNum = 1:noneFaceSize
   a = noneFace{noneFaceNum};
for i=1:r-maskSize+1
    for j=1:c-maskSize+1
        if i == 1 && j == 1
            white(i,j) = a(maskSize,maskSize)-a(maskSize/2,maskSize);
            black(i,j) = a(maskSize/2,maskSize);
            wb(i,j) = white(i,j)-black(i,j);   
        elseif i == 1
            white(i,j) = a(maskSize,maskSize+(j-1))-a(maskSize/2,maskSize+(j-1))-a(maskSize,j-1)+a(maskSize/2,j-1);   
            black(i,j) = a(maskSize/2,maskSize+(j-1))-a(maskSize/2,j-1);
            wb(i,j) = white(i,j)-black(i,j);
        elseif j == 1
            white(i,j) = a(maskSize+(i-1),maskSize)-a((maskSize/2)+(i-1),maskSize);
            black(i,j) = a((maskSize/2)+(i-1),maskSize)-a(i-1,maskSize);
            wb(i,j) = white(i,j)-black(i,j); 
        else
            white(i,j) = a(maskSize+(i-1),maskSize+(j-1))-a((maskSize/2)+(i-1),maskSize+(j-1))-a(maskSize+(i-1),j-1)+a((maskSize/2)+(i-1),j-1);
            black(i,j) = a((maskSize/2)+(i-1),maskSize+(j-1))-a(i-1,maskSize+(j-1))-a((maskSize/2)+(i-1),j-1)+a(i-1,j-1);
            wb(i,j) = white(i,j)-black(i,j);
        end
    end
end
noneFaceHaar{noneFaceNum} = wb;
end


% feature noses
fprintf('Create feature nose\n');
black = zeros(r,c);
white = zeros(r,c); 
wb = zeros(r,c);
maskSize = 6; % 3x3 pixel

%harr like feature --> Face
%{
 0 1 0 
 0 1 0 
 0 1 0
%}
faceHaar2 = cell(1,faceSize);
for faceNum = 1:faceSize
   a = face{faceNum};
for i=1:r-maskSize
    for j=1:c-maskSize
        if i == 1 && j == 1
            white(i,j) = a(maskSize,maskSize/3)+(a(maskSize,maskSize)-a(maskSize,(maskSize/3)*2));
            black(i,j) = a(maskSize,(maskSize/3)*2)-a(maskSize,maskSize/3);
            wb(i,j) = white(i,j)-black(i,j);
        elseif i == 1
            white(i,j) = a(maskSize,(maskSize/3)+(j-1))-a(maskSize,j-1)+(a(maskSize,maskSize+(j-1))-a(maskSize,((maskSize/3)*2)+(j-1)));
            black(i,j) = a(maskSize,((maskSize/3)*2)+(j-1))-a(maskSize,(maskSize/3)+(j-1));
            wb(i,j) = white(i,j)-black(i,j);
        elseif j == 1
            white(i,j) = (a(maskSize+(i-1),maskSize/3)-a(i-1,maskSize/3))+(a(maskSize+(i-1),maskSize)-a(i-1,maskSize)-a(maskSize+(i-1),(maskSize/3)*2)+...
                          a(i-1,(maskSize/3)*2));
            black(i,j) = a(maskSize+(i-1),(maskSize/3)*2)-a(i-1,(maskSize/3)*2)-a(maskSize+(i-1),maskSize/3)+a(i-1,maskSize/3);
            wb(i,j) = white(i,j)-black(i,j); 
        else           
            white(i,j) = (a(maskSize+(i-1),(maskSize/3)+(j-1))-a(i-1,(maskSize/3)+(j-1))-a(maskSize+(i-1),j-1)+a(i-1,j-1))+...
                         (a(maskSize+(i-1),maskSize+(j-1))-a(i-1,maskSize+(j-1))-a(maskSize+(i-1),((maskSize/3)*2)+(j-1))+a(i-1,((maskSize/3)*2)+(j-1)));
            black(i,j) = a(maskSize+(i-1),((maskSize/3)*2)+(j-1))-a(i-1,((maskSize/3)*2)+(j-1))-a(maskSize+(i-1),(maskSize/3)+(j-1))+a(i-1,(maskSize/3)+(j-1));
            wb(i,j) = white(i,j)-black(i,j);
        end
    end
end
faceHaar2{faceNum} = wb;
end

%faceMean,Min,Max in pixel such as (1,1)
faceMean = zeros(faceSize,1);
mean = zeros(r,c);
faceMax = zeros(r,c);
faceMin = zeros(r,c);
for i = 1:r
    for j = 1:c
        k = 1;
        while k <= faceSize
            b = faceHaar2{k};
            c2 = b(i,j);
            faceMean(k) = c2; 
            k = k+1;
        end
        mean(i,j) = sum(faceMean)/faceSize;
        faceMax(i,j) = max(faceMean);
        faceMin(i,j) = min(faceMean);
        k = 1;
    end
end

faceMeanHaar{2} = mean;
faceMaxHaar{2} = faceMax;
faceMinHaar{2} = faceMin;

%harr like feature --> noneFace
%{
 0 1 0 
 0 1 0 
 0 1 0
%}
noneFaceHaar2 = cell(1,noneFaceSize);
for noneFaceNum = 1:noneFaceSize
   a = noneFace{noneFaceNum};
for i=1:r-maskSize
    for j=1:c-maskSize
        if i == 1 && j == 1
            white(i,j) = a(maskSize,maskSize/3)+(a(maskSize,maskSize)-a(maskSize,(maskSize/3)*2));
            black(i,j) = a(maskSize,(maskSize/3)*2)-a(maskSize,maskSize/3);
            wb(i,j) = white(i,j)-black(i,j);
        elseif i == 1
            white(i,j) = a(maskSize,(maskSize/3)+(j-1))-a(maskSize,j-1)+(a(maskSize,maskSize+(j-1))-a(maskSize,((maskSize/3)*2)+(j-1)));
            black(i,j) = a(maskSize,((maskSize/3)*2)+(j-1))-a(maskSize,(maskSize/3)+(j-1));
            wb(i,j) = white(i,j)-black(i,j);
        elseif j == 1
            white(i,j) = (a(maskSize+(i-1),maskSize/3)-a(i-1,maskSize/3))+(a(maskSize+(i-1),maskSize)-a(i-1,maskSize)-a(maskSize+(i-1),(maskSize/3)*2)+...
                          a(i-1,(maskSize/3)*2));
            black(i,j) = a(maskSize+(i-1),(maskSize/3)*2)-a(i-1,(maskSize/3)*2)-a(maskSize+(i-1),maskSize/3)+a(i-1,maskSize/3);
            wb(i,j) = white(i,j)-black(i,j); 
        else           
            white(i,j) = (a(maskSize+(i-1),(maskSize/3)+(j-1))-a(i-1,(maskSize/3)+(j-1))-a(maskSize+(i-1),j-1)+a(i-1,j-1))+...
                         (a(maskSize+(i-1),maskSize+(j-1))-a(i-1,maskSize+(j-1))-a(maskSize+(i-1),((maskSize/3)*2)+(j-1))+a(i-1,((maskSize/3)*2)+(j-1)));
            black(i,j) = a(maskSize+(i-1),((maskSize/3)*2)+(j-1))-a(i-1,((maskSize/3)*2)+(j-1))-a(maskSize+(i-1),(maskSize/3)+(j-1))+a(i-1,(maskSize/3)+(j-1));
            wb(i,j) = white(i,j)-black(i,j);
        end
    end
end
noneFaceHaar2{noneFaceNum} = wb;
end


% feature mouth
fprintf('Create feature mouth\n');
black = zeros(r,c);
white = zeros(r,c); 
wb = zeros(r,c);

%harr like feature --> Face
%{
 0 0 0
 1 1 1
 0 0 0
%}
faceHaar3 = cell(1,faceSize);
for faceNum = 1:faceSize
   a = face{faceNum};
for i=1:r-maskSize
    for j=1:c-maskSize
        if i == 1 && j == 1
            white(i,j) = a(maskSize/3,maskSize)+(a(maskSize,maskSize)-a((maskSize/3)*2,maskSize));
            black(i,j) = a((maskSize/3)*2,maskSize)-a(maskSize/3,maskSize);
            wb(i,j) = white(i,j)-black(i,j);   
        elseif i == 1
            white(i,j) = (a(maskSize,maskSize+(j-1))-a((maskSize/3)*2,maskSize+(j-1))-a(maskSize,j-1)+a((maskSize/3)*2,j-1))+...
                         (a(maskSize/3,maskSize+(j-1))-a(maskSize/3,j-1));
            black(i,j) =  a((maskSize/3)*2,maskSize+(j-1))-a(maskSize/3,maskSize+(j-1))-a((maskSize/3)*2,maskSize/3)+a(maskSize/3,j-1);
            wb(i,j) = white(i,j)-black(i,j);
        elseif j == 1
            white(i,j) = (a((maskSize/3)+(i-1),maskSize)-a(i-1,maskSize)) + (a(maskSize+(i-1),maskSize)-a(((maskSize/3)*2)+(i-1),maskSize));
            black(i,j) =  a(((maskSize/3)*2)+(i-1),maskSize)-a((maskSize/3)+(i-1),maskSize);
            wb(i,j) = white(i,j)-black(i,j); 
        else           
            white(i,j) = (a((maskSize/3)+(i-1),maskSize+(j-1))-a(i-1,maskSize+(j-1))-a((maskSize/3)+(i-1),j-1)+a(i-1,j-1))+...
                         ((a(maskSize+(i-1),maskSize+(j-1))-a(((maskSize/3)*2)+(i-1),maskSize+(j-1)))-a(maskSize+(i-1),j-1)+a(((maskSize/3)*2)+(i-1),j-1));
            black(i,j) = a(((maskSize/3)*2)+(i-1),maskSize+(j-1))-a((maskSize/3)+(i-1),maskSize+(j-1))-a(((maskSize/3)*2)+(i-1),j-1)+a((maskSize/3)+(i-1),j-1);
            wb(i,j) = white(i,j)-black(i,j);
        end
    end
end
faceHaar3{faceNum} = wb;
end

%faceMean,Min,Max in pixel such as (1,1)
faceMean = zeros(faceSize,1);
mean = zeros(r,c);
faceMax = zeros(r,c);
faceMin = zeros(r,c);
for i = 1:r
    for j = 1:c
        k = 1;
        while k <= faceSize
            b = faceHaar3{k};
            c2 = b(i,j);
            faceMean(k) = c2; 
            k = k+1;
        end
        mean(i,j) = sum(faceMean)/faceSize;
        faceMax(i,j) = max(faceMean);
        faceMin(i,j) = min(faceMean);
        k = 1;
    end
end

faceMeanHaar{3} = mean;
faceMaxHaar{3} = faceMax;
faceMinHaar{3} = faceMin;

%harr like feature --> noneFace
%{
 0 0 0
 1 1 1
 0 0 0
%}
noneFaceHaar3 = cell(1,noneFaceSize);
for noneFaceNum = 1:noneFaceSize
   a = noneFace{noneFaceNum};
for i=1:r-maskSize
    for j=1:c-maskSize
        if i == 1 && j == 1
            white(i,j) = a(maskSize/3,maskSize)+(a(maskSize,maskSize)-a((maskSize/3)*2,maskSize));
            black(i,j) = a((maskSize/3)*2,maskSize)-a(maskSize/3,maskSize);
            wb(i,j) = white(i,j)-black(i,j);   
        elseif i == 1
            white(i,j) = (a(maskSize,maskSize+(j-1))-a((maskSize/3)*2,maskSize+(j-1))-a(maskSize,j-1)+a((maskSize/3)*2,j-1))+...
                         (a(maskSize/3,maskSize+(j-1))-a(maskSize/3,j-1));
            black(i,j) =  a((maskSize/3)*2,maskSize+(j-1))-a(maskSize/3,maskSize+(j-1))-a((maskSize/3)*2,maskSize/3)+a(maskSize/3,j-1);
            wb(i,j) = white(i,j)-black(i,j);
        elseif j == 1
            white(i,j) = (a((maskSize/3)+(i-1),maskSize)-a(i-1,maskSize)) + (a(maskSize+(i-1),maskSize)-a(((maskSize/3)*2)+(i-1),maskSize));
            black(i,j) =  a(((maskSize/3)*2)+(i-1),maskSize)-a((maskSize/3)+(i-1),maskSize);
            wb(i,j) = white(i,j)-black(i,j); 
        else           
            white(i,j) = (a((maskSize/3)+(i-1),maskSize+(j-1))-a(i-1,maskSize+(j-1))-a((maskSize/3)+(i-1),j-1)+a(i-1,j-1))+...
                         ((a(maskSize+(i-1),maskSize+(j-1))-a(((maskSize/3)*2)+(i-1),maskSize+(j-1)))-a(maskSize+(i-1),j-1)+a(((maskSize/3)*2)+(i-1),j-1));
            black(i,j) = a(((maskSize/3)*2)+(i-1),maskSize+(j-1))-a((maskSize/3)+(i-1),maskSize+(j-1))-a(((maskSize/3)*2)+(i-1),j-1)+a((maskSize/3)+(i-1),j-1);
            wb(i,j) = white(i,j)-black(i,j);
        end
    end
end
noneFaceHaar3{noneFaceNum} = wb;
end

strongCount = 0;
haarType = [];
pixelX = [];
pixelY = [];
storeRatingDiff = [];
storeFaceRating = [];
storeNoneFaceRating = [];
storeTotalError = [];
storeLowerBound = [];
storeUpperBound = [];
weakClassifiers = {};
imgWeights = ones(faceSize+noneFaceSize,1)./(faceSize+noneFaceSize);

fprintf('Create weak classifier\n');
for haar=1:3
    for x=1:r
        for y=1:c
            for T = 1:selectT
                C = ones(size(imgWeights,1),1);
                mean = faceMeanHaar{haar};
                faceMin = faceMinHaar{haar};
                faceMax = faceMaxHaar{haar};
                minRating = mean(x,y)-(abs((T/50)*(mean(x,y)-faceMin(x,y))));
                maxRating = mean(x,y)+(abs((T/50)*(faceMax(x,y)-mean(x,y))));
                i = 1;
                while i <= faceSize
                b = faceHaar{i};
                c2 = b(x,y);
                if c2 >= minRating && c2 <= maxRating
                    C(i) = 0;
                end 
                i = i+1;
                end

                faceRating = sum(imgWeights(1:faceSize).*C(1:faceSize));
                if faceRating < 0.05
                i = 1;
                while i <= noneFaceSize
                b = noneFaceHaar{i};
                c2 = b(x,y);
                if c2 >= minRating && c2 <= maxRating
                else
                    C(faceSize+i) = 0;
                end 
                i = i+1;
                end
                end
                noneFaceRating = sum(imgWeights(faceSize+1:noneFaceSize+faceSize).*C(faceSize+1:noneFaceSize+faceSize));
                totalError = sum(imgWeights.*C);
                if totalError < 0.5
                    strongCount = strongCount + 1;
                    haarType(strongCount) = haar;
                    pixelX(strongCount) = x;
                    pixelY(strongCount) = y;
                    storeRatingDiff(strongCount) = (1-faceRating)-noneFaceRating;
                    storeFaceRating(strongCount) = 1-faceRating;
                    storeNoneFaceRating(strongCount) = noneFaceRating;
                    storeTotalError(strongCount) = totalError;
                    storeLowerBound(strongCount) = minRating;
                    storeUpperBound(strongCount) = maxRating;
                end
            end
            if size(storeRatingDiff) > 0
                    maxRatingIndex = -inf;
                    maxRatingDiff = max(storeRatingDiff);
            for index=1:size(storeRatingDiff,2)
                if storeRatingDiff(index) == maxRatingDiff
                    maxRatingIndex = index;
                    break;
                end
            end
            end
            if size(storeRatingDiff) > 0
                thisClassifier = [haar,x,y,maxRatingDiff,storeFaceRating(maxRatingIndex),storeNoneFaceRating(maxRatingIndex),...
                                  storeLowerBound(maxRatingIndex),storeUpperBound(maxRatingIndex),storeTotalError(maxRatingIndex)];
                
                C2 = ones(faceSize+noneFaceSize,1);
                
                for i=1:faceSize
                    if haar == 1
                        f2 = faceHaar{i};
                        c3 = f2(x,y);
                    elseif haar == 2
                        f2 = faceHaar2{i};
                        c3 = f2(x,y);
                    elseif haar == 3
                        f2 = faceHaar3{i};
                        c3 = f2(x,y);
                    end
                    if c3 >= storeLowerBound(maxRatingIndex) && c3 <= storeUpperBound(maxRatingIndex) 
                        C2 = 1;
                    else
                        C2 = 0;
                        error = error+imgWeights(i);
                    end           
                end
                
                for i=1:noneFaceSize
                    if haar == 1
                        nf2 = noneFaceHaar{i};
                        c3 = nf2(x,y);
                    elseif haar == 2
                        nf2 = noneFaceHaar2{i};
                        c3 = nf2(x,y);
                    elseif haar == 3
                        nf2 = noneFaceHaar3{i};
                        c3 = nf2(x,y);
                    end
                    if c3 >= storeLowerBound(maxRatingIndex) && c3 <= storeUpperBound(maxRatingIndex) 
                        C2(faceSize+i) = 0;
                        error = error+imgWeights(i);
                    else
                        C2(faceSize+i) = 1;
                    end           
                end
                
                alpha = 0.5*log((1-error)/error);
                
                
                for i = 1:faceSize+noneFaceSize
                    if C2(i) == 0
                    imgWeights(i) = imgWeights(i).*exp(alpha);
                    else
                    imgWeights(i) = imgWeights(i).*exp(-alpha);
                    end
                end
                
                imgWeights = imgWeights./sum(imgWeights);  
                
                thisClassifier = [thisClassifier,alpha];                
                weakClassifiers{size(weakClassifiers,2)+1} = thisClassifier;                
                error = 0;  
                
            end 
            strongCount = 0;
            haarType = [];
            pixelX = [];
            pixelY = [];
            storeRatingDiff = [];
            storeFaceRating = [];
            storeNoneFaceRating = [];
            storeTotalError = [];
            storeLowerBound = [];
            storeUpperBound = [];           
        end
    end
end

fprintf('Create Strong Classifiers\n');

alphas = zeros(size(weakClassifiers,2),1);
for i = 1:size(alphas,1)
    alphas(i) = weakClassifiers{i}(10);
end

tempClassifiers = zeros(size(alphas,1),2);
tempClassifiers(:,1) = alphas;
for i = 1:size(alphas,1)
   tempClassifiers(i,2) = i; 
end

tempClassifiers = sortrows(tempClassifiers,-1);

selectedClassifiers = zeros(size(tempClassifiers),10);
for i = 1:size(tempClassifiers)
    selectedClassifiers(i,:) = weakClassifiers{tempClassifiers(i,2)};
end

fprintf('Create Strong Classifiers is Completed!!\n');
save('finalClassifiers.mat','selectedClassifiers');