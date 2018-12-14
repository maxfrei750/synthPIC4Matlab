function generateagglomeratedataset( ...
    outputPath, ...
    nPrimaryParticleArray, ...
    agglomerationMode, ...
    fractionList, ...
    varargin)
%GENERATEAGGLOMERATEDATASET Summary of this function goes here
%   Detailed explanation goes here

assert(~exist(outputPath,'dir'),'Output folder already exists.')

% Create outputPath.
createdirectory(outputPath);

% Setup parallel pool.
setupparallelpool
dataQueue = parallel.pool.DataQueue;

% Get number of agglomerates.
nAgglomerates = numel(nPrimaryParticleArray);

% Setup progress bar.
progressBar = CommandLineProgressBar(nAgglomerates);
progressBar.message = ['Generating agglomerates:' newline];

% Generate agglomerates.
tic;
afterEach(dataQueue, @(varargin) increment(progressBar));
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
    send(dataQueue,iAgglomerate);
end
toc;
end

