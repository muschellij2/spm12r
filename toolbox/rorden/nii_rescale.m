function nii_rescale(V);
%Set image intensity range to -1000...1000
% approximate match for http://en.wikipedia.org/wiki/Hounsfield_scale
% V : image(s) to rescale
%Note this may result in some loss of precision for integer data
%  nii_rescale ('a.nii'); 
%  nii_rescale(strvcat('a.nii', 'b.nii')); 

newMin = -1000;
newMax = 1000;
if nargin<1, V = spm_select(inf,'image','Select image[s] to extract'); end
for i=1:size(V,1)
  filename = deblank(V(i,:));
	[pth nm ext] = spm_fileparts(filename);
	hdr = spm_vol(filename); % <- these are the actual SPM calls
	img = spm_read_vols(hdr); % <- these are the actual SPM calls
	img(isnan(img)) = 0; % SPM uses 'not a number' outside brain
	mx = max(img(:));
	mn = min(img(:));
	if (mx > mn)
		scale = (newMax-newMin)/(mx-mn);
        %by changing the header values we will no reduce precision
        hdr.pinfo(1) = hdr.pinfo(1) * scale; %adjust header slope
        hdr.pinfo(2) = hdr.pinfo(2) + newMin; %adjust header intercept
        %alternatively, we could save as 32-bit floating point, e.g. hdr.dt(1) = 16  uint8=2; int16=4; int32=8; float32=16; float64=64
		hdr.fname = fullfile(pth, ['h' nm ext]);  
		img = ((img-mn)*scale)+newMin;
		spm_write_vol(hdr,img);
	else
		fprintf('No variability in this image, unable to rescale %s\n',filename);	
	end;
end; %for each image