function linearOrder = matrixorder2linearorder(matrixOrder,dimension)
%MATRIXORDER2LINEARORDER Converts a matrixorder returend by the
%sort-command, into a linear order.
%   The dimensions has to be set according to the dimension of the
%   sort-command.

% Set default value for dimensions.
if nargin<2
    dimension = 1;
end

% Validate inputs.
validateattributes( ...
    matrixOrder, ...
    {'numeric','gpuArray'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer','positive','ndims',2});

validateattributes( ...
    dimension, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>=',1,'<=',2});

[m,n] = size(matrixOrder);

% Determine linearOrder.
switch dimension
    case 1
        linearOrder = bsxfun(@plus,matrixOrder,(0:m:(n-1)*m));
    case 2
        linearOrder = bsxfun(@plus,(matrixOrder-1)*m,(1:m)');
end

end

