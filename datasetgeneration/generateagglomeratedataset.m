function generateagglomeratedataset( ...
    outputPath, ...
    nPrimaryParticleArray, ...
    agglomerationMode, ...
    fractionList, ...
    nAgglomerates_offset, ...
    varargin)
%GENERATEAGGLOMERATEDATASET Summary of this function goes here
%   Detailed explanation goes here

% Parse inputs
isPositiveIntegerScalar = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer','scalar','>=',0});

isPositiveIntegerVector = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer','vector','>=',0});

p = inputParser;
addRequired(p,'outputPath',@ischar);
addRequired(p,'nPrimaryParticleArray',isPositiveIntegerVector);
addRequired(p,'agglomerationMode'); % Validation in sub-function.
addRequired(p,'fractionList'); % Validation in sub-function.
addOptional(p,'nAgglomerates_offset',0,isPositiveIntegerScalar);

parse(p,outputPath,nPrimaryParticleArray,agglomerationMode,fractionList,nAgglomerates_offset);

% Create outputPath.
createdirectory(outputPath);

% Get number of agglomerates.
nAgglomerates = numel(nPrimaryParticleArray);

% Setup progress bar.
progressBar = CommandLineProgressBar(nAgglomerates);
progressBar.message = ['Generating agglomerates:' newline];

% Generate agglomerates.
tic;
parfor iAgglomerate = 1:nAgglomerates
    
    nPrimaryParticles = nPrimaryParticleArray(iAgglomerate);
    
    outputFile = matfile( ...
        fullfile(outputPath,sprintf('%06d.mat',iAgglomerate)), ...
        'Writable',true);
    
    agglomerate =  Agglomerate( ...
        agglomerationMode, ...
        fractionList, ...
        nPrimaryParticles, ...
        'randomSeed',iAgglomerate, ...
        varargin{:});
    
    outputFile.agglomerate = agglomerate;
    
    % Update progressbar.
    progressBar.increment;
end
toc;
end

