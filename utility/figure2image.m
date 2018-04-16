function image = figure2image(hFigure,imageWidth,imageHeight,resolutionDPI)
%FIGURE2IMAGE Converts a figure into an image.
%   The default resolution is 300 dpi.

% Set default value for the resolution.
if nargin<4
    resolutionDPI = 300;
end

% Validate inputs.
validateattributes( ...
    hFigure, ...
    {'matlab.ui.Figure'}, ...
    {'scalar'});

validateattributes( ...
    imageWidth, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

validateattributes( ...
    imageHeight, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

validateattributes( ...
    resolutionDPI, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

% Try to use a hardware renderer.
opengl hardware

% Set figure properties.
hFigure.Units = 'normalized';
hFigure.OuterPosition = [0 0 1 1];

hFigure.Units = 'normalized';
hFigure.Position = [0 0 1 1];

hFigure.PaperUnits = 'inches';
hFigure.PaperPosition = [0 0 imageWidth imageHeight]/resolutionDPI;

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
    hAxis.YLim = [0 imageHeight];
    hAxis.XLim = [0 imageWidth];
end

% Generate image.
image = print('-RGBImage',['-r' num2str(resolutionDPI)]);
end

