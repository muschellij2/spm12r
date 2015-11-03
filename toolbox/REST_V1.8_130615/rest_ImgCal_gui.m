function varargout = rest_ImgCal_gui(varargin)
%   varargout = rest_ImgCal_gui(varargin)
%   Image Calculator for REST.
%   By YAN Chao-Gan and Dong Zhang-Ye 091029.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a> 
%	Version=1.0;
%	Release=20091215;
%------------------------------------------------------------------------------------------------------------------------------
%   Revised by YAN Chao-Gan, 100130. Make the outputname as 00001.img other than 1.img.
%   Revised by Dong Zhang-Ye, 100530. Add the function of corr(i1,i2,'spatial').
%   Revised by DONG Zhang-Ye, 110218. Fixed an error when processing i10, i11....
%   Revised by DONG Zhang-Ye, 110505. Supporting keep "shift" key and select multiple images and groups.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_ImgCal_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_ImgCal_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function rest_ImgCal_gui_OpeningFcn(hObject, eventdata, handles, varargin)
InitControlProperties(hObject, handles);
handles.Cfg.DataDirs ={};
handles.Cfg.DataImgs = {};
handles.Cfg.OutputDir=pwd;

handles.output = hObject;
set(handles.edtoutdir ,'String', handles.Cfg.OutputDir);

% Make Display correct in linux - YAN Chao-Gan 111025 Added.
if ~ispc
    ZoomFactor=0.85;
    ObjectNames = fieldnames(handles);
    for i=1:length(ObjectNames);
        eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
        if IsFontSizeProp
            eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
            FontSize=PCFontSize*ZoomFactor;
            eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
        end
    end
end

guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = rest_ImgCal_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in btnAddGroup.
function btnAddGroup_Callback(hObject, eventdata, handles)
if size(handles.Cfg.DataDirs, 1)>0
		theDir =handles.Cfg.DataDirs{1,1};
else
		theDir =pwd;
end
theDir =uigetdir(theDir, 'Please select the data directory to compute: ');
if ischar(theDir),
	SetDataDir(hObject, theDir,handles);	
end


% --- Executes on selection change in listGroup.
function listGroup_Callback(hObject, eventdata, handles)
theIndex =get(hObject, 'Value');
if isempty(theIndex) || theIndex<1,
     msgbox(sprintf('Nothing added.\n\nYou must add some diretories containing only paired {hdr/img} files first'), ...
				'REST' ,'help');
	return;
end	
	
if strcmp(get(handles.figIC, 'SelectionType'), 'open') %when double click 
	msgbox(sprintf('%s \t\nhas\t %d\t volumes\n\nTotal: %d Data Directories' , ... 
					handles.Cfg.DataDirs{theIndex, 1} , ...
	                handles.Cfg.DataDirs{theIndex, 2} , ...
					size(handles.Cfg.DataDirs,1)), ...
					'Volume count in selected dir' ,'help');
end


% --- Executes during object creation, after setting all properties.
function listGroup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnAddImage.
function btnAddImage_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
												'Pick a user''s  image','MultiSelect','on'); %Multiple Files 20110326 DONG
                                                                        
if ~isempty(filename)%Multiple Files 20110326 DONG
    if ~iscell(filename)
        handles.Cfg.DataImgs =[ handles.Cfg.DataImgs;{[pathname,filename]}];
    else
        for i=1:size(filename,2)
            handles.Cfg.DataImgs =[ handles.Cfg.DataImgs;{[pathname,filename{1,i}]}];
        end
    end%Multiple Files 20110326 DONG
    guidata(hObject,handles);
end    
UpdateDisplay(handles);



