f  = imread('testPicturePerson\30+\we.jpg');
f = imresize(f,[300 300]);

g = rgb2ycbcr(f);
cb = g(:,:,2);
cr = g(:,:,3);
maskImage = 19; % 19x19 pixel
threshold = [1 0.5 0.5 0.5 0.6];

%-------------------Segmentation Color-----------------------
%erosion = 15;
erosion = 5;
dilation = 1;
%------------------------------------------------------------

img = f;

[r] = size(f,1);
[c] = size(f,2);
a = zeros(r,c);
count = 0;
k = 1;
k2 = 1;

face = zeros(size(g,1),size(g,2));
[r] = size(g,1);
[c] = size(g,2);

%Color Skin Segmentation
for i = 1:r
    for j = 1:c
        if cr(i,j) > 140 && cr(i,j) < 165 && cb(i,j) > 105 && cb(i,j) < 135
            face(i,j) = f(i,j);
        else
            face(i,j) = 0;
        end
    end
end

f = face;

fprintf('Integral images\n');
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

% HaarI 
fprintf('Create feature eyes\n');
black = zeros(r,c);
white = zeros(r,c); 
wb = zeros(r,c);
maskSize = 4; 
faceHaar = cell(1,3);

for i=1:r-maskSize
    for j=1:c-maskSize
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

faceHaar{1} = wb;

% HaarII
fprintf('Create feature nose\n');
black = zeros(r,c);
white = zeros(r,c); 
wb = zeros(r,c);
maskSize = 6; 
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

faceHaar{2} = wb;

% HaarIII
fprintf('Create feature mouth\n');
black = zeros(r,c);
white = zeros(r,c); 
wb = zeros(r,c);

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

faceHaar{3} = wb;

load('finalClassifiers.mat');

class1 = selectedClassifiers(1:2,:);
class2 = selectedClassifiers(3:12,:);
class3 = selectedClassifiers(13:20,:);
class4 = selectedClassifiers(21:40,:);
class5 = selectedClassifiers(41:60,:);

pass = 0;
faces = [];

fprintf('Create Cascade Classifier\n');

    for i=1:2:r-maskImage;
        if i+maskImage > r
            break;
        end
            for j=1:2:c-maskImage
                if j+maskImage > c
                    break;
                end
                
                % class1
                result = 0;
                px = size(class1,1);
                weightSum = sum(class1(:,10));
                k = 1;
                
                while k <= px
                    window = faceHaar{class1(k,1)}(i:i+(maskImage-1),j:j+(maskImage-1));
                    if window(class1(k,2),class1(k,3)) >= class1(k,7) && window(class1(k,2),class1(k,3)) <= class1(k,8)
                        score = class1(k,10);
                    else
                        score = 0;
                    end
                    k = k+1;
                    result = result + score;
                end
                
                if result >= weightSum*threshold(1)
                    output = 1;
                    pass = pass + 1;
                else
                    output = 0;
                    pass = 0;
                end
                
                % class2
                if output == 1 && pass == 1
                result = 0;
                px = size(class2,1);
                weightSum = sum(class2(:,10));
                k = 1;
                
                while k <= px
                    window = faceHaar{class2(k,1)}(i:i+(maskImage-1),j:j+(maskImage-1));
                    if window(class2(k,2),class2(k,3)) >= class2(k,7) && window(class2(k,2),class2(k,3)) <= class2(k,8)
                        score = class2(k,10);
                    else
                        score = 0;
                    end
                    k = k+1;
                    result = result + score;
                end
                
                if result >= weightSum*threshold(2)
                    output = 1;
                    pass = pass + 1;
                else
                    output = 0;
                    pass = 0;
                end
                end  
                
                %class3
                if output == 1 && pass == 2
                result = 0;
                px = size(class3,1);
                weightSum = sum(class3(:,10));
                k = 1;
                
                while k <= px
                    window = faceHaar{class3(k,1)}(i:i+(maskImage-1),j:j+(maskImage-1));
                    if window(class3(k,2),class3(k,3)) >= class3(k,7) && window(class3(k,2),class3(k,3)) <= class3(k,8)
                        score = class3(k,10);
                    else
                        score = 0;
                    end
                    k = k+1;
                    result = result + score;
                end
                
                if result >= weightSum*threshold(3)
                    output = 1;
                    pass = pass + 1;
                else
                    output = 0;
                    pass = 0;
                end
                end 
                

                %class4
                if output == 1 && pass == 3
                result = 0;
                px = size(class4,1);
                weightSum = sum(class4(:,10));
                k = 1;
                
                while k <= px
                    window = faceHaar{class4(k,1)}(i:i+(maskImage-1),j:j+(maskImage-1));
                    if window(class4(k,2),class4(k,3)) >= class4(k,7) && window(class4(k,2),class4(k,3)) <= class4(k,8)
                        score = class4(k,10);
                    else
                        score = 0;
                    end
                    k = k+1;
                    result = result + score;
                end
                
                if result >= weightSum*threshold(4)
                    output = 1;
                    pass = pass + 1;
                else
                    output = 0;
                    pass = 0;
                end
                end 
                
                %class5
                if output == 1 && pass == 4
                result = 0;
                px = size(class5,1);
                weightSum = sum(class5(:,10));
                k = 1;
                
                while k <= px
                    window = faceHaar{class5(k,1)}(i:i+(maskImage-1),j:j+(maskImage-1));
                    if window(class5(k,2),class5(k,3)) >= class5(k,7) && window(class5(k,2),class5(k,3)) <= class5(k,8)
                        score = class5(k,10);
                    else
                        score = 0;
                    end
                    k = k+1;
                    result = result + score;
                end
                
                if result >= weightSum*threshold(5)
                    output = 1;
                    pass = pass + 1;
                else
                    output = 0;
                    pass = 0;
                end
                end 
                
                if output == 1 && pass == 5
                    bounds = [j,i,j+(18-1),i+(18-1)];
                    faces = [faces;bounds];
                end
                
          
            end              
    end


