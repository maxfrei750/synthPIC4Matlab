function addlayer(obj,layer)

if isa(layer,'BlurLayer') && obj.nLayers == 0
    error( ...
        ['First layer of an image may not be of class BlurLayer, ' ...
        'because there is nothing to blur yet.']);
end

layer.parent = obj;
obj.layers{end+1} = layer;
layer.apply;

end