% --- Executes on selection change in listImage.
function listImage_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listImage_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtFunction_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function edtFunction_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnCompute.
function btnCompute_Callback(hObject, eventdata, handles)
theOldColor=get(hObject,'BackgroundColor');		
set(hObject,'Enable','off', 'BackgroundColor', 'red');
set(handles.btnAddGroup,'Enable','off');
set(handles.btnAddImage,'Enable','off');
drawnow;
OutPut=get(handles.edtOutput, 'String');
OutDir=handles.Cfg.OutputDir;
Function=get(handles.edtFunction,'String');
Group=handles.Cfg.DataDirs;
Image=handles.Cfg.DataImgs;
Gmag=size(Group,1);
% if Gmag>=1,
%     data={Group{1:Gmag},Image};
% else
%     data={Image};
% end
% if ~isempty(findstr('*',Function)) && isempty((findstr('.*',Function)))
%    Function=strrep(Function,'*','.*');
% end
if ~isempty(findstr('corr',Function))
    if ~isempty(findstr('g',Function))
        mkdir([OutDir,filesep,OutPut]);
        f=strrep(Function,'corr','rest_TwoGroupCorr');
        f=strrep(f,'g','Group{');
        f=strrep(f,',','},');
        f=strrep(f,')',',[OutDir,filesep,OutPut])');
        eval(f);
    else
        mkdir([OutDir,filesep,OutPut]); %dong 100530
        f=strrep(Function,'corr','rest_TwoGroupCorr');
        f=strrep(f,'i','Image{');
        f=strrep(f,',','},');
        f=strrep(f,')',',[OutDir,filesep,OutPut])');
        eval(f);
    end
else %Revised by YAN Chao-Gan 100403.
    MeanStrIndex=findstr('mean',Function);
    if ~isempty(MeanStrIndex)
        for imean=1:length(MeanStrIndex)
            RightBrackedIndex=findstr(')',Function);
            RightBrackedIndex=min(RightBrackedIndex(find(RightBrackedIndex>MeanStrIndex(imean))));
            MeanStr=Function(MeanStrIndex(imean):RightBrackedIndex);
            NewImageIndex=length(Image)+1;
            Function=strrep(Function,MeanStr,['i',num2str(NewImageIndex)]);
            MeanGroupName=['group',MeanStr(7:end-1),'_mean.img'];
            Image=[Image;{[OutDir,filesep,MeanGroupName]}];
            f=strrep(MeanStr,'mean','rest_Mean');
            f=strrep(f,'g','Group{');
            f=strrep(f,')','},OutDir,MeanGroupName)');
            eval(f);
        end
    end
    StdStrIndex=findstr('std',Function);
    if ~isempty(StdStrIndex)
        for istd=1:length(StdStrIndex)
            RightBrackedIndex=findstr(')',Function);
            RightBrackedIndex=min(RightBrackedIndex(find(RightBrackedIndex>StdStrIndex(istd))));
            StdStr=Function(StdStrIndex(istd):RightBrackedIndex);
            NewImageIndex=length(Image)+1;
            Function=strrep(Function,StdStr,['i',num2str(NewImageIndex)]);
            StdGroupName=['group',StdStr(6:end-1),'_std.img'];
            Image=[Image;{[OutDir,filesep,StdGroupName]}];
            f=strrep(StdStr,'std','rest_Std');
            f=strrep(f,'g','Group{');
            f=strrep(f,')','},OutDir,StdGroupName)');
            eval(f);
        end
    end
    if Gmag>=1,
        data={Group{1:Gmag},Image};
    else
        data={Image};
    end
    if ~isempty(findstr('*',Function)) && isempty((findstr('.*',Function)))
        Function=strrep(Function,'*','.*');
    end
    if ~isempty(findstr('/',Function)) && isempty((findstr('./',Function))) %Added by YAN Chao-Gan, 100403.
        Function=strrep(Function,'/','./');
    end
    img_cal(OutDir,OutPut,Function,Gmag,data);
end
set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
set(handles.btnAddGroup,'Enable','on');
set(handles.btnAddImage,'Enable','on');
drawnow;
rest_waitbar;






