function memoryConsumption = getmemoryconsumption(variable)
%GETMEMORYCONSUMPTION returns the memory consumption of a variable.
%   The memory consumption is returned in bytes. GpuArrays are supported.

switch class(variable)
    case 'gpuArray'
        
        dataType = classUnderlying(variable);
        
        switch dataType
            case 'double'
                bytesPerElement = 8;
            case 'single'
                bytesPerElement = 4;
            case 'logical'
                bytesPerElement = 1;
            otherwise
                bytesPerElement = ...
                    str2double(regexprep(dataType,'[a-z]',''))/8;
        end
        
        if ~isreal(variable)
            bytesPerElement = 2*bytesPerElement;
        end
        
        memoryConsumption = bytesPerElement*numel(variable);
        
    otherwise
        
        variableInfo = whos('variable');
        memoryConsumption = variableInfo.bytes;
end

