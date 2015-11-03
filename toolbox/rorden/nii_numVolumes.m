function [nVol] = nii_numVolumes (imgName);
%returns number of volumes (timepoints, directions) in a NIfTI image
% imgName : name of source image 
%Examples
% nii_cropVolumes('img.nii'); %returns volumes in img.nii
if ~exist('imgName')
 imgName = spm_select(1,'image','Select 4D image to crop');
end
[pth,nam,ext,vol] = spm_fileparts( deblank (imgName));
imgName = fullfile(pth,[nam, ext]); %remove volume is 'img.nii,1' -> 'img.nii'
hdr = spm_vol([imgName]); 
nVol = length(hdr);
