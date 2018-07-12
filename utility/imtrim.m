function image = imtrim(image,top,bottom,left,right)
    
% Validate |image|.
validateattributes( ...
    image, ...
    {'int16','logical','single','double','uint16', 'uint8'}, ...
    {'real','nonsparse'}, ...
    mfilename, ...
    'image',1);

% Convert top, bottom, left and right to uint16, so they are positive.
top = uint16(top);
bottom = uint16(bottom);
left = uint16(left);
right = uint16(right);

% If the trimming in x or y is larger than the image size, then there are
% no pixels left.
[height,width] = size(image);

trimming_x = left+right;
trimming_y = top+bottom;

if (trimming_x >= width) || (trimming_y >= height)
    image = [];
    return
end

% If the amount is smaller equal to zero, then no trimming has to be 
% performed.
if top>0
    image(1:top,:,:) = [];
end

if bottom>0
    image((end-bottom+1):end,:,:) = [];
end

if left>0
    image(:,1:left,:) = [];
end

if right>0
    image(:,(end-right+1:end),:) = [];
end

end