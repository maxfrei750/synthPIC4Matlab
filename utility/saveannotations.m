function saveannotations(classes,folderPath)
%SAVEANNOTATIONS Summary of this function goes here
%   Detailed explanation goes here

% Validate the input.
validateattributes( ...
    classes, ...
    {'categorical','cell'}, ...
    {'column'});

% Convert categorical or cell array to table.
classes = cell2table(cellstr(classes));

path = fullfile(folderPath,'annotations.txt');

writetable(classes,path,'WriteVariableNames',false)
end