function edtOutput_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function edtOutput_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function InitControlProperties(hObject, handles)
    handles.hContextMenu =uicontextmenu;
	set(handles.listGroup, 'UIContextMenu', handles.hContextMenu);	
	uimenu(handles.hContextMenu, 'Label', 'Add a group', 'Callback', get(handles.btnAddGroup, 'Callback'));	
	uimenu(handles.hContextMenu, 'Label', 'Remove selected group', 'Callback', 'rest_ImgCal_gui(''DeleteSelectedDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', '=============================');	
	uimenu(handles.hContextMenu, 'Label', 'Remove all data groups', 'Callback', 'rest_ImgCal_gui(''ClearDataDirectories'',gcbo,[], guidata(gcbo))');
    
    handles.hContextMenui =uicontextmenu;
	set(handles.listImage, 'UIContextMenu', handles.hContextMenui);	
	uimenu(handles.hContextMenui, 'Label', 'Add an image', 'Callback', get(handles.btnAddImage, 'Callback'));	
	uimenu(handles.hContextMenui, 'Label', 'Remove selected image', 'Callback', 'rest_ImgCal_gui(''DeleteSelectedDataImg'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenui, 'Label', '=============================');	
	uimenu(handles.hContextMenui, 'Label', 'Remove all images', 'Callback', 'rest_ImgCal_gui(''ClearDataImgs'',gcbo,[], guidata(gcbo))');
	
    
   ExpressionHelp='Please input the expression here. Click Help for more information.';
    set(handles.edtFunction, 'ToolTipString', ExpressionHelp);	
	
	% Save handles structure	
	guidata(hObject,handles);
function SetDataDir(hObject, ADir,handles)	
if ~ischar(ADir), return; end	
theOldWarnings =warning('off', 'all');
if rest_misc('GetMatlabVersion')>=7.3,
	ADir =strtrim(ADir);
end	
if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.DataDirs( : , 1),'exact' ) ) ))
     handles.Cfg.DataDirs =[handles.Cfg.DataDirs;{ADir , 0}];%update the dir  
     tmpSize=size(handles.Cfg.DataDirs);
	 theVolumnCount =rest_CheckDataDir(handles.Cfg.DataDirs{tmpSize(1),1} );	
	 if (theVolumnCount<=0),
			if isappdata(0, 'FC_DoingRecursiveDir') && getappdata(0, 'FC_DoingRecursiveDir'), 
			else
				fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n\n', ADir);
				errordlg( sprintf('There is no data or non-data files in this directory:\n\n%s\n\nPlease re-select',ADir )); 
			end
			handles.Cfg.DataDirs(tmpSize(1),:)=[];
			if size(handles.Cfg.DataDirs, 1)==0
				handles.Cfg.DataDirs=[];
			end	       
	 else
			handles.Cfg.DataDirs{tmpSize(1),2} =theVolumnCount;
     end	
     guidata(hObject, handles);
     UpdateDisplay(handles);
end
warning(theOldWarnings);
function [nVolumn]=CheckDataDir(ADataDir)
theFilenames = dir(ADataDir);
theHdrFiles=dir(fullfile(ADataDir,'*.hdr'));
theImgFiles=dir(fullfile(ADataDir,'*.img'));
if ~length(theHdrFiles)==length(theImgFiles)
		nVolumn =-1;
		fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);
		errordlg('*.{hdr,img} should be pairwise. Please re-examin them.'); 
		return;
end		
count = 3; nVolumn = 0;		
for count = 3:size(struct2cell(theFilenames),2)				
		if	(length(theFilenames(count).name)>4) && ...
			strcmpi(theFilenames(count).name(end-3:end) , '.hdr') 
			if strcmpi(theFilenames(count).name(1:end-4) ...                %hdr
					        , theFilenames(count+1).name(1:end-4) )     %img
				nVolumn = nVolumn + 1;  
            else
				nVolumn =-1;
				fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);	
				errordlg('*.{hdr,img} should be pairwise. Please re-examin them.'); 
				break;
			end
		end			
