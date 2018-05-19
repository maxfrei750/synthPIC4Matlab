function apply(obj)
if obj.strength > 0
    obj.parent.pixelData = ...
        imgaussfilt(obj.parent.pixelData,obj.strength);
end
end