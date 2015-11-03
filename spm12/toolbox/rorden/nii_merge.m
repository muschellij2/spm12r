function nii_merge (P);
%Given a series of images, creates a single 3D volume
% 0: voxels not >0.5 in any image
% 1: voxel >0.5 in image 1
% 2: voxel >0.5 in image 2
%  ....
%
%Example
%  nii_merge(strvcat('./j/ec1S0815.nii','./j/ec2S0815.nii','./j/ec3S0815.nii','./j/ec4S0815.nii','./j/ec5S0815.nii'));

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to merge');
end;

    oh = deblank(P(1,:));
    [pth,nam,ext] = spm_fileparts(oh);
    oh = spm_vol(oh); %output header
    o = spm_read_vols(oh);%Output image
    oh.fname = fullfile(pth,['mx',  nam, ext]);
    oh.pinfo(1)=1; %set scale header
    o(:) = 0; %voxels will be zero unless >0.5 in one of the input volumes...
    num = size(P,1);
    for n=1:num
        ih = deblank(P(n,:));
        ih = spm_vol(ih); %input header
        i = spm_read_vols(ih);%Input image
        tmp      = find((i>0.499999));
        o(tmp)  = n;
    end;
    %save results...
    spm_write_vol(oh,o);
