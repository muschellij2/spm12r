function OK = nii_mask(ifNm, mfNm, thresh, val)
%Masks ifNm with mfNm: values <=Thresh in mfNm are set to val in ifNm
% if a voxel in the mask is less than thresh corresponding voxel in input is set to val% ifNm   - Input filename
% mfNm   - Mask filename
% thresh - Change voxels darker than this in the template image 
% val    - Value to set dark voxels to
%
% Output:
% OK  - number of images masked
%
%Example
%  mask('~/c1head_1.nii','~/aTPM.nii,1');

if nargin<1, ifNm = spm_select(Inf,'image','Select images for masking'); end
if nargin<2, mfNm = spm_select(1,'image','Select mask'); end
if nargin<3, thresh = 0.025; end
if nargin<4, val = 0; end

OK = 0;

VM       = spm_vol(mfNm);
vol = size(VM);
if vol(1) > 1 
    disp('Error: mask has multiple volumes, please explicitly specify masking volume, e.g. ''~/tpm.nii,1'' ');
    return;
end;
for j=1:size(ifNm,1)  
  fNm = deblank(ifNm(j,:));
  [pth,nm,xt, vol] = spm_fileparts(fNm);
  OfNm = fullfile(pth,['m' nm xt]);
  VI       = spm_vol(fNm);
  if VI.dim ~= VM.dim
    disp('mask and source must have same dimensions!');
    break; 
  end;

  VO       = VI;
  VO.fname = OfNm;
  VO       = spm_create_vol(VO);
  clipped = 0;
  for i=1:VI.dim(3),
    mask      = spm_slice_vol(VM,spm_matrix([0 0 i]),VM.dim(1:2),0);
    img      = spm_slice_vol(VI,spm_matrix([0 0 i]),VI.dim(1:2),0);
    for px=1:length(img(:)),
      if mask(px) > thresh
  	%this way we detect < and NaN...
      else
        clipped = clipped + 1;
        img(px) = val;
      end;  %if thresh
    end; %for each pixel
    VO       = spm_write_plane(VO,img,i);

  end;
    fprintf('Mask: %s had %d voxels set to %f because they were less then %f in %s\n',VO.fname, clipped,val,thresh,VM.fname); 
  OK= OK+1;

end
