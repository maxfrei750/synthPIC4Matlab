function varargout = imshowtiles(image,tileSize)
%IMSHOWTILES Display an image with a tile-overlay.

[imageHeight,imageWidth] = size(image);

[varargout{1:nargout}] = imshow(image);

hold on

nTiles_x = floor(imageWidth/tileSize);
nTiles_y = floor(imageHeight/tileSize);

for iTile_x = 1:nTiles_x-1
    plot(ones(2,1)*iTile_x*tileSize,[0 imageHeight],'w:','LineWidth',0.5);
end

for iTile_y = 1:nTiles_y-1
    plot([0 imageWidth],ones(2,1)*iTile_y*tileSize,'w:','LineWidth',0.5);
end

for iTile_x = 1:nTiles_x
    for iTile_y = 1:nTiles_y
        tileString = sprintf('%d,%d',iTile_x,iTile_y);
        text((iTile_x-0.5)*tileSize,(iTile_y-0.5)*tileSize,tileString,'HorizontalAlignment','center','FontSize',8,'color','w');
    end
end

hold off

end

