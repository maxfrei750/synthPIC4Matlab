function generateagglomeratedataset( ...
    outputPath, ...
    nPrimaryParticleArray, ...
    agglomerationMode, ...
    fractionList, ...
    nAgglomerates_offset, ...
    varargin)
%GENERATEAGGLOMERATEDATASET Summary of this function goes here
%   Detailed explanation goes here

% Create a pool with as many workers as there are CPU cores. If necessary, close
% old pools.
hPool = gcp('nocreate');

if isempty(hPool)
    nWorkers = 0;
else
    nWorkers = hPool.NumWorkers;
end

nCores = feature('numcores');

if nWorkers ~= nCores
    delete(hPool);
    parpool('local',nCores);
end

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
progressBar = CommandLineProgressBar(nAgglomerates-nAgglomerates_offset);
progressBar.message = ['Generating agglomerates:' newline];

% Generate agglomerates.
tic;
parfor iAgglomerate = (1+nAgglomerates_offset):nAgglomerates
    
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

