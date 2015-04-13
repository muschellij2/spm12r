function [outName] = nii_binary (imgName, thresh, zeroEdgeSlices);
%given source image create image where voxels < thresh are zero, and >= thresh are one
%  imgName : name of source image 
%  thresh  : threshold level
%  zeroEdgeSlices : if true, lowest and hightest 3rd of slices set to zero
%                   Useful for ASL images where edges may have unusual values
%Example
% nii_binary('c1t1.nii',0.5);
% nii_binary('c1t1.nii',0.5, true);


if ~exist('imgName')
 imgName = spm_select(1,'image','Select image to binarize');
end
if ~exist('thresh')
    prompt = {'Zero voxels less than :'};
    dlg_title = 'Threshold value';
    num_lines = 1;
    def = {'0.5'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    thresh = str2num(answer{1});
end;
if ~exist('zeroEdgeSlices')
    zeroEdgeSlices = false;
end;
[pth,nam,ext,vol] = spm_fileparts( deblank (imgName));
outName = fullfile(pth,['b', nam, ext]); %'b'inary
%load data...
hdr = spm_vol(imgName);
[img] = spm_read_vols(hdr);
%threshold data...
imgBin= zeros(size(img));
imgBin((img >= thresh)) = 1; 
if zeroEdgeSlices %next zero top and bottom 3rd
    z = size(imgBin,3);
    z3rd = floor(z /3);
    if z3rd > 0
        fprintf('Zeroing top and bottom slices of %s\n',outName);
        for sl = 1:z3rd
            imgBin(:,:,sl) = 0; %bottom slices
            imgBin(:,:,z-sl+1) = 0; %top slices
        end;
    end;
end;
hdr.fname   = outName;
spm_write_vol(hdr,imgBin);