function md5 = image2md5(image)
%IMAGE2MD5 Calculate the md5 of an image.

% Validate input.
validateattributes( ...
    image, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','3d'});

hashingOptions.Input = 'bin';
md5 = DataHash(image,hashingOptions);
end

