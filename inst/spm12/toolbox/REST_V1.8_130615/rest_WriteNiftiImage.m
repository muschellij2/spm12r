function [flag] = rest_WriteNiftiImage(Data,Head,imageOUT)
% Write file(NIFTI, ...) for REST by CHEN Gui-Wen and YAN Chao-Gan
% %------------------------------------------------------------------------
% Write data (Data) with a specified header (Head) into a image file with format 
% of Nifti 1.1. The data (Data) should be 3D matrix, the header (Head) should 
% be a structure the same as SPM5. If the filename (imageOUT) is with 
% extra name as '.img', then it will generate two files (header and
% data seperately), or else, '.nii', it will generate single file with
% header 
% and data together.
%
% Usage: [flag] = rest_WriteNiftiImage(Data,Head,imageOUT)
%
% Input:
% 1. Data -  Data of 3D matrix to write
% 2. Head - a structure containing image volume information, the structure
%    is the same with a structure have read
%    The elements in the structure are:
%       Head.fname - the filename of the image. If the filename is not set, 
%                    just use the parameter.
%       Head.vox - A 1x3 array. It is the size of a voxel. (Must)
%       Head.origin - A 1x3 array. It is the origin of coordinate. (Must)
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
%              The scale and intercept will be changed according to the
%              data to write
% 3. imageOUT - the path and filename of image file to output [path\*.img or *.nii]
% Output:
% 1. flag - a flag for all done, 1: successful, 0: fail
% %------------------------------------------------------------------------
% Copyright (C) 2007 Neuroimage Computing Group, State Key Laboratory of
% Cognitive Neuroscience and Learning
%
% Guiwen Chen, gwenchill@gmail.com
% @(#)rest_WriteNiftiImage.m  ver 2.0, 07/11/21
% %------------------------------------------------------------------------
% Revised by YAN Chao-Gan 080621
% Last Revised by YAN Chao-Gan 120814. Set the default writing format into .nii.
% ycg.yan@gmail.com

% get the SPM path to use
FilePath = which('rest.m');
[giftPath, fileN, extn] = fileparts(FilePath);
spmPath = fullfile(giftPath, 'rest_spm5_files');
oldDir = pwd;
addpath(spmPath);

try
%     cd(spmPath); 
    [pth,nam,ext] = fileparts(imageOUT);  %%Added by YAN Chao-Gan
    if isempty(ext)
        imageOUT=[imageOUT,'.nii'];
    end


    V=Head;
    
    %construct the file name and path
    if(~exist('imageOUT','var'))
      if(~isfield(Head,'fname')),
        fName=Head.fname;
      end
    else
      fName=imageOUT;
    end
    %fName=imgPath;
    if isempty(fileparts(fName))
        fName = fullfile(oldDir, fName);
    end
     V.fname=fName;

    rest_spm_write_vol(V, Data);

    clear V;    
    flag=1;% Successful
    rmpath(spmPath);
%     cd(oldDir);
catch
   rmpath(spmPath);
   rest_Fix_Read_Write_Error; %YAN Chao-Gan, 100426.
   flag=0;% fail
%    cd(oldDir);
   error('Meet error while writing data. 1) Please ensure there is NO space or Chinese character in the file path; Or 2) Please restart MATLAB, and run "rest_Fix_Read_Write_Error" before starting REST.');
end

