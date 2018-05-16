function [pcaParamsFull, pcaParamsLess, distances] = pcaEvaluation(DataDescriptors, Layers, Additional, Features, less)
% Compute the pca eigen vectors on all the data and a randomly selected
% percentage of it, defined by the parameter "less".
% For all other parameters, see the documentation of 
% generateFeaturesBScan (...).
% Outputs are:
% pcaParamsFull: The pcaParams (EVectors and Values, for both all and
%                Normal classes, if inputs configured properly) of ALL
%                the data.
% pcaParamsLess: Same computation as pcaParamsFull, but with a randomly
%                selected subset.
% distances: For all layers, the first column contains the euclidian
%            distances of the PCA EVectors Full to Less on all the data, 
%            the second column on normal data only.
%           


octsegConstantVariables;

featureCollection = cell(0,1);
dataAll = cell(1, 1);
validCount = 1;
classes = [];
age = [];

% Load the layer thickness data and the additional information
if(DataDescriptors.featureDataLoaded)
    dataAll = DataDescriptors.FeatureData.dataAll;
    classes = DataDescriptors.FeatureData.classes;
    age = DataDescriptors.FeatureData.age;
else
    for i = 1:numel(DataDescriptors.filenameList)
        [numDescriptor, openFuncHandle] = examineOctFile(DataDescriptors.pathname, ...
            [DataDescriptors.filenameList{i} DataDescriptors.filenameEnding]);
        if numDescriptor == 0
            disp([DataDescriptors.pathname DataDescriptors.filenameList{i} ': File is no OCT file.']);
            continue;
        end
        Header = ...
            openFuncHandle([DataDescriptors.pathname DataDescriptors.filenameList{i} DataDescriptors.filenameEnding], 'header');
        
        class = loadClass(DataDescriptors.pathname, DataDescriptors.filenameList{i}, Features);
        if numel(class) == 0
            disp(['No Class data for ' DataDescriptors.filenameList{i} '! Skipping!']);
            continue;
        end
        adder = loadAdditional(DataDescriptors.pathname, DataDescriptors.filenameList{i}, Header, Additional);
        data = loadLayers(DataDescriptors.filenameList{i}, Header, DataDescriptors, Layers, Features);
        
        featureCollection{validCount, 1} = adder;
        featureCollection{validCount, 2} = class;
        classes(validCount) = class;
        dataAll{validCount} = data;
        age(validCount) = calculateAge(Header);
       
        validCount = validCount + 1;
    end
end

if Features.ageNormalize
    dataAll = thicknessAgeNormalize(dataAll, age, classes, Features.ageNormalClass, Features.ageNormalizeSamples, Features.ageNormalizeRefAge);
end

[pcaCoeffsAll, eigenValues] = calculatePCACoeffs(dataAll, classes, Features.pcaAllClasses, Features.numSamplesPCA, 1.0);
pcaParamsFull.eigenValuesAll = eigenValues;
pcaParamsFull.coeffsAll = pcaCoeffsAll;

[pcaCoeffsNormal, eigenValues] = calculatePCACoeffs(dataAll, classes, Features.pcaNormalClasses, Features.numSamplesPCA, 1.0);
pcaParamsFull.eigenValuesNormal = eigenValues;
pcaParamsFull.coeffsNormal = pcaCoeffsNormal;

[pcaCoeffsAll, eigenValues] = calculatePCACoeffs(dataAll, classes, Features.pcaAllClasses, Features.numSamplesPCA, less);
pcaParamsLess.eigenValuesAll = eigenValues;
pcaParamsLess.coeffsAll = pcaCoeffsAll;

[pcaCoeffsNormal, eigenValues] = calculatePCACoeffs(dataAll, classes, Features.pcaNormalClasses, Features.numSamplesPCA, less);
pcaParamsLess.eigenValuesNormal = eigenValues;
pcaParamsLess.coeffsNormal = pcaCoeffsNormal;

distances = cell(size(dataAll{1}, 1),2);
for i = 1:size(dataAll{1}, 1)
    distances {i,1} = zeros (1,Features.numSamplesPCA);
    for s = 1:Features.numSamplesPCA
        dist1 = norm (pcaParamsFull.coeffsAll {i} (:,s) - pcaParamsLess.coeffsAll {i} (:,s), 2);
        dist2 = norm (pcaParamsFull.coeffsAll {i} (:,s) + pcaParamsLess.coeffsAll {i} (:,s), 2);
        distances {i,1} (s) = min(dist1, dist2);
        if distances {i,1} (s) == dist2
            pcaParamsLess.coeffsAll {i} (:,s) = - pcaParamsLess.coeffsAll {i} (:,s);
        end
    end
end
for i = 1:size(dataAll{1}, 1)
    distances {i,2} = zeros (1,Features.numSamplesPCA);
    for s = 1:Features.numSamplesPCA
        dist1 = norm (pcaParamsFull.coeffsNormal {i} (:,s) - pcaParamsLess.coeffsNormal {i} (:,s), 2);
        dist2 = norm (pcaParamsFull.coeffsNormal {i} (:,s) + pcaParamsLess.coeffsNormal {i} (:,s), 2);
        distances {i,2} (s) = min (dist1, dist2);
        if distances {i,1} (s) == dist2
            pcaParamsLess.coeffsNormal {i} (:,s) = - pcaParamsLess.coeffsNormal {i} (:,s);
        end
    end