end
function UpdateDisplay(handles)
if size(handles.Cfg.DataDirs,1)>0	
	theOldIndex =get(handles.listGroup, 'Value');
	set(handles.listGroup, 'String',  GetInputDirDisplayList(handles) , 'Value', 1);
	theCount =size(handles.Cfg.DataDirs,1);
	if (theOldIndex>0) && (theOldIndex<= theCount)
		set(handles.listGroup, 'Value', theOldIndex);
    end
else
	set(handles.listGroup, 'String', '' , 'Value', 0);
end
if size(handles.Cfg.DataImgs)>0	
		theOldIndexi =get(handles.listImage, 'Value');%here
		set(handles.listImage, 'String',  GetInputImageDisplayList(handles) , 'Value', 1);
		theCount =size(handles.Cfg.DataImgs,1);
		if (theOldIndexi>0) && (theOldIndexi<= theCount)
			set(handles.listImage, 'Value', theOldIndexi);
        end
else
		set(handles.listImage, 'String', '' , 'Value', 0);
end


function Result=GetInputDirDisplayList(handles)
Result ={};
for x=size(handles.Cfg.DataDirs, 1):-1:1
	Result =[{sprintf('g%d : %d img %s',x,handles.Cfg.DataDirs{x, 2},handles.Cfg.DataDirs{x, 1})} ;Result];
end
function Result=GetInputImageDisplayList(handles)
Result ={};
for x=size(handles.Cfg.DataImgs,1):-1:1 %Multiple files 20110326 DONG
	Result =[{sprintf('i%d : %s',x, handles.Cfg.DataImgs{x})} ;Result];
end

function DeleteSelectedDataDir(hObject, eventdata, handles)	
theIndex =get(handles.listGroup, 'Value');
if prod(size(handles.Cfg.DataDirs))==0 ...
	|| size(handles.Cfg.DataDirs, 1)==0 ...
	|| theIndex>size(handles.Cfg.DataDirs, 1),
	return;
end
theDir     =handles.Cfg.DataDirs{theIndex, 1};
theVolumnCount=handles.Cfg.DataDirs{theIndex, 2};
tmpMsg=sprintf('Delete\n\n "%s" \nVolumn Count :%d ?', theDir, theVolumnCount);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
	if theIndex>1,
		set(handles.listGroup, 'Value', theIndex-1);
    end
    handles.Cfg.DataDirs(theIndex, :)=[];
	if size(handles.Cfg.DataDirs, 1)==0
		handles.Cfg.DataDirs={};
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);
end


function DeleteSelectedDataImg(hObject, eventdata, handles)	
theIndex =get(handles.listImage, 'Value');
if prod(size(handles.Cfg.DataImgs))==0 ...
	|| theIndex>size(handles.Cfg.DataImgs,1),
	return;
end
theDir     =handles.Cfg.DataImgs{theIndex};
tmpMsg=sprintf('Delete\n\n "%s" ?', theDir);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
	if theIndex>1,
        set(handles.listImage, 'Value', theIndex-1);
    end
    handles.Cfg.DataImgs(theIndex)=[];
	if size(handles.Cfg.DataImgs)==0
		handles.Cfg.DataImgs={};
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);
end
	


function ClearDataDirectories(hObject, eventdata, handles)	
if prod(size(handles.Cfg.DataDirs))==0 ...
	|| size(handles.Cfg.DataDirs, 1)==0,		
    return;
end
tmpMsg=sprintf('Attention!\n\n\nDelete all data directories?');
if strcmpi(questdlg(tmpMsg, 'Clear confirmation'), 'Yes'),		
	handles.Cfg.DataDirs(:)=[];
	if prod(size(handles.Cfg.DataDirs))==0,
		handles.Cfg.DataDirs={};
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);
end	

function ClearDataImgs(hObject, eventdata, handles)	
if prod(size(handles.Cfg.DataImgs))==0,		
    return;
end
tmpMsg=sprintf('Attention!\n\n\nDelete all data directories?');
if strcmpi(questdlg(tmpMsg, 'Clear confirmation'), 'Yes'),		
	handles.Cfg.DataImgs(:)=[];
	if prod(size(handles.Cfg.DataImgs))==0,
		handles.Cfg.DataImgs={};
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);
end	




