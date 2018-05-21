function image = figure2image(hFigure,imageSize,resolutionDPI)
%FIGURE2IMAGE Converts a figure into an image.
%   The default resolution is 300 dpi.

% Set default value for the resolution.
if nargin<3
    resolutionDPI = 300;
end

% Validate inputs.
validateattributes( ...
    hFigure, ...
    {'matlab.ui.Figure'}, ...
    {'scalar'});

validateattributes( ...
    imageSize, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});

validateattributes( ...
    resolutionDPI, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

% Assign imageHeight and imageWidth.
imageHeight = imageSize(1);
imageWidth = imageSize(2);

% Set cropping buffer
croppingBuffer = 10;

% Try to use a hardware renderer.
opengl hardware

% Set figure properties.
hFigure.Units = 'normalized';
hFigure.OuterPosition = [0 0 0.5 0.5];

hFigure.Units = 'normalized';
hFigure.Position = [0 0 1 1];

hFigure.PaperUnits = 'inches';
hFigure.PaperPosition = ...
    ([0 0 imageWidth imageHeight]+[0 0 2 2].*croppingBuffer) / ...
    resolutionDPI;

% Set properties of all axes.
nAxes = numel(hFigure.Children);

for iAxis = 1:nAxes
    % Select axis.
    hAxis = hFigure.Children(iAxis);
    
    % Set properties of the current axis.
    view(hAxis,2)
    hAxis.Visible = 'off';
    hAxis.Units = 'normalized';
    hAxis.Position = [0 0 1 1];
    hAxis.YLim = [0 imageHeight]+[-1 1].*croppingBuffer;
    hAxis.XLim = [0 imageWidth]+[-1 1].*croppingBuffer;
end

% Generate image.
image = print(hFigure,'-RGBImage',['-r' num2str(resolutionDPI)]);

% Crop buffer to remove edge effects.
image = ...
    imcrop(image,[croppingBuffer+2 croppingBuffer imageWidth-1 imageHeight-1]);
end

