function mask=rest_loadmask(AX, AY, AZ, AMaskFilename)
%Load mask for REST by Xiao-Wei Song
% AX, AY, AZ should be the same size as the Volume, this size should be set automatically, but I use this for compatibility. And I specially give the code  for many files' use already. And another reason is the null mask need it
% AMaskFilename should be the mask filename
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
% dawnsong, 20070509
%------------------------------------------------------------------------------------------------------------------------------
%Vesa.Kiviniemi@ppshp.fi found Yong He's bug in loading a null-mask
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.2;
%	Release=20081225;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Revised by Yan Chao-Gan 081225: use the new mask files.
%   Revised by YAN Chao-Gan, 090420. Revise the input mask to ensure that it only contains 0 and 1.	
	
	
%Load mask, copy from reho.m revised by Dawnwei.Song, 20070504
[pathstr, name, ext] = fileparts(mfilename('fullpath'));

if ( strcmp(AMaskFilename, '')|| (isnumeric(AMaskFilename) && AMaskFilename==0) )% like the old parameter, back-compatible  Xiaowei Song, 20070421
	mask=ones(AX, AY, AZ);
elseif( strcmpi(AMaskFilename, 'Default')||( isnumeric(AMaskFilename) && AMaskFilename==1) ) % like the old parameter	, back-compatible  Xiaowei Song, 20070421
	switch int2str([AX, AY, AZ])
	    case '79  95  69'   % 'default''[2 2 2]'
	        [mask, vsizeTmp, Header]=rest_readfile([pathstr '/mask/BrainMask_05_79x95x69.img']); %YAN Chao-Gan 081225: New masks.
	    case '53  63  46'   % 'default''[3 3 3]'	        
			[mask, vsizeTmp, Header]=rest_readfile([pathstr '/mask/BrainMask_05_53x63x46.img']); %YAN Chao-Gan 081225: New masks.
	    case '91  109   91'  % 'template''[2 2 2]'	        
			[mask, vsizeTmp, Header]=rest_readfile([pathstr '/mask/BrainMask_05_91x109x91.img']); %YAN Chao-Gan 081225: New masks.
	    case '61  73  61'   % 'template' '[3 3 3]'	        
			[mask, vsizeTmp, Header]=rest_readfile([pathstr '/mask/BrainMask_05_61x73x61.img']); %YAN Chao-Gan 081225: New masks.
	    otherwise
	        error(sprintf('There are no appropriate default mask file:\n\tVolume size=79*95*69 ,Voxel size=2*2*2;\n\tVolume size=53*63*46, Voxel size=3*3*3;\n\tVolume size=91*109*91, Voxel size=2*2*2;\n\tVolume size=61*73*61, Voxel size=3*3*3;\n Please set bMask = 0.'));
	end %end switch
else		% new,  Xiaowei Song, 20070421
	if (ischar(AMaskFilename))
		%if is img file, read and load
		if strcmpi(AMaskFilename(end-3:end), '.img') || strcmpi(AMaskFilename(end-3:end), '.nii')
			[mask, vsizeTmp, Header]=rest_readfile(AMaskFilename);            
		else%if is mat file, direct load			
			load(AMaskFilename);
		end
	else
		error('There are no appropriate mask file. Please set bMask = 0.');
	end
end %mask select end

mask =logical(mask); %Revised by YAN Chao-Gan, 090420. Revise the mask to ensure that it only contains 0 and 1.	

%Check whether mask is 3d
if ndims(mask)~=3
	error('mask error, mask is not 3d');
end	

% Brutely check the mask's size to make sure whether the mask's size same to the required size
if ~all(size(mask)==[AX, AY, AZ]),	
	%warning(sprintf('\n\tMask does not match. Brutely use "No Mask".\n\tMask size is %dx%dx%d, not equal to required size %dx%dx%d',size(mask), [AX, AY, AZ]));
	
	%20070820 Zang's advice
	error(sprintf('\n\tMask does not match.\n\tMask size is %dx%dx%d, not same with required size %dx%dx%d',size(mask), [AX, AY, AZ]));
	
	mask = ones(AX, AY, AZ);	
end