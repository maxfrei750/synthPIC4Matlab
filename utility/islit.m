function tf = islit(ax)

% If no axis was specified, then use the current axis.
if nargin < 1
    ax = gca;
end

tf = false;

% Iterate all children of the current axis.
for child = ax.Children'
    % Check if current child is a light object.
    if isa(child,'matlab.graphics.primitive.Light')
        tf = true;
        break
    end
end

end