end


end

%%%%%%%%%%%%%HELPER FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [coeffs, eigenValues] = calculatePCACoeffs(dataAll, classes, validClasses, samples, percent)
    coeffs = cell(0,1);
    eigenValues = cell(0,1);
    
    valid = false(size(classes));
    for i = 1:numel(validClasses)
        validAdder = classes == validClasses(i);
        valid = valid | validAdder;
    end

    dataAll = dataAll(valid);
    
    if percent ~= 1.0
        probSize = numel(dataAll) * percent;
        dataAll = dataAll(randperm(numel(dataAll), floor(probSize)));
    end
    
    for i = 1:size(dataAll{1}, 1)
        data = zeros(numel(dataAll), samples);
        for k = 1:numel(dataAll)
            data(k, :) = featureMeanSections(dataAll{k}(i,:), samples);
        end
        
        % The following code had to be replaced, as it does not work
        % with matlab 2012b anymore (uups, that was just a path problem 
        % - strptool mirrors come of the matlab function (pca) -
        % Move strptool path to the end.
        [coeffs{i}, ~, eigenValues{i}] = princomp(data);
        
        % Replacement:
        % [coeff,~,latent] = pca(data', 0);
        % coeffs{i} = coeff;
        % eigenValues{i} = latent; 
    end
end

function data = loadLayers(filename, Header, DataDescriptors, Layers, Features)
    if Features.onlyAuto
        tag = 'autoData';
    else
        tag = 'bothData';
    end
    
    if Layers.retina
        ilm = readData(getMetaTag('INFL', tag),DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        rpe = readData(getMetaTag('RPE', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ilm) == numel(rpe)
            data = (rpe - ilm) * Header.ScaleZ * 1000;
        end
    end
    
    if Layers.rnfl 
        ilm = readData(getMetaTag('INFL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        onfl = readData(getMetaTag('ONFL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ilm) == numel(onfl)
            if numel(data) == 0
                data = (onfl - ilm) * Header.ScaleZ * 1000;
            else
                data = [data; (onfl - ilm) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.ipl 
        ipl = readData(getMetaTag('IPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        onfl = readData(getMetaTag('ONFL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ipl) == numel(onfl)
            if numel(data) == 0
                data = (ipl - onfl) * Header.ScaleZ * 1000;
            else
                data = [data; (ipl - onfl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.opl 
        ipl = readData(getMetaTag('IPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        opl = readData(getMetaTag('OPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(ipl) == numel(opl)
            if numel(data) == 0
                data = (opl - ipl) * Header.ScaleZ * 1000;
            else
                data = [data; (opl - ipl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.onl 
        icl = readData(getMetaTag('ICL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        opl = readData(getMetaTag('OPL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(icl) == numel(opl)
            if numel(data) == 0
                data = (icl - opl) * Header.ScaleZ * 1000;
            else
                data = [data; (icl - opl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.rpe 
        icl = readData(getMetaTag('ICL', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        rpe = readData(getMetaTag('RPE', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(icl) == numel(rpe)
            if numel(data) == 0
                data = (rpe - icl) * Header.ScaleZ * 1000;
            else
                data = [data; (rpe - icl) * Header.ScaleZ * 1000];
            end
        end
    end
    
    if Layers.bv
        bv = readData(getMetaTag('Blood Vessels', tag), DataDescriptors.pathname, filename, DataDescriptors.evaluatorName);
        if numel(data) == 0
            data = bv;
        else
            data = [data; bv];
        end
    end
    
    if Features.normFocus
        data = data * Header.ScaleX;
    end
end

function adder = loadAdditional(~, filename, Header, Additional)
    adder = cell(0,1);
    adderCount = 1;
    if Additional.filename
        adder{adderCount} = filename;
        adderCount = adderCount + 1;
    end
    
    if Additional.age    
        adder{adderCount} = calculateAge(Header);
        adderCount = adderCount + 1;
    end
    
    if Additional.patientID
        adder{adderCount} = deblank(Header.PatientID);
    end
end

function class = loadClass(pathname, filename, Features)
    class = readOctMeta([pathname filename], Features.class);
    class = round(class);
end

function data = readData(tags, pathname, filename, evaluatorName)
    tagMan = [];
    if numel(tags) == 2 && iscell(tags)
        tagAuto = tags{1};
        tagMan = tags{2};
    else
        if iscell(tags)
            tagAuto = tags{1};
        else
            tagAuto = tags;
        end
    end
    
    data = [];
    if numel(tagMan) ~= 0
        data = readOctMeta([pathname filename], [evaluatorName tagMan]);
    end
    if numel(data) == 0
        data = readOctMeta([pathname filename], [evaluatorName tagAuto]);
    end
end

