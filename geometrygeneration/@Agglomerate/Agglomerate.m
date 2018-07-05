classdef Agglomerate < matlab.mixin.Copyable
    %AGGLOMERATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mesh = Mesh.empty;
        bulkDensity = 1
        fractions = Fraction.empty
        agglomerationMode
        agglomerationSpeed
        
        randomSeed
    end
    
    properties(SetAccess=private)
        childList = Agglomerate.empty
    end
    
    properties(Dependent = true)
        boundingBox
        completeMesh
        centroid
        mass
        volume
        radiusOfGyration
        centerOfMass
        nFractions
        nChildren
    end

    methods
        function obj = Agglomerate(agglomerationMode,fractions,nParticles,varargin)
            %AGGLOMERATE Construct an agglomerate.
            
            % Allow creation of dummy agglomerates.
            if nargin == 0
                return
            end
            
            % Parse input parameters.
            p = inputParser;
            
            expectedAgglomerationTypes = {'BPCA','DLA','BCCA','DLCA'};
            
            isValidAgglomerationType = ...
                @(x) any(validatestring(x,expectedAgglomerationTypes));
            
            isValidFractionList  = @(x) isa(x,'Fraction') && isvector(x);
            
            isPositiveRealScalarNumber = @(x) ...
                isscalar(x) && ...
                x>0 && ...
                ~isnan(x) && ...
                isreal(x);
            
            % If no random seed was specified, then keep the current random
            % seed.
            currentRandomNumberGenerator = rng;
            defaultRandomSeed = currentRandomNumberGenerator.Seed;
            
            addRequired(p,'agglomerationType',isValidAgglomerationType);
            addRequired(p,'fractionArray',isValidFractionList);
            addRequired(p,'nParticles',isPositiveRealScalarNumber);
            addParameter(p,'agglomerationSpeed',10,isPositiveRealScalarNumber);
            addParameter(p,'randomSeed',defaultRandomSeed);
            
            parse(p,agglomerationMode,fractions,nParticles,varargin{:});
            
            obj.agglomerationMode = upper(agglomerationMode);
            obj.fractions = fractions;
            obj.agglomerationSpeed = p.Results.agglomerationSpeed;
            obj.randomSeed = p.Results.randomSeed;
            
            % Set seed of the random number generator.
            rng(obj.randomSeed);
            
            % Create the particle list.
            particleList = createparticlelist(fractions,nParticles);
            
%             obj.childList(1) = particleList(1).copy;
            
            % Distinguish the different agglomeration mechanisms.
            switch obj.agglomerationMode
                case 'BPCA'
                    randomness = 0;
                    obj = obj.particleagglomeration(particleList,randomness);
                case 'DLA'
                    randomness = 1;
                    obj = obj.particleagglomeration(particleList,randomness);
                case 'BCCA'
                    randomness = 0;
                    obj = obj.clusteragglomeration(particleList,randomness);
                case 'DLCA'
                    randomness = 1;
                    obj = obj.clusteragglomeration(particleList,randomness);
            end
            
        end
        
        %% Getter methods.
        function completeMesh = get.completeMesh(obj)
            
            completeMesh = obj.mesh;
            
            % Gather descendants.
            descendants = obj.getalldescendants;
            nDescendants = numel(descendants);
            
            % Iterate all descendants.
            for iDescendant = 1:nDescendants
                descendant = descendants(iDescendant);
                completeMesh = completeMesh+descendant.mesh;
            end
        end
        
        function boundingBox = get.boundingBox(obj)
            boundingBox = obj.completeMesh.boundingBox;
        end
        
        function centroid = get.centroid(obj)
            centroid = obj.completeMesh.centroid;
        end
        
        function volume = get.volume(obj)           
            volume = obj.completeMesh.volume;
        end
        
        function mass = get.mass(obj)           
            meshes = [obj.mesh obj.getalldescendants.mesh];
            volumes = arrayfun(@(x) x.volume,meshes);
            bulkDensities = [obj.bulkDensity obj.getalldescendants.bulkDensity];
            mass = sum(volumes.*bulkDensities);
        end
        
        function centerOfMass = get.centerOfMass(obj)
            centerOfMass = calculatecenterofmass(obj);
        end
        
        function radiusOfGyration = get.radiusOfGyration(obj)
            radiusOfGyration = calculateradiusofgyration(obj);
        end 
        
        function nFractions = get.nFractions(obj)
            nFractions = numel(obj.fractions);
        end 
        
        function nChildren = get.nChildren(obj)
            nChildren = numel(obj.childList);
        end
        
    end
end

