function tf = isgpuavailable
%ISGPUAVAILABLE Determines whether a compatible GPU is available.
%   Returns true, if a compatible GPU is available and false if not.
%   The actual test is only performed on the first call to
%   |isgpuavailable|.

persistent isAvailable

if isempty(isAvailable)
    try
        gpu = gpuDevice;
        isAvailable = gpu.SupportsDouble;
    catch
        isAvailable = false;
    end
end

tf = isAvailable;

end