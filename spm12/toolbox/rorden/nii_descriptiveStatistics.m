function [stats] = nii_descriptiveStatistics (imgName, maskName);
%input: provided with continous image (imgName) and binary mask(s)
%output: mean and stand
% imgName  : continous image
% maskName : binary masking image(s)
%Examples
% nii_descriptiveStatistics('beta.nii','mask1.nii')
% nii_descriptiveStatistics('beta.nii',strvcat('mask1.nii','mask2.nii'))
if ~exist('imgName')
 imgName = spm_select(1,'image','Select continous image');
end
if ~exist('maskName')
 maskName = spm_select(inf,'image','Select binary mask(s)');
end
hdr = spm_vol([imgName]); 
[img] = spm_read_vols(hdr);
nMask = length(maskName(:,1));
stats = zeros(3,nMask);
for m = 1 : nMask
    msk = deblank (maskName(m,:));
    mhdr = spm_vol([msk]); 
    [mimg] = spm_read_vols(mhdr);
    if (size(img) ~= size(mimg)), fprintf('%s error: dimensions of %s do not match %s\n',mfilename,msk,imgName); end;
    vox = img(mimg ~= 0);
    sd = std(vox(:));
    mn = mean(vox(:));
    stats(1,m) = mn; %mean
    stats(2,m) = sd; %standard deviation
    stats(3,m) = length(vox); %number of voxels in mask
    fprintf('%d\tvoxels from %s masked by %s have mean=\t%f\tstdev=\t%f\n',length(vox),imgName, msk,mn,sd);
end;