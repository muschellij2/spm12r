function Result = rest_ReadLutColorScheme(ALutFilename)
%Read look up table of color scheme By Xiao-Wei Song according to MRIcro's help forum
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%20070918
%------------------------------------------------------------------------------------------------------------------------------
%Read a binary LUT file-format to construct a look-up-table / color scheme
%dawnwei.song@gmail.com
%Code is translated from MRIcron's LoadColorScheme in nifti_img.pas, 20070918
theLutFile = fopen(ALutFilename,'r');
if theLutFile>0,
	try
		fseek(theLutFile,0,'eof');
		theSize =ftell(theLutFile);
		if any(theSize==[768, 800, 970]),
			fseek(theLutFile,theSize-768, 'bof');
			Result =zeros(256,3);
			Result(:,1) =fread(theLutFile, 256, 'uint8');
			Result(:,2) =fread(theLutFile, 256, 'uint8');
			Result(:,3) =fread(theLutFile, 256, 'uint8');			
			Result =Result/max(Result(:));
		else
			error('Non correct binary LUT file format that I don''t support currently');
		end
	catch
	end
	fclose(theLutFile);
else
	error(sprintf('Failed to open color file: %s', ALutFilename));
end

	 % if (lZ =768) or (lZ = 800) or (lZ=970) then begin
		% //binary LUT
		% assignfile(lFdata,lStr);
		% Filemode := 0;
		% reset(lFdata,1);
		% seek(lFData,lZ-768);
		% GetMem( lBuff, 768);
		% BlockRead(lFdata, lBuff^, 768);
		% for lZ := 0 to 255 do begin
			% lHdr.LUT[lZ].rgbRed := lBuff^[lZ];
			% lHdr.LUT[lZ].rgbGreen := lBuff^[lZ+256];
			% lHdr.LUT[lZ].rgbBlue := lBuff^[lZ+512];
			% lHdr.LUT[lZ].rgbReserved := kLUTalpha;
		% end;
          