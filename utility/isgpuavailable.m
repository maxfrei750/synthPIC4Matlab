function tf = isgpuavailable
%ISGPUAVAILABLE Determines whether a compatible GPU is available.
%   Returns true, if a compatible GPU is available and false if not.

tf = gpuDeviceCount>0;

end