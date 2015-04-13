function [Outdata,VoxDim, Origin] = rest_ReadAnalyzeImage(filename)
% Read file(ANALYZE 7.5, ...) for REST by Yong He and Xiao-Wei Song
% %------------------------------------------------------------------------------------------------------------------------------
% Read analyze format file.
% FORMAT function [Outdata,voxdim, Origin] = rest_readfile(filename)
%                 filename - Analyze file (*.{hdr, img})
%                 Outdata  - data file.                            
%                 VoxDim   - the size of the voxel.
%
% Written by Yong He, April,2004
% Medical Imaging and Computing Group (MIC), National Laboratory of Pattern Recognition (NLPR),
% Chinese Academy of Sciences (CAS), China.
% E-mail: yhe@nlpr.ia.ac.cn
% Copywrite (c) 2004, 
% %------------------------------------------------------------------------------------------------------------------------------
%Revised by dawnsong, 20070511
%Todo:
%1. read the origin and revise the rest_writefile.m

% remove file extension if exists
if length(filename)>4
	if strcmpi(filename(end-3:end), '.hdr')
	  filename = filename(1:end-4);
	end
	if strcmpi(filename(end-3:end), '.img')
	  filename = filename(1:end-4);
	end
end

% open .hdr file
fid = fopen([filename,'.hdr'],'r');
if fid > 0
    fseek(fid,40,'bof');
    dim = fread(fid,8,'int16');
    byteswap = 'native';
    % byte swapping 
    if (dim(1) > 15 | dim(1) < 0)
        byteswap = 'ieee-be';
        fclose(fid);
        fid = fopen([filename,'.hdr'],'r','ieee-be');
        fseek(fid,40,'bof');
        dim = fread(fid,8,'int16');
        if (dim(1) > 15 | dim(1) < 0)
            byteswap = 'ieee-le';
            fclose(fid);
            fid = fopen([filename,'.hdr'],'r','ieee-le');
            fseek(fid,40,'bof');
            dim = fread(fid,8,'int16');
            if (dim(1) > 15 | dim(1) < 0)
                error('Error opening header file. Dimension error');end
        end
    end
else error(sprintf('Error opening header file. Please check whether the %s.hdr file exist.',filename));end

fseek(fid,40+30,'bof');
DataType = fread(fid,1,'int16');
fseek(fid,40+36,'bof');
VoxDim = fread(fid,8,'float');
fseek(fid,40+72,'bof');
Scale = fread(fid,1,'float');

%Dawnsong added, 20070904, for ROI coordinate transformation
fseek(fid,148+105,'bof');
Origin = fread(fid,3,'int16');

fclose(fid);

% open .img file
fid = fopen([filename,'.img'],'r',byteswap);
if fid < 0
  error(sprintf('Error opening data file. Please check whether the %s.img file exist',filename));
end

switch DataType
    case 2
        dtype = 'uint8';
    case 4
        dtype = 'int16';
    case 8
        dtype = 'float32';
    case 16
        dtype = 'float';
    case 32
        dtype = 'float32';
    case 64
        dtype = 'double';
    otherwise
        error('Invalid data type!');
end

switch dim(1)
  case 4
      len = dim(2)*dim(3)*dim(4)*dim(5);
      Outdata = fread(fid,len,dtype);
      if dim(5) == 1  Outdata = reshape(Outdata,dim(2),dim(3),dim(4));      
      else            Outdata = reshape(Outdata,dim(2),dim(3),dim(4),dim(5));end
  case 3
      len = dim(2)*dim(3)*dim(4);
      Outdata = fread(fid,len,dtype);
      Outdata = reshape(Outdata,dim(2),dim(3),dim(4));    
end

fclose(fid);
if Scale ~= 1 & Scale ~= 0
    Outdata = Scale*Outdata; end
VoxDim = VoxDim(2:4);

