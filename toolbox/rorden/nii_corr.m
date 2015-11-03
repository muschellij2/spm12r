function nii_corr(IMGname, MeanSignal);
%Creates image showing how well voxels in IMGname correlate with MeanSignal
%  IMGname : NIfTI image to examine,  4D  
%  MeanSignal: Timecourse to be matched
% Outputs correlation image with 'cX' prefix, where X is the Region of interesst
%      e.g. img.nii -> cqimg.nii
%Example 1: compute timecourse in region of interest, compute voxelwise correlation
%  meansig = nii_timecourse_roi('rest_filt.nii','lfrontal.nii');
%  nii_corr('rest_filt.nii', meansig);
%Example 2: multiple regions of interest
%  meansig = nii_timecourse_roi('rest_filt.nii',strvcat('lfrontal.nii','rfrontal.nii')); %two regions 
%  nii_corr('rest_filt.nii', meansig); %will one correlation map for each region (c1, c2)

[nT nR] = size(MeanSignal); %number of timepoints, number of regions
if (nT < 1); fprintf('Input signal must have multiple observations.\n');  return; end;


if (exist(IMGname) == 0); fprintf('%s unable to find image %s\n',which(mfilename),IMGname);  return; end;
IMGname = nii_ungz(IMGname); %optional: decompress .voi/nii.gz to .nii files

%load 4D dataset only once!
hdr = spm_vol(IMGname);
[XYZV] = spm_read_vols(hdr);
[nX nY nZ nV] = size(XYZV);
if (nT ~= nV); fprintf('Image %s should be 4D image with %d observations.\n',IMGname, nT);  return; end;

%create 3D image
[pth nam ext vol] = spm_fileparts(IMGname);
VO = spm_vol(fullfile(pth, [nam ext ',1'])); %only 1st volume!
Oimg = spm_read_vols(VO); %output image

VoxSignal = zeros(nV, 1);


%note: currently written for minimal memory footprint and easy coding
%        However: identical VoxSignal computed for EACH region of interest
%        Therefore, could be written to be much faster 

for r=1:nR %for each region
    VO.fname = fullfile(pth, ['c' int2str(r) nam ext]);  
    Oimg(:) = 0;
    for z=1:nZ,
        for y=1:nY,
            for x= 1:nX,
                for v = 1 : nV %for each volume
                    VoxSignal(v) = XYZV(x,y,z,v);
                end; %for each volume
                if (min(VoxSignal(:)) ~= max(VoxSignal(:)) ) %only examine voxels with signal variability
                    correl =corrcoef(VoxSignal,MeanSignal(:,r));
                    Oimg(x,y,z) = correl(1,2); 
                end; %if signal variability
            end; %z
        end; %y
    end; %x
    spm_write_vol(VO,Oimg);
end; %for each region
