function [x] nii_temporalfilter(fnm, tr, saveToDisk);
%Input 4D image(s), output 3D descriptive statistics maps (mean, stdev, tsnr) 
% 
%Example: 
%  nii_temporalfilter('4d.nii'); 
%  nii_temporalfilter('4d.nii', 2.2); %TR=2.2sec
%  nii_temporalfilter('4d.nii', 2.2, false); %TR=2.2sec, don't save to disk


if nargin<1, fnm = spm_select(1,'image','Select 4D image for filtering'); end
if (nargin< 2) || (tr==0), tr = 1; fprintf('%s assuming TR (sample period is %f seconds.\n',which(mfilename),tr); end;
saveToDisk

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
    x=XYZV;
    %mnImg = mean(XYZV,4);
    %x=bsxfun(@minus,XYZV,mnImg);
    x = reshape(x,nX*nY*nZ,nV);
    x = detrend(x');
    x = reshape(x', nX, nY, nZ, nV);

else
    x=XYZV;
end;

if (true)
    x =permute(x,[4 1 2 3]); %make time first dimension
    rt = tr;
    filter=[0.01, 0.1]; %HighPass_LowCutoff=0.01Hz; LowPass_HighCutoff =0.1Hz 
    x=fft(x,[],1);
    f=(0:size(x,1)-1);
    f=min(f,size(x,1)-f);
    idx=find(f<filter(1)*(rt*size(x,1))|f>filter(2)*(rt*size(x,1)));
    idx=idx(idx>1);
    x(idx,:)=0;
    x=real(ifft(x,[],1));
    x=permute(x,[2 3 4 1]); %make time last dimension   
end

%if (doDetrend)
%    x=bsxfun(@plus,x,mnImg);
%end        




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
    spm_write_vol(hdr,x(:, :, :, vol));
end;

