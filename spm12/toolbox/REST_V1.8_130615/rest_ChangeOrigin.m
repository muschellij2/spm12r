function rest_ChangeOrigin(ADataDir, ANewOrigin)
%Change the orgin of ANALYZE 7.5 
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%	Dawnwei.Song@gmail.com
%-----------------------------------------------------------
    theFileList = dir(ADataDir);	
	ImgFileList ={};
	for x = 3:size(struct2cell(theFileList),2)
	    if strcmpi(theFileList(x).name(end-3:end), '.hdr') 
	        if strcmpi(theFileList(x).name(1:end-4), theFileList(x+1).name(1:end-4))
				ImgFileList=[ImgFileList; {theFileList(x).name(1:end-4)}];
            else
                error('*.{hdr,img} should be pairwise. Please re-examin them.');
            end
	    end
	end
	clear theFileList;
	
	%read the normalized functional images 
	% -------------------------------------------------------------------------
	fprintf('\n\t Read 3D EPI functional images: "%s".', ADataDir);	
	for x = 1:size(ImgFileList,1),    		
		rest_waitbar(x/size(ImgFileList,1), ...
					ImgFileList{x}, ...
					'Reset origin','Child','NeedCancelBtn');
		theFilename = fullfile(ADataDir,ImgFileList{x});				
		% [theOneTimePoint VoxelSize, Origin] = rest_readfile(theFilename);
        
        %theNewFilename =fullfile(ADataDir,['x', ImgFileList{x}]);
        % rest_writefile(theOneTimePoint,theFilename,size(theOneTimePoint),VoxelSize',ANewOrigin,'int16')
		
		hdr_ChangeOrigin(theFilename, ANewOrigin);
		if ~mod(x,5)
			fprintf('.');		
		end
    end
    fprintf('\n\t Reset origin over: "%s".', ADataDir);	
    rest_waitbar;
	
	
function hdr_ChangeOrigin(AFilename, ANewOrigin)
	if length(AFilename)>4
		if strcmpi(AFilename(end-3:end), '.hdr')
		  AFilename = AFilename(1:end-4);
		end
		if strcmpi(AFilename(end-3:end), '.img')
		  AFilename = AFilename(1:end-4);
		end
	end

	% open .hdr file
	fid = fopen([AFilename,'.hdr'],'r+');
	if fid > 0
	fseek(fid,40,'bof');
	dim = fread(fid,8,'int16');
	byteswap = 'native';
	% byte swapping 
	if (dim(1) > 15 | dim(1) < 0)
		byteswap = 'ieee-be';
		fclose(fid);
		fid = fopen([AFilename,'.hdr'],'r','ieee-be');
		fseek(fid,40,'bof');
		dim = fread(fid,8,'int16');
		if (dim(1) > 15 | dim(1) < 0)
			byteswap = 'ieee-le';
			fclose(fid);
			fid = fopen([AFilename,'.hdr'],'r','ieee-le');
			fseek(fid,40,'bof');
			dim = fread(fid,8,'int16');
			if (dim(1) > 15 | dim(1) < 0)
				error('Error opening header file. Dimension error');end
		end
	end
	else error(sprintf('Error opening header file. Please check whether the %s.hdr file exist.',filename));end

	%Dawnsong added, 20070904, for ROI coordinate transformation
	fseek(fid,148+105,'bof');
	Origin = fread(fid,3,'int16');
	%fclose(fid);
	
	%fid = fopen([AFilename,'.hdr'],'r+');
	fseek(fid,148+105,'bof');
	fwrite(fid,[ANewOrigin,0,0],'int16');
	fclose(fid);