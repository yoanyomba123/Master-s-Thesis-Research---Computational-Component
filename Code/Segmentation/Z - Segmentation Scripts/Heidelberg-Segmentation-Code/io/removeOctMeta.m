function removeOctMeta(filename, mode)
% REMOVEOCTMETA Removes the meta data information denoted by "mode" from meta
% data files.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Oktober 2012
% Revised comments: November 2015

fIn = [filename '.meta'];
fOut = [filename '.metaX'];

fidR = fopen(fIn, 'r');
fidW = fopen(fOut, 'wt');

removed = 0;

if fidR ~= -1
    line = fgetl(fidR);
    
    if strcmp(line, 'BINARY META FILE') % Binary meta file
        fprintf(fidW, '%s\n', line);
        modeTemp = 'temp';
        while ~feof(fidR) 
            [modeTemp, output] = binReadHelper(fidR);
            if numel(modeTemp) == 0
                break;
            end
            
            if strcmp(modeTemp, mode)
                removed = 1;
            else
                binWriteHelper(fidW, modeTemp, output);
            end
        end
    else % Text meta file
        while ischar(line)
            [des, rem] = strtok(line);
            if strcmp(des, mode)
                removed = 1;
            else
                fprintf(fidW, '%s\n', line);
            end
            line = fgetl(fidR);
        end
       
    end
    
    fclose(fidR);
end

fclose(fidW);

if ispc     
    movefile(fOut,fIn, 'f');
else
    movefile(fOut,fIn, 'f');
end
end

function binWriteHelper(fid, mode, data)
    fwrite(fid, uint32(numel(mode)), 'uint32');
    fwrite(fid, uint32(numel(data)), 'uint32');
    if ischar(data)
        fwrite(fid, 1, 'uint8');
        fwrite(fid, uint8(mode), 'uint8');
        fwrite(fid, uint8(data), 'uint8');
    else
        fwrite(fid, 0, 'uint8');
        fwrite(fid, uint8(mode), 'uint8');
        fwrite(fid, data, 'float64');
    end
end

function [mode, data] = binReadHelper(fid)
    numMode = fread(fid, 1, 'uint32');
    numData = fread(fid, 1, 'uint32');
    typeData = fread(fid, 1, 'uint8');
    
    if numel(numMode) == 0 || numel(numData) == 0 || numel(typeData) == 0
        mode = [];
        data = [];
        return;
    end
    
    mode = char(fread(fid, numMode, 'uint8'))';
    
    if typeData == 0
        data = fread(fid, numData, 'float64')';
    else
        data = char(fread(fid, numData, 'uint8'))';
    end
end
