function agglomerateDataset = readagglomeratedataset(inputPath,nFiles_desired,doRandomize)
%READAGGLOMERATEDATASET Accumulate a dataset of agglomerates.

% List the mat files in the input folder.
files = dir(fullfile(inputPath,'*.mat'));

% Get number of available files.
nFiles_total = numel(files);

% If the user does not specify otherwise, then return all available files.
if nargin<2
    nFiles_desired = nFiles_total;
end

% Do a random selection by default.
if nargin<3
    doRandomize = false;
end

% Validate inputs.
validateattributes( ...
    nFiles_desired, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar','integer'});

validateattributes( ...
    doRandomize, ...
    {'logical'}, ...
    {'scalar'});

% Check if the requested number of files is available.
assert( ...
    nFiles_total<=nFiles_desired, ...
    'You requested %d items, but only %d are available.', ...
    nFiles_desired,nFiles_total);

% Shuffle the files.
if doRandomize
    selectionIndices = randperm(nFiles_total);
    files = files(selectionIndices);
end

% Select the desired number of files.
files = files(1:nFiles_desired);

% Read the files and store them into an array.
agglomerateDataset = Agglomerate.empty(nFiles_desired,0);

% Setup parallel pool.
setupparallelpool
dataQueue = parallel.pool.DataQueue;

%% Setup progress bar.
progressBar = CommandLineProgressBar(nFiles_desired);
progressBar.message = ['Reading files:' newline];

tic;
afterEach(dataQueue, @(varargin) increment(progressBar));
parfor iFile = 1:nFiles_desired
    file = files(iFile);
    
    temp = load(fullfile(file.folder,file.name));
    
    % Convert the struct to a cell, so that it can be indexed.
    temp = struct2cell(temp);
    
    % Add the agglomerate to the dataset.
    agglomerateDataset(iFile) = temp{1};
    
    % Update progressbar.
    send(dataQueue,iFile);
end
toc;

end