%Color Skin Segmentation
for i = 1:r
    for j = 1:c
        if cr(i,j) > 140 && cr(i,j) < 200 && cb(i,j) > 100 && cb(i,j) < 150
            face(i,j) = 1;
        else
            face(i,j) = 0;
        end
    end
end

%Erosion
select = face;
q = face;
count = 0;
while count < erosion
for i=1:r-1
    for j=1:c-1
        q(i,j) = sum(sum(face(i:i+1,j:j+1)));
        if q(i,j) == 4
            q(i,j) = 1;
        else
            q(i,j) = 0;
        end
    end
end
face = q;
count = count + 1;
end

%Dilation
q2 = q;
count = 0;
while count < dilation
for i=1:r-1
    for j=1:c-1
        q2(i,j) = sum(sum(q(i:i+1,j:j+1)));
        if q2(i,j) > 0
            q2(i,j) = 1;
        else
            q2(i,j) = 0;
        end
    end
end
q = q2;
count = count + 1;
end

q2 = q;
count = 2;
arr = [];
list = zeros(255,1);
t = 1;
c2 = 0;

for i=1:r-1
    for j=1:c-1
            if q(i,j) == 1
                    if i == 1 || j == 1
                        q2(i,j) = 0;
                    else
                    arr = [arr;q2(i-1,j);q2(i,j-1)];
                    k = 1;
                    while k <= size(arr,1)
                        if arr(k,1) > 0
                        q2(i,j) = arr(k,1);
                        if q2(i,j-1) > 0
                        c2 = q2(i,j-1);
                        end
                        list(c2,1) = q2(i-1,j); 
                        break;                        
                        end
                        k = k + 1;
                    end
                    if k-1 == size(arr,1)
                        q2(i,j) = count;
                        list(count,1) = count; 
                        count = count + 1;
                    end  
                    arr = []; 
                    end
            end
    end
end

% random color to segmentation
fprintf('random color\n');
q3 = q2;

i = 2;
segment = [];
rgb = [];

while i <= size(list,1)
    if i <= list(i,1)
        list(i,1) = i;
        randomR = randi(255);
        randomG = randi(255);
        randomB = randi(255);
        segment = [i,randomR,randomG,randomB];
        rgb = [rgb;segment];
    end
    i = i + 1;
end

i = 2;
j = 2;

% equivalence table
fprintf('equivalence table\n');
while i <= size(list,1)
    if list(i,1) == 0
        break;
    end
    result = i;
    while result ~= list(result,1);
        count = list(i,1);
        result = list(count,1);
    end    
    list(i,1) = list(result,1);
    i = i + 1;
end


% final segmentation color
fprintf('final segmentation color!!\n');
count = 2;
while count <= size(list,1)
if list(count,1) == 0
    break;
end
for i = 1:size(q2,1)
    for j = 1:size(q2,2)
        if  q2(i,j) == count
            k = 1;
            while k <= size(rgb,1)
                if list(count,1) == rgb(k,1)
                q3(i,j,1) = rgb(k,2);
                q3(i,j,2) = rgb(k,3);
                q3(i,j,3) = rgb(k,4); 
                end                
            k = k + 1;
            end
        end
    end
end
count = count + 1;
end

fprintf('Finish!!\n');

g = mat2gray(img);
subplot(1,2,1);
imshow(g);

hold on;

i = 1;
count = 0;
while i <= size(faces,1)
a = faces(i,2);
b = faces(i,1);
if q2(a,b) > 0
plot([faces(i,1) faces(i,1) faces(i,3) faces(i,3) faces(i,1)],[faces(i,2) faces(i,4) faces(i,4) faces(i,2) faces(i,2)],'LineWidth',2);
count = count + 1;
end
i = i+1;
end
title('position face in picture');
hold off;

g2 = mat2gray(q3);
subplot(1,2,2);
imshow(g2);
title(['There are ',num2str(size(rgb,1)),' person in picture']);

fprintf('count = %d\n',count);




