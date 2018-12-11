function createdirectory(path)
%CREATEDIRECTORY Create a directory.
%   Create a directory if it doesn't exist already.

if ~exist(path, 'dir')
  mkdir(path);
end

end

