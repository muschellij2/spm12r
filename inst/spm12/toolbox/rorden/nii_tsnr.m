function nii_tsnr(V);
%Input 4D image(s), output 3D descriptive statistics maps (mean, stdev, tsnr) 
%  % V : name(s) of 4D image[s] (optional) 
%create 'Temporal Signal-to-Noise Ratio' Image: TSNR=mean/stdev image
% http://practicalfmri.blogspot.com/2011/01/comparing-fmri-protocols.html
% http://www.ncbi.nlm.nih.gov/pubmed/17126038
%Example: 
%  nii_tsnr('4d.nii'); 
%  nii_tsnr(strvcat('4d.nii','4dxs.nii'));

if nargin<1, V = spm_select(inf,'image','Select 4D image[s] to compute TSNR'); end

for i=1:size(V,1)
    fnm = deblank(V(i,:)); %filename for this image
    %fnm = nii_ungz(fnm); %optional: decompress .voi/nii.gz to .nii files
    [pth nam ext vol] = spm_fileparts(fnm);
    fnm = fullfile(pth, [nam ext]); %remove volume index 'vol' 
    if (exist(fnm) == 0); fprintf('%s unable to find image %s\n',which(mfilename),fnm);  return; end;
    %VO = spm_vol(fullfile(pth, [nam ext ',1'])); %clone 1st volume for output images
    VO = spm_vol([fnm ',1']); %clone 1st volume for output images
    
    hdr = spm_vol(fnm); %load 4D dataset only once!
    [XYZV] = spm_read_vols(hdr);
    [nX nY nZ nV] = size(XYZV);
    if (nV < 2); fprintf('%s requires 4D volumes, %s is a 3D volume.\n',which(mfilename),fnm);  return; end;
    
    %Create Mean Image
    mnImg = mean(XYZV,4);
    VO.fname = fullfile(pth, ['mn' nam ext]); 
    spm_write_vol(VO,mnImg);

    %Create Standard Deviation Image
    sdImg = std(XYZV,0,4);
    VO.fname = fullfile(pth, ['sd' nam ext]); 
    spm_write_vol(VO,sdImg);

    %create TSNR
    tsnrImg = mnImg ./ sdImg;
    VO.fname = fullfile(pth, ['snr' nam ext]); 
    spm_write_vol(VO,tsnrImg);

    % mean- exclude NaN and zeros (TSNR never negative)
    index = tsnrImg(:)>0;
    n = sum(index(:));
    tot = sum(tsnrImg(index));
    mn = tot/n;
    fprintf('mean tSNR (meaningful for scalp stripped images only) for %s is %f\n',fnm,mn);
end;