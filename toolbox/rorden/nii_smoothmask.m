function oname = nii_smoothmask (P);
% Creates dilated binary lesion mask for an image with prefix 'dx'
%new filename returned
% Example
%   nii_smoothmask ('C:\ct\script\xwsctemplate_final.nii');

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to smooth');
end;

for i=1:size(P,1)
  ref = deblank(P(i,:));
  ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  src = fullfile(pth,[ nam ext]);
  smth =fullfile(pth,['s' nam ext]);
  spm_smooth(src,smth,8,16); 
  %last  uint8=2; int16=4; int32=8; float32=16; float64=64
  Vi  = spm_vol(smth);
  VO       = Vi;
  [pth,nam,ext] = spm_fileparts(ref);
  VO.fname = fullfile(pth,['x' nam ext]);
  VO       = spm_create_vol(VO);
  clipped = 0;
  thresh = 0.001;
  for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);

    for px=1:length(img(:)),
      if img(px) < thresh
        img(px) = 0;
        clipped = clipped + 1;
      else
        img(px) = 1;
      end;
    end;
    VO       = spm_write_plane(VO,img,i);
 end;
 %thresholding done - delete the raw smoothed data
 nii_delete(smth);
 %next downsample to 8 bit [optional]
 nii_8bit (VO.fname);
 nii_delete(VO.fname);
 nii_rename(fullfile(pth,['dx' nam ext]),VO.fname);
 %
 fprintf('SmoothMask: %s had %d voxels >%f\n',VO.fname, clipped,thresh); 
 oname = VO.fname;
end