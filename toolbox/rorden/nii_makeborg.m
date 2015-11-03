nii_make_borg
% Demo: create NIfTI volume with Jimmy's tools
% http://www.rotman-baycrest.on.ca/~jimmy/NIFTI/
% http://paulbourke.net/geometry/borg/

vox=64;
img = zeros(vox,vox,vox); 
freq =7;
for z = 2 : (vox-1) 
	z1 = freq*z/vox;
	for y = 2 : (vox-1) 
		y1 = freq*y/vox;
		for x = 2 : (vox-1) 
			x1 = freq*x/vox;
			
			img(x,y,z)=pi+sin(x1*y1)+sin(y1*z1)+sin(z1*x1);
		end;
	end;
end;
ni=make_nii(img,[2],[0],16);
save_nii(ni, 'test.nii');
