function nii_midline (V, save_reslice);
% This script attempts to align scan along midline
% Example
%   nii_midline('C:\dir\img.nii');
% You can also pass multiple images and the FIRST is used for the computation with transforms applied to all
%  This keeps images in register
% Example - T1 scan and fMRI from same session
%  nii_midline(strvcat('C:\dir\T1.nii','C:\dir\fmri.nii'));
% Example - T1 scan and Lesion map
%  nii_midline(strvcat('C:\dir\T1.nii','C:\dir\lesion.nii'));
% By default, only the headers are changed (reslicing is lossy). You can force a reslice:
%  nii_midline('C:\img.nii',true);
%  
%This code was adapted for SPM8 by Chris Rorden
%Original source:
%  Enantiomorphic normalization of focally lesioned brains.
%  Nachev P, Coulthard E, Jäger HR, Kennard C, Husain M.
%  Neuroimage. 2008 39(3):1215-26. PMID: 18023365


%in case no files specified
if nargin <1 %no files
 %V = 'C:\irate\spm8\chrisr.nii';
 V = spm_select(inf,'image','Select image to midline align');
end

if nargin <2 %only change matrix by default
 save_reslice = false;
end

%extract filename 
[pth,nam,ext] = spm_fileparts(deblank(V(1,:)));
fname = fullfile(pth,[nam ext]);

%report if filename does not exist...
if (exist(fname) ~= 2) 
 	fprintf('Error: unable to find image %s.\n',fname);
	return;  
end;

fhead = spm_vol([fname,',1']); 
fdata = spm_read_vols(fhead); 
     
%flip image 
fdata_flip=flipdim(fdata,1); 
fhead_flip=fhead; 
fhead_flip.descrip='pn_flipt'; 
[pth,nam,ext] = spm_fileparts(fname);
fhead_flip.fname = fullfile(pth,['flip' nam ext]);
%previous code set pinfo, but this caused problems, e.g. SPM8 template images with no scaling factors
%best leave pinfo blank and let spm_write_vol calculate
%to set pinfo for SPM5 and later [don't change offset for NII files]
%fhead_flip.pinfo(1)=1; 
%to set pinfo for SPM2
% fhead_flip.pinfo=[1;0;0];
spm_write_vol(fhead_flip,fdata_flip); 

fflip = spm_vol([fhead_flip.fname,',1']); 
     
x  = spm_coreg(fflip,fhead); 
x  = (x/2); 
%M = spm_matrix(x);
M  = inv(spm_matrix(x)); 
MM = zeros(4,4,2); 

%read initial matrix
for j=1:size(V,1),
         MM(:,:,j) = spm_get_space(deblank(V(j,:)));
end;
%write transformed matrix
for j=1:size(V,1),
          spm_get_space(deblank(V(j,:)), M*MM(:,:,j));         
end;


%'mean',1, if you want a symmetrical image (left and right side averaged
%'mean',0, if you only want a resliced image
%'which',1, because we are not interested in reslicing the flipped image
if save_reslice
 def_flags = struct('interp',1,'mask',1,'mean',1,'which',1,'wrap',[0 0 0]','prefix','r');
 spm_reslice(strvcat(fhead_flip.fname,fname),def_flags); 
end;

%you can delete the flipped file...
  nii_delete(fhead_flip.fname);

