function [] = rest_WriteAnalyzeImage(data,filename,isize,vsize,AOrigin,dtype)
%Write ANALYZE 7.5 file by Yong He and Xiao-Wei Song
% %------------------------------------------------------------------------------------------------------------------------------
% Write analyze format file.
% FORMAT function [] = rest_writefile(data,filename,isize,vsize,dtype)
%           filename - Analyze file (*.{hdr, img})
%               data - .mat data file.                            
%              isize - the size of the data
%              vsize - the size of the voxel
%              dtype - the data type.
%
% Written by Yong He, April,2004
% Medical Imaging and Computing Group (MIC), National Laboratory of Pattern Recognition (NLPR),
% Chinese Academy of Sciences (CAS), China.
% E-mail: yhe@nlpr.ia.ac.cn
% Copywrite (c) 2004, 
% %------------------------------------------------------------------------------------------------------------------------------

% remove file extension if exists
% if filename(end-3:end) == '.hdr'
%   filename = filename(1:end-4);
% end
% if filename(end-3:end) == '.img'
%   filename = filename(1:end-4);
% end

%20071031, Dawnwei.Song revised for Scaling
if strcmpi(lower(dtype),'int16'),
	tmpData =double(data(0~=data));
	if length(tmpData)>1000 && mean(abs(tmpData))<100,	%This is a random value I set for supress data-type conversion!
		dtype='double';
	end
end

% write img 
fid = fopen([filename,'.img'],'w');
if fid<0, error(sprintf('Failed to Open file:%s', [filename,'.img'])); end
fwrite(fid,data,dtype);
fclose(fid);

%DawnWei.Song 20071021 Revised
switch lower(dtype),
    case 'double',
        datatype = 64;
        bitvox = 64; 
	case 'float',
		datatype = 16;
        bitvox = 16;
    case 'float32',
        datatype = 8;
        bitvox = 8;
    case 'int16',
        datatype = 4;
        bitvox = 4;
	case 'uint8',
        datatype = 2;
        bitvox = 2;	
    otherwise % need to add other decription
        error('unsupported data format now.');
end

scale = 1;
%write hdr
fid = fopen([filename,'.hdr'],'w');
fwrite(fid,zeros(1,348),'uint8');
fseek(fid,0,'bof');
fwrite(fid,348,'int16');
fseek(fid,32,'bof');
fwrite(fid,16384,'int16');
fseek(fid,38,'bof');
fwrite(fid,'r','char');
fseek(fid,40,'bof');
fwrite(fid,[4,isize,1],'int16');
fseek(fid,40+30,'bof');
fwrite(fid,datatype,'int16');
fseek(fid,40+32,'bof');
fwrite(fid,bitvox,'int16');
fseek(fid,40+36,'bof');
fwrite(fid,[0,vsize],'float32');
fseek(fid,40+72,'bof');
fwrite(fid,scale,'float');


switch int2str(isize)
    case '79  95  69'   % 'default''[2 2 2]'
        if vsize(1) == 2 & vsize(2) == 2 & vsize(3) == 2 
            origin = [40 57 26];
        else  error ('invalid voxel size.'); end            
    case '54  64  50'   % 'default''[3 3 3]'
        if vsize(1) == 3 & vsize(2) == 3 & vsize(3) == 3 
            origin = [28 28 23];
        else  error ('invalid voxel size.'); end                    
    case '91  109  91'  % 'template''[2 2 2]'
        if vsize(1) == 2 & vsize(2) == 2 & vsize(3) == 2 
            origin = [46 64 37];
        else  error ('invalid voxel size.'); end
    case '181  217  181'  % 'template''[1 1 1]'
        if vsize(1) == 1 & vsize(2) == 1 & vsize(3) == 1 
            origin = [91 127 73];
        else  error ('invalid voxel size.'); end 
    case '61  73  61'   % 'template' '[3 3 3]'
        if vsize(1) == 3 & vsize(2) == 3 & vsize(3) == 3 
            origin = [31 43 25];
        else  origin = [31 43 25]; end
    case '53  63  46'   % 'template' '[3 3 3]'
        if vsize(1) == 3 & vsize(2) == 3 & vsize(3) == 3 
            origin = [27 38 18];
        else  error ('invalid voxel size.'); end
    case '161 191 151'   % 'template' '[1 1 1]'
        if vsize(1) == 1 & vsize(2) == 1 & vsize(3) == 1
            origin = [82 82 66];
        else  error ('invalid voxel size.'); end
    % case '128 128 25'   % 'template' '[1.72 1.72 5]'
        % if vsize(1) == 1.72 & vsize(2) == 1.72 & vsize(3) == 5
            % origin = [0 0 0];
        % else  error ('invalid voxel size.'); end 
    otherwise
        %origin = [0 0 0];
end
origin =AOrigin;%Revised by Dawnsong
origin =reshape(origin, [1 3]);

fseek(fid,148+105,'bof');
fwrite(fid,[origin,0,0],'int16');
fclose(fid);
