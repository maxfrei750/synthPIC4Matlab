function varargout = imshowtiles(image,tileSize)
%IMSHOWTILES Display an image with a tile-overlay.

[imageHeight,imageWidth] = size(image);

[varargout{1:nargout}] = imshow(image);

hold on

nTiles_x = floor(imageWidth/tileSize);
nTiles_y = floor(imageHeight/tileSize);

nTiles = nTiles_x*nTiles_y;

for iTile_x = 1:nTiles_x
    plot(ones(2,1)*iTile_x*tileSize,[0 imageHeight],'w:','LineWidth',0.5);
end

for iTile_y = 1:nTiles_y
    plot([0 imageWidth],ones(2,1)*iTile_y*tileSize,'w:','LineWidth',0.5);
end

for iTile = 1:nTiles
    % Calculate current tile indices in x- andy y- direction.
    iTile_x = mod(iTile-1,nTiles_x)+1;
    iTile_y = floor((iTile-1)/nTiles_x)+1;
    
    tileString = sprintf('%d',iTile);
    text((iTile_x-0.5)*tileSize,(iTile_y-0.5)*tileSize,tileString,'HorizontalAlignment','center','FontSize',8,'color','w');
end

hold off

end

