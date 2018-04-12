function matrix = ordermatrix(matrix,order,dimension)
%ORDERMATRIX Orders a matrix.
%   An example for the order might for example be the second output of the
%   sort-command. The simensions has to be set according to the dimension
%   of the sort 

% Set default value for dimensions.
if nargin<3
    dimension = 1;
end

% Validate inputs.
assert( ...
    all(size(matrix) == size(order)), ...
    'Expected inputs matrix and order to have the same dimensions.');

validateattributes( ...
    matrix, ...
    {'numeric','gpuArray'}, ...
    {'ndims',2});

validateattributes( ...
    order, ...
    {'numeric','gpuArray'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer','positive'});

validateattributes( ...
    dimension, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>=',1,'<=',2});

if dimension == 2
    matrix = matrix';
    order = order';
end

[nRows,nColumns] = size(matrix);
order = sub2ind([nRows nColumns],order,repmat(1:nColumns,nRows,1));

matrix = matrix(order);

if dimension == 2
    matrix = matrix';
end

end

