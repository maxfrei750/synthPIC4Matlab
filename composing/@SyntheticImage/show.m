function varargout = show(obj,varargin)

if obj.nLayers > 0
    [varargout{1:nargout}] = imshow(obj.pixelData);
else
    warning('There are no layers to show yet.');
end

end