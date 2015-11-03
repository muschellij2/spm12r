function nii_mirror (V);
% Generates 3 images: right mirror, left mirror, mean of left+right 
% The first step is to align the image along its axis of symmetry
%   this step uses nii_align
% The second step generates the new images 
% Example
%   nii_mirror('C:\dir\img.nii');
% You can also pass multiple images - each will be mirrored
% Example - scans from participant 1 and 2
%  nii_mirror(strvcat('C:\dir\p1.nii','C:\dir\p2.nii'));

%in case no files specified
if nargin <1 %no files
 %V = 'C:\irate\test\CT.nii';
 V = spm_select(inf,'image','Select image to midline align');
end

for i=1:size(V,1)
 ref = deblank(V(i,:));
 [pth,nam,ext] = spm_fileparts(ref); 
 src = fullfile(pth,[nam ext]);
 if (exist(src ) ~= 2) 
 	fprintf('nii_mirror error: unable to find source image %s.\n',ref);
	return;  
 end;
 nii_midline(src,true);
 fname = fullfile(pth,['r' nam ext]);
 makesym(fname,1);
 makesym(fname,2);
 makesym(fname,3);
end; %for each image
return

%_______________________________________________________________________
function middle = makesym(fname, fx);
%makes a symmetrical image
%fx controls function
%  fx=1: create image with mirrorred left side
%  fx=2: create image with mirrorred right side
%  fx=3: create image where left is left+rightmirror and right is right+rightmirror

 if (exist(fname ) ~= 2) 
 	fprintf('nii_mirror error: unable to find midline-corrected source image %s.\n',ref);
	return;  
 end;
 Vi  = spm_vol([fname,',1']);
 if (Vi.dim(1) < 2) 
 	fprintf('nii_mirror error: image must be at least 2 voxels wide %s.\n',ref);
	return;  
 end;
 %load image header
 VO       = Vi;
 [pth,nam,ext] = spm_fileparts(fname);
 if fx==1
   VO.fname = fullfile(pth,['LL' nam '.nii']);
 elseif fx==2
   VO.fname = fullfile(pth,['RR' nam '.nii']);
 else
   VO.fname = fullfile(pth,['BB' nam '.nii']);
 end;
 VO       = spm_create_vol(VO);
 %create vector
 xvect=zeros(1,Vi.dim(1));
 xHalf = Vi.dim(1) / 2;
 %compute
 for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);
    for Yi=1:Vi.dim(2),
  	px = (Yi-1)*Vi.dim(1);
  	for Xi=1:Vi.dim(1),
  	 if fx==1 %left mirror
       if Xi <= xHalf
       	xvect(Xi) = img(px+Xi);
       else
       	xvect(Xi) = img(px+Vi.dim(1)-Xi+1);
       end;
  	 elseif fx==2 %right mirror
       if Xi >= xHalf
       	xvect(Xi) = img(px+Xi);
       else
       	xvect(Xi) = img(px+Vi.dim(1)-Xi+1);
       end;
   	else %combine both sides
    	  xvect(Xi) = (img(px+Xi)+img(px+Vi.dim(1)-Xi+1))/2;
   	end;
    end; %for dim(1) = X
  	for Xi=1:Vi.dim(1),
       img(px+Xi) = xvect(Xi);
     end; %for dim(1) = X

    end; %for dim(2) = Y
    VO       = spm_write_plane(VO,img,i);
 end; %for dim(3) = Z

return;
%_______________________________________________________________________