function image = im2datatype(image,datatype)
%IM2DATATYPE converts an image to the specified datatype.

switch lower(datatype)
    case 'single'
       image = im2single(image);
    case 'double'
        image = im2double(image);
    case 'uint8'
        image = im2uint8(image);
    case 'uint16'
        image = im2uint16(image);
    case 'int16'
        image = im2int16(image);
    case 'logical'
        image = logical(image);
    otherwise
        error('Unknown datatype: %s',datatype);
end
end

