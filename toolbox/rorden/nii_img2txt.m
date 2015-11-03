function nii_img2text (V);
% Converts NIfTI image to (huge) text file - very wasteful of disk space
% V: Image[s] to convert
%
%Example
%  nii_img2text('brain.nii');
%  nii_img2text(strvcat('post.nii','pre.nii'));
 
if nargin <1 %no files
 V = spm_select(inf,'image','Select image[s] to convert to text');
end
format long %show higher precision
for i=1:size(V,1)
	ref = deblank(V(i,:));
    hdr = spm_vol(ref);
    img = spm_read_vols(hdr);
    d = size(img);
    [pth,nam,ext] = spm_fileparts(ref); 
    fid = fopen(fullfile(pth, [ nam '.txt']), 'w');
    for z = 1 : d(3) 
        	for y = 1 : d(2) 
            		for x = 1 : d(1)
                		fprintf(fid, '%d\t%d\t%d\t%g\n', x,y,z,img(x,y,z));
            		end;%for X
        	end;%for Y
	end;%for Z   
    fclose(fid);
end; % for each image