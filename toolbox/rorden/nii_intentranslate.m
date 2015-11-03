function nii_intentranslate (P, Thresh);
% Values translated so Thresh = 0, values less than Thresh are set to 0
%  P: Image[s] to translate
%  Thresh: Voxels intensity translated so this value is zero, darker voxels zeroed.
% Example - all values greater below 0.5 set to zero, intensities translated so 0.5-> 0.0
%   nii_intentranslate ('C:\dir\img.nii', 0.5);

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to translate');
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
  
    for px=1:length(img(:)),
      img(px) = img(px)-Thresh;
      if img(px) < 0
        img(px) = 0;
        clipped = clipped + 1;
      end;
    end;
    VO       = spm_write_plane(VO,img,i);
 end;
 fprintf('%s had %d voxels <%f\n',VO.fname, clipped,Thresh); 	
end