function img_cal(outdir,out,f,dirmag,varargin)
dirg=varargin{1}(1:dirmag);
imgpre=varargin{1}(dirmag+1:end);
img=imgpre{1};
%f='(i2+i1).*g1';
%out='testgi2';
%dirg1='E:\imagecalculator\g1';
%dirg2='E:\imagecalculator\g2';
%dirg3='E:\imagecalculator\g3';
%img1='E:\imagecalculator\i1.img';
%img2='E:\imagecalculator\i2.img';
%img3='E:\imagecalculator\i3.img';
%...


for j=1:length(img)
    if ~isempty(img(j))
        eval(['[i' int2str(j) ',voxdim,header] = rest_readfile(img{j});']);
    end
end
olddir=pwd;
DirListg={};
minlength=+inf;
for j=1:length(dirg)
    cd(dirg{j});
    DirListg{j}=dir('*.img');
    if isempty(DirListg{j})
        DirListg{j}=dir('*.nii');
    end
    minlength=min(minlength,length(DirListg{j}));
end
cd(olddir);
% mkdir(out); % YAN Chao-Gan 091215.
% cd(out);
if isempty(findstr('g',f))
    minlength=1;
end
for i=1:minlength
    rest_waitbar(i/minlength,'Computing','Computing','Parent');
    for j=1:length(dirg)
        if ~isempty(dirg(j))
            if ispc,
                tempname=strcat(dirg{j},'\',DirListg{j}(i).name);
            else 
                tempname=strcat(dirg{j},'/',DirListg{j}(i).name);
            end
            eval(['[g' int2str(j) ',voxdim,header] = rest_readfile(tempname);']);
        end
    end
    eval(['Y = ' f ';']);
    OutNameIndex=['0000000' num2str(i)]; %Added by YAN Chao-Gan, 100130. Make the outputname as 00001.img other than 1.img.
    OutNameIndex=OutNameIndex(end-4:end);
    outname=strcat(out,OutNameIndex); %Revised by YAN Chao-Gan, 100130. Make the outputname as 00001.img other than 1.img.%outname=strcat(out,int2str(i));
        temf=f;
        acplace=0;
        placei=strfind(f,'i');
        placeg=strfind(f,'g');
        place=[placei,placeg];
        place=sort(place);
        for ipl=1:length(place)
            if (place(ipl)+2)<=length(f)
                temi=f(place(ipl)+1:place(ipl)+2);
            else
                temi=f(place(ipl)+1);
            end
            temi=filter_num(temi);
            if ~isempty(temi)
                if numel(find(placei==place(ipl)))==1
                    numi=str2num(temi);
                    temi=strcat('i',temi);
                    
                    [a,fname]=fileparts(img{numi});
                    afterplace=place(ipl)+acplace;
                    if (place(ipl)+2)<=length(f)
                        temf=strcat(temf(1:afterplace-1),strrep(temf(afterplace:afterplace+2),temi,strcat(temi,': ',fname,'.img')),temf(afterplace+3:end));
                    else
                        temf=strcat(temf(1:afterplace-1),strrep(temf(afterplace:afterplace+1),temi,strcat(temi,': ',fname,'.img')),temf(afterplace+3:end));
                    end
                    acplace=acplace+length(fname)+5;
                else
                    numg=str2num(temi);
                    temi=strcat('g',temi);
                    
                    afterplace=place(ipl)+acplace;
                    if (place(ipl)+2)<=length(f)
                        temf=strcat(temf(1:afterplace-1),strrep(temf(afterplace:afterplace+2),temi,strcat(temi,': ',DirListg{numg}(i).name)),temf(afterplace+3:end));
                    else
                        temf=strcat(temf(1:afterplace-1),strrep(temf(afterplace:afterplace+1),temi,strcat(temi,': ',DirListg{numg}(i).name)),temf(afterplace+3:end));
                    end
                    acplace=acplace+length(DirListg{numg}(i).name)+1;
                end
            end
        end
        
%         for iim=length(img):-1:1
%             [a,fname]=fileparts(img{iim});
%             temi=strcat('i',int2str(iim));
%             temf=strrep(temf,temi,strcat(temi,': ',fname,'.img'));
%         end
      
%         for iig=length(dirg):-1:1
%             temg=strcat('g',int2str(iig));
%             temf=strrep(temf,temg,strcat(temg,': ',DirListg{iig}(i).name));
%         end
        fprintf('%s.img= %s\n',outname,temf);
    if ispc,
       outname=[outdir,'\',outname];
    else 
       outname=[outdir,'/',outname];
     end
    if dirmag>0,
        rest_writefile(Y,outname,size(g1),voxdim,header,'double') ;
    else
        rest_writefile(Y,outname,size(i1),voxdim,header,'double') ;
    end
end
cd(olddir);




function edtoutdir_Callback(hObject, eventdata, handles)

function edtoutdir_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function btnoutdir_Callback(hObject, eventdata, handles)
theDir =handles.Cfg.OutputDir;
	theDir =uigetdir(theDir, 'Please select the output directory: ');
	if ~isequal(theDir, 0)
		SetOutputDir(hObject,handles, theDir);	
	end	
	
function SetOutputDir(hObject, handles, ADir)
	if 7==exist(ADir,'dir')
		handles.Cfg.OutputDir =ADir;
        set(handles.edtoutdir,'String',ADir);
		guidata(hObject, handles);
	    UpdateDisplay(handles);
    end

function rest_Mean(GroupDir,outdir,outname)
olddir=pwd;
[GroupSeries, VoxelSize, ImgFileList, Header,nVolumn] =rest_to4d(GroupDir);
cd(olddir);
rest_waitbar;
meanSeries=mean(GroupSeries,4);
fprintf('Get the mean value of all the images in %s\n',GroupDir);
rest_WriteNiftiImage(meanSeries,Header,[outdir,filesep,outname]);

function rest_Std(GroupDir,outdir,outname)
% Added by YAN Chao-Gan 100403
olddir=pwd;
[GroupSeries, VoxelSize, ImgFileList, Header,nVolumn] =rest_to4d(GroupDir);
cd(olddir);
rest_waitbar;
StdSeries=std(GroupSeries,0,4);
fprintf('Get the std value of all the images in %s\n',GroupDir);
rest_WriteNiftiImage(StdSeries,Header,[outdir,filesep,outname]);




function bu_Callback(hObject, eventdata, handles)
% hObject    handle to bu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bu as text
%        str2double(get(hObject,'String')) returns contents of bu as a double


% --- Executes during object creation, after setting all properties.
function bu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnHelp.
function btnHelp_Callback(hObject, eventdata, handles)
msgbox({'Example expressions:';...
    '(a)      g1-1     Subtract 1 from each image in group 1';...
    '(b)      g1-g2    Subtract each image in group 2 from each corresponding image in group1';...
    '(c)      i1-i2    Subtract image 2 from image 1';...
    '(d)      i1>100    Make a binary mask image at threshold of 100';...
    '(e)      g1.*(i1>100)   Make a mask and then apply to each image in group 1';...
    '(f)      mean(g1)   Calculate the mean image of group 1';...
    '(g)      (i1-mean(g1))./std(g1)   Calculate the z value of i1 related to group 1';...
    '(h)      corr(g1,g2,''temporal'')    Calculate the temporal correlation between two groups, i.e. one correlation coefficient between two ''time courses'' for each voxel.';...
    '(i)      corr(g1,g2,''spatial'')     Calculate the spatial correlation between two groups, i.e. one correlation coefficient between two images for each ''time point''.';...
    '(i)      corr(i1,i2,''spatial'')     Calculate the spatial correlation between two images.';...
    },'Expression Help');

function outstr=filter_num(instr)%filter num from str 110218 dong
outstr='';
for i=1:length(instr)
    if double(instr(i))>=48&&double(instr(i))<=57
        outstr=strcat(outstr,instr(i));
    end
end


