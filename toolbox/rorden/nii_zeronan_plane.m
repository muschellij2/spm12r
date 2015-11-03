function ofNm = nii_zeronan_plane(ifNm,val)
% Voxels with NaN's are replaced with zero, output has 'z' prefix
%  ifNm : Input filename(s)
%  val : Value to set NaN's to (defaults to zero)
% Output:
%  ofNm  - Cell array of output filenames.
%
%This shows how to achieve this using 2D planes
% see nii_zeronan for using 3D volumes (simpler, uses more memory)
% http://blogs.warwick.ac.uk/nichols/entry/zero_nans_in/
% Thomas Nichols, 1 April 2011

if nargin<2, val = 0; end
if nargin<1, ifNm = spm_select(Inf,'image','Select images for NaN->0'); end

if ~iscell(ifNm)
  ifNm = cellstr(ifNm)';
else
  ifNm = ifNm(:)';
end

OtfNm = {};

for fNm = ifNm

  fNm = fNm{:};

  OfNm = ['z' fNm];
  [pth,nm,xt,vol] = spm_fileparts(fNm);
  OfNm = fullfile(pth,['z' nm xt]);

  % Code snippet from John Ashburner...
  VI       = spm_vol(fNm);
  VO       = VI;
  VO.fname = OfNm;
  VO       = spm_create_vol(VO);
  nNaN = 0;
  for i=1:VI.dim(3),
    img      = spm_slice_vol(VI,spm_matrix([0 0 i]),VI.dim(1:2),0);
    tmp      = find(isnan(img));
    
    nNaN = nNaN + length(tmp);
    img(tmp) = val;
    VO       = spm_write_plane(VO,img,i);
  end;
  fprintf('Number of not-a-number voxels %d \n', nNaN);
  OtfNm = {OtfNm{:} OfNm};

end


if nargout>0
  ofNm = OtfNm;
end