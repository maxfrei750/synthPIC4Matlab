clear
% close all

imageHeight = 96;
imageWidth = 128;

scale = 10;

resolution = 1;

% image = zeros(imageHeight,imageWidth);

z = 2;

i = 0;

for y_image = 1:imageHeight
    i = i+1;
    j = 0;
    
    x_noise = y_image/scale;
    
    for x_image = 1:imageWidth
        j = j+1;
        
        y_noise = x_image/scale;
        
        point = [x_noise y_noise z];
        
        image(i,j) = calculatesimplexamplitude3d(point);
        
%         imagesc(image)
%         drawnow
    end
end

figure
imshow(mat2gray(image))
       

