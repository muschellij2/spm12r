function nii_thresh_hi (P, Thresh);
%Clip image intensity so no voxels brighter than Thresh
% Example - user prompted for threshold
%   nii_thresh_hi('C:\dir\img.nii');
% Example - all values greater than 0.5 are set to 0.5
%   nii_thresh_hi('C:\dir\img.nii', 0.5);


if nargin <1 %no files
 P = spm_select(inf,'image','Select images to threshold');
end;
if nargin <2 %no threshold
 YPos = 1;
 Thresh = 0.5;
 [Thresh , YPos] = spm_input('Threshold', YPos, 'r',Thresh);
end;

for i=1:size(P,1)
  ref = deblank(P(i,:));
  Vi  = spm_vol(strvcat(P(i,:)));
  VO       = Vi;
  [pth,nam,ext] = spm_fileparts(ref);
  VO.fname = fullfile(pth,['x' nam '.nii']);
  VO       = spm_create_vol(VO);
  clipped = 0;
  for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);
    %make NaNs into zeros
    tmp      = find(isnan(img));
    img(tmp) = 0;
    %apply threshold
    for px=1:length(img(:)),
      if img(px) > Thresh
        img(px) = Thresh;
        clipped = clipped + 1;
      end;
    end;
    VO       = spm_write_plane(VO,img,i);
 end;
 fprintf('%s had %d voxels >%f\n',VO.fname, clipped,Thresh); 	
end
