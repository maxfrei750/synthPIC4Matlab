function generateagglomeratedataset( ...
    outputPath, ...
    nPrimaryParticleArray, ...
    agglomerationMode, ...
    fractionList, ...
    varargin)
%GENERATEAGGLOMERATEDATASET Summary of this function goes here
%   Detailed explanation goes here

% Parse inputs

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

