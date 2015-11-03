function [Data, Head] = rest_ReadNiftiImage(imageIN, volumeIndex)
% Read file(NIFTI, ...) for REST by CHEN Gui-Wen and YAN Chao-Gan
% %------------------------------------------------------------------------
% Read MRI image file (imageIN) with format of Nifti 1.1. It will return data
% of 3D matrix (Data) and infomation of the header (Head). Please set the volume
% index (1 for the first volume) you want to load into memory if the image file
% contains 4D data. The structure of header (Head) is the same with SPM5.
%
% Usage: [Data, Head] = rest_ReadNiftiImage(imageIN, volumeIndex)
%
% Input:
% 1. imageIN - the path and filename of image file, [path\*.img]
% 2. volumeIndex- the volume of 4D data to read, can be 1,2,..., not larger than
%             the number of total volumes, default: 'all' means read all
%             the time points.
% Output:
% 1. Data - 3D matrix of data
% 2. Head - a structure containing image volume information
% The elements in the structure are:
%       Head.fname - the filename of the image.
%       Head.dim   - the x, y and z dimensions of the volume
%       Head.dt    - A 1x2 array.  First element is datatype (see spm_type).
%                 The second is 1 or 0 depending on the endian-ness.
%       Head.mat   - a 4x4 affine transformation matrix mapping from
%                 voxel coordinates to real world coordinates.
%       Head.pinfo - plane info for each plane of the volume.
%              Head.pinfo(1,:) - scale for each plane
%              Head.pinfo(2,:) - offset for each plane
%                 The true voxel intensities of the jth image are given
%                 by: val*Head.pinfo(1,j) + Head.pinfo(2,j)
%              Head.pinfo(3,:) - offset into image (in bytes).
%                 If the size of pinfo is 3x1, then the volume is assumed
%                 to be contiguous and each plane has the same scalefactor
%                 and offset.
%        Head.private - a structure containing complete information in the header
% %------------------------------------------------------------------------
% Copyright (C) 2007 Neuroimage Computing Group, State Key Laboratory of
% Cognitive Neuroscience and Learning
% Guiwen Chen, gwenchill@gmail.com
% @(#)rest_ReadNiftiImage.m  ver 2.0, 07/11/24
% %------------------------------------------------------------------------
% Revised by YAN Chao-Gan 080621
% Last Revised by YAN Chao-Gan 110911. Read all volumes for a 4d .nii dataset.
% ycg.yan@gmail.com

if ~exist('volumeIndex', 'var')
    volumeIndex='all';
end

% get the SPM path
FilePath = which('rest.m');
[RESTPath, fileN, extn] = fileparts(FilePath);
spmPath = fullfile(RESTPath, 'rest_spm5_files');

addpath(spmPath);

% try
    % %     cd(spmPath);  %Revised by YAN Chao-Gan
%     filename=imageIN;
%     %Added by YAN Chao-Gan
%     if length(filename)>4
%         if strcmpi(filename(end-3:end), '.hdr')
%             filename = filename(1:end-4);
%             filename=[filename,'.img'];
%         end
%     end

    %YAN Chao-Gan, 120822. Add the support for .nii.gz files.
    [pth,nam,ext] = fileparts(imageIN);
    switch ext
        case {'.img','.hdr'}
            filename = fullfile(pth,[nam '.hdr']);
        case {'.nii'}
            filename = fullfile(pth,[nam '.nii']);
        case {'.gz'}  % 
            gunzip(imageIN);
            filename = fullfile(pth,[nam]);
        otherwise
            filename = fullfile(pth,[nam '.nii']);
            if ~exist(filename,'file')
                filename = fullfile(pth,[nam '.hdr']);
            end
    end;
    
    if ~exist(filename,'file')
        error(['File doesn''t exist: ',filename]);
    end
    

    % construct the file name
    [pathstr, fName, extn] = fileparts(deblank(filename));

    if isempty(pathstr)
        filename = strcat(pwd, filesep, filename);
    end

    % Get info of header
    V = rest_spm_vol(filename);

    % Initialise data
    Data = zeros([V(1).dim(1:3), 1]);

    if(~strcmpi(volumeIndex,'all'))  %YAN Chao-Gan 110911 added. Read all volumes for a 4d .nii dataset.
        if(volumeIndex>length(V))
            error('The volume is error, please set the right volume to read');
        end
        Data(:, :, :,1) = rest_spm_read_vols(V(volumeIndex));
        Head=V(volumeIndex); % save Header info in structure
    else
        Data = rest_spm_read_vols(V);
        Head=V(1); % save Header info in structure (just the first volume)
    end

    % replace NaN with zero
    Data(isnan(Data)) = 0;

    clear V;
    rmpath(spmPath);
    
    if (length(imageIN)>7) && strcmpi(imageIN(end-6:end), '.nii.gz')  %YAN Chao-Gan, 111111. Delete the uncompressed version after reading for .nii.gz file. %YAN Chao-Gan, 120525. Fixed a bug for file name length.
        delete(filename);
    end
    
% catch
%     rmpath(spmPath);
%     rest_Fix_Read_Write_Error; %YAN Chao-Gan, 100426.
%     error('Meet error while reading data. 1) Please ensure there is NO space or Chinese character in the file path; Or 2) Please restart MATLAB, and run "rest_Fix_Read_Write_Error" before starting REST.');
% end

