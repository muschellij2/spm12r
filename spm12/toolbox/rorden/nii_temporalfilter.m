function [filtImg] = nii_temporalfilter(fnm, tr, saveToDisk);
%Input 4D image(s), output 3D descriptive statistics maps (mean, stdev, tsnr) 
% 
%Example: 
%  nii_temporalfilter('4d.nii'); 
%  nii_temporalfilter('4d.nii', 2.2); %TR=2.2sec
%  nii_temporalfilter('4d.nii', 2.2, false); %TR=2.2sec, don't save to disk


if nargin<1, fnm = spm_select(1,'image','Select 4D image for filtering'); end
if (nargin< 2) || (tr==0), tr = 1; fprintf('%s assuming TR (sample period) is %f seconds.\n',which(mfilename),tr); end;
if (nargin< 3), saveToDisk= true; end;

HighPass_LowCutoff=0.01;%Hz; 
LowPass_HighCutoff =0.1;%Hz 
fprintf('%s TR=%f seconds, band pass filtering higher than %f Hz and lower than %f Hz.\n',which(mfilename),tr,HighPass_LowCutoff,LowPass_HighCutoff);

[pth nam ext vol] = spm_fileparts(fnm);
fnm = fullfile(pth, [nam ext]); %remove volume index 'vol' 
if (exist(fnm) == 0); fprintf('%s unable to find image %s\n',which(mfilename),fnm);  return; end;

hdr = spm_vol(fnm); %load 4D dataset only once!
[XYZV] = spm_read_vols(hdr);
[nX nY nZ nV] = size(XYZV);
if (nV < 2); fprintf('%s requires 4D volumes, %s is a 3D volume.\n',which(mfilename),fnm);  return; end;

%create a mask - only filter voxels that have variability...
%mask = ones (nX, nY, nZ);
%mask = std(XYZV,0,4);
%tmp      = find((mask)~= 0);
%mask(tmp) = 1;
%if (nnz(mask) == 0); fprintf('%s requires image brightness variability, unable to process %s\n',which(mfilename),fnm);  return; end;
%%to save mask...
%%VO = spm_vol([fnm ',1']); %clone 1st volume for output images
%%VO.fname = fullfile(pth, ['mask' nam ext]); 
%%spm_write_vol(VO,sdImg);

doDetrend = true;
if (doDetrend)
    filtImg=XYZV;
    %mnImg = mean(XYZV,4);
    %filtImg=bsxfun(@minus,XYZV,mnImg);
    filtImg = reshape(filtImg,nX*nY*nZ,nV);
    filtImg = detrend(filtImg');
    filtImg = reshape(filtImg', nX, nY, nZ, nV);

else
    filtImg=XYZV;
end;

if (true)
    filtImg =permute(filtImg,[4 1 2 3]); %make time first dimension
    rt = tr;
    %filter=[0.01, 0.1]; %HighPass_LowCutoff=0.01Hz; LowPass_HighCutoff =0.1Hz 
    filtImg=fft(filtImg,[],1);
    f=(0:size(filtImg,1)-1);
    f=min(f,size(filtImg,1)-f);
    idx=find(f<HighPass_LowCutoff*(rt*size(filtImg,1))|f>LowPass_HighCutoff*(rt*size(filtImg,1)));
    idx=idx(idx>1);
    filtImg(idx,:)=0;
    filtImg=real(ifft(filtImg,[],1));
    filtImg=permute(filtImg,[2 3 4 1]); %make time last dimension   
end

%if (doDetrend)
%    x=bsxfun(@plus,x,mnImg);
%end        


if (~saveToDisk), return; end;

hdr = spm_vol([fnm ',1' ]); %load 4D dataset only once!
hdr.fname   = fullfile(pth,['b' nam ext]);;
hdr.private.timing.toffset= 0;
hdr.private.timing.tspace= tr;
%next: save data as 32-bit real
hdr.dt(1) = 16; %make 32 bit real
hdr.private.dat.dtype = 'FLOAT32-LE';
hdr.private.dat.scl_slope = 1;
hdr.private.dat.scl_inter = 0;
hdr.pinfo(1) = 16; %make 32 bit real
for vol=1:nV
    hdr.n(1)=vol;
    spm_write_vol(hdr,filtImg(:, :, :, vol));
end;

