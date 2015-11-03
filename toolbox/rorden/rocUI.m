function varargout = rocUI(varargin)
% simpleUI Example for creating GUIs with menus, toolbar, plots without GUIDE
% based on AXESMENUTOOLBAR http://www.mathworks.com/help/matlab/creating_guis/gui-with-axes-menu-and-toolbar.html
% Adds ability to easily call functions from the command line
% Example usage:
% simpleUI %launch program with defaults
% simpleUI('copyBitmap') %copy image to clipboard
% simpleUI('saveBitmap',{'myPicture.png'}); %save image to disk
mOutputArgs = {}; % Variable for storing output when GUI returns
h = findall(0,'tag',mfilename); %run as singleton http://www.mathworks.com/support/solutions/en/data/1-77HLIL/?product=SL&solution=1-77HLIL
if (isempty(h)) % new instance
    h = makeGUI; %set up user interface
else % instance already running
 figure(h); %make active figure
end;
if (nargin) && (ischar(varargin{1})) 
 f = str2func(varargin{1});
 f(guidata(h),varargin{2:nargin})
end

% --- Save screenshot as bitmap image
function saveBitmap(v,varargin)
%simpleUI('saveBitmap',{'myPicture.png'});
if (length(varargin) < 1), return; end;
filename = char(varargin{1});
%saveas(v.hPlotAxes, filename,'png'); %<- save as 150dpi
print (v.hMainFigure, '-r600', '-dpng', filename); %<- save as 600dpi, '-noui'
%end saveBitmap()

% --- Copy screenshot to clipboard
function copyBitmap(v)
%simpleUI('copyBitmap')
editmenufcn(v.hMainFigure,'EditCopyFigure');
%end copyBitmap()

function figureKeyPress(ObjH, EventData)
%Powerpoint wireless presenter devices generat pageup/pagedown and hide
%http://www.mathworks.com/matlabcentral/fileexchange/22334-keyboardnavigate/content/keyboardnavigate.m
global v;
if length(EventData.Modifier) == 0 ;%Normal mode; no modifier pressed
switch EventData.Key 
    case 'pageup' 
        absentResponse_Callback (ObjH);
        disp('PageUp: absent response');
    case 'pagedown' 
        presentResponse_Callback (ObjH);
        disp('PageDown: present response'); %to determine other keys
    otherwise
        %disp(double(EventData.Key));
end;
end;%no modifier
Key = get(ObjH, 'CurrentCharacter');
switch Key
 case 98 %F5/escape key
    nextTrial_Callback(ObjH);
    disp('b key: next trial');
 %case 27 %F5/escape key
     %disp('escape');
 %case 46 %monitor hide key
    %startStopCallback(v.hStartButton,[]);
    %disp('hide');
 otherwise
     disp(double(Key)); %to determine other keys
end; %switch deviceType   
%end figureKeyPress()     

% --- Declare and create all the UI objects
function [vFig] =  makeGUI
buttonHeight = 30;
border = 60; %pixels space around edges of figure- if you adjust this, also adjust 'fontsize' in rocPlot
screensize = get(0,'ScreenSize');
sz = [680 480]; % figure width, height in pixels
sz = [screensize(3)-100 screensize(4)-100]; % figure width, height in pixels
margin = [ceil((screensize(3)-sz(1))/2) ceil((screensize(4)-sz(2))/2)];
v.hMainFigure = figure('KeyPressFcn', @figureKeyPress,'MenuBar','none','Toolbar','none','HandleVisibility','on', ...
'DeleteFcn',@DeleteFigure_Callback,'Tag', mfilename,'Name', mfilename, 'NumberTitle','off', ...
 'position',[margin(1), margin(2), sz(1), sz(2)],'Color', get(0, 'defaultuicontrolbackgroundcolor'));
%user interface objects
v.hPlotAxes = axes('Parent', v.hMainFigure,'Units', 'pixels', ...
 'HandleVisibility','on','Position',[border (border) (sz(1)-2*border) (sz(2)-border-buttonHeight)]);
v.hNextTrialButton = uicontrol('Style', 'PushButton','String', 'Next Trial','units', 'pixels','position', [120 (sz(2)-buttonHeight) 60 buttonHeight],'callback', {@nextTrial_Callback});
v.hPresentButton = uicontrol('Enable','off','Style', 'PushButton','String', 'Present','units', 'pixels','position', [190 (sz(2)-buttonHeight) 60 buttonHeight],'callback', {@presentResponse_Callback});
v.hAbsentButton = uicontrol('Enable','off','Style', 'PushButton','String', 'Absent','units', 'pixels','position', [260 (sz(2)-buttonHeight) 60 buttonHeight],'callback', {@absentResponse_Callback});
%menu items
v.hFileMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','File');
v.hNextTrialMenuitem = uimenu('Parent',v.hFileMenu,'Label','Present Trial','HandleVisibility','callback', 'Callback', @nextTrial_Callback);
v.hSetIntenistyMenuitem = uimenu('Parent',v.hFileMenu,'Label','Set Intensity','HandleVisibility','callback', 'Callback', @setIntensity_Callback);
v.hSaveMenuitem = uimenu('Parent',v.hFileMenu,'Label','Save bitmap','HandleVisibility','callback', 'Callback', @saveBitmap_Callback);
v.hEditMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Edit');
v.hCopyMenuitem = uimenu('Parent',v.hEditMenu,...
 'Label','Copy','HandleVisibility','callback','Callback', @copyBitmap_Callback);
v.hToolbarMenu = uimenu('Parent',v.hEditMenu,'Label','Show/hide toolbar','HandleVisibility','callback','Callback', @ToolbarMenu_Callback);
v.hHelpMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Help');
v.hAboutMenu = uimenu('Parent',v.hHelpMenu,'Label','About','HandleVisibility','callback','Callback', @AboutMenu_Callback);
v.AboutVersionString = 'SimpleUI version 7/2013';
%draw initial figure
vFig = v.hMainFigure;
v.Intensity = 50; %sound intensity 0..1
v.Hz = 2000; %sound frequency in Hz
v.Duration = 0.2; %sound duration in Sec
guidata(v.hMainFigure,v);%store settings
ClearTrials_Callback(v.hMainFigure, 1);
rocPlot(v.hMainFigure); 
%end makeGUI()

function rocPlot(hObject)
v = guidata(hObject); %get settings
nCurves = 3;
nSamp = 40;
faRate = (0:nSamp)/nSamp;
hitRate= zeros(nCurves, length(faRate));
nTests = 100;
dTarget = 0;
for c= 1:nCurves
    hitRate(c,:)=faRate;
    for i=2:(nSamp) %compute for values >0 and <1.0 
        dInc = (1-faRate(i))/nTests;
        d = 0;
        while (hitRate(c,i) < 1.0) && (d < dTarget),
            hitRate(c,i) = hitRate(c,i) + dInc;
            [d,beta] = dprime(hitRate(c,i),faRate(i));
        end;
        hitRate(c,i) = hitRate(c,i) - dInc/2;
        %fprintf('d= %f, pHit=%f pFA=%f %f\n',d, hitRate(c,i), faRate(i), dTarget);
    end;
    dTarget = dTarget+1;
end;
set(gca,'FontSize',24); %if you adjust this, also adjust 'border' in makeGUI
hold off;
plot(faRate, hitRate(1,:), '-r','LineWidth',2);
hold on;
plot(faRate, hitRate(2,:), '-y','LineWidth',2);
plot(faRate, hitRate(3,:), '-g','LineWidth',2);
e = 0.05; axis([0-e 1+e 0-e 1+e]);
vxlabel = xlabel('false alarm rate');
vylabel = ylabel('hit rate');
vLegend = legend('d=0','d=1','d=3');
 set(vLegend,'Location','SouthEast')
grid on
axis square; %set(gca,'DataAspectRatio',[1 1 1]);
v.graphText = text(0.1, 0.0 , 'xxxx', 'Color', 'b', 'FontName', 'Arial','FontSize', 24);
v.pHitLine = line([0 1],[0.5 0.5]); %v.pFA = 0.5;
v.pFALine = line([0.5 0.5],[0.05 1]);
v.d = 0;
v.beta = 0;
v.lastResponseCorrect = true;
guidata(v.hMainFigure,v);%store settings
updateCrosshair(hObject);
%end drawPlot()

function updateCrosshair(hObject)
v = guidata(hObject); %get settings
%if (length(allLines) < 5), return; end;
set(v.pFALine, 'XData', [v.pFA v.pFA]); 
set(v.pHitLine, 'YData', [v.pHit v.pHit]); 
set(v.graphText,'String', sprintf('d=%0.2f, beta=%0.2f', v.d, v.beta));
if v.lastResponseCorrect
    set(v.graphText,'Color', 'g');
else
    set(v.graphText,'Color', 'r');
end
%end updateCrosshair()

function [d,beta] = dprime(pHit,pFA)
%-- Convert to Z scores, no error checking
zHit = norminv(pHit,0,1) ;
zFA  = norminv(pFA,0,1) ;
%-- Calculate d-prime
d = zHit - zFA ;
%-- If requested, calculate BETA
if (nargout > 1)
  yHit = normpdf(zHit) ;
  yFA  = normpdf(zFA) ;
  beta = yHit ./ yFA ;
end
%end dprime()

function pdf = stdnormal_pdf (x)
%http://www.dynare.org/dynare-matlab-m2html/matlab/missing/stats/stdnormal_pdf.html
if (nargin ~= 1)
 error('stdnormal_pdf: you should provide one argument');
end
sz = size(x);
pdf = zeros (sz);
k = find (isnan (x));
if (any (k))
 pdf(k) = NaN;
end
k = find (~isinf (x));
if (any (k))
 pdf (k) = (2 * pi)^(- 1/2) * exp (- x(k) .^ 2 / 2);
end
%end stdnormal_pdf
 

function pdf = normpdf (x, m, s)
%http://www.dynare.org/dynare-matlab-m2html/matlab/missing/stats/normpdf.html
if (nargin ~= 1 && nargin ~= 3)
 error('normpdf: you must give one or three arguments');
end
if (nargin == 1)
 m = 0;
 s = 1;
end
if (~isscalar (m) || ~isscalar (s))
 [retval, x, m, s] = common_size (x, m, s);
 if (retval > 0)
     error ('normpdf: x, m and s must be of common size or scalars');
 end
end
sz = size (x);
pdf = zeros (sz);
if (isscalar (m) && isscalar (s))
 if (find (isinf (m) | isnan (m) | ~(s >= 0) | ~(s < Inf)))
     pdf = NaN * ones (sz);
 else
     pdf = stdnormal_pdf ((x - m) ./ s) ./ s;
 end
else
 k = find (isinf (m) | isnan (m) | ~(s >= 0) | ~(s < Inf));
 if (any (k))
     pdf(k) = NaN;
 end
 k = find (~isinf (m) & ~isnan (m) & (s >= 0) & (s < Inf));
 if (any (k))
     pdf(k) = stdnormal_pdf ((x(k) - m(k)) ./ s(k)) ./ s(k);
 end
end
pdf((s == 0) & (x == m)) = Inf;
pdf((s == 0) & ((x < m) | (x > m))) = 0;
%end normpdf()
 
function x = norminv(p,m,s);
%http://fast-toolbox.googlecode.com/svn-history/r2/trunk/innards/norminv.m
% allocate output memory and check size of arguments
x = sqrt(2)*erfinv(2*p - 1).*s + m;  % if this line causes an error, input arguments do not fit.
x((p>1) | (p<0) | isnan(p) | isnan(m) | isnan(s) | (s<0)) = nan;
k = (s==0) & ~isnan(m);		% temporary variable, reduces number of tests.
x((p==0) & k) = -inf;
x((p==1) & k) = +inf;
k = (p>0) & (p<1) & k;
if prod(size(m))==1,
    x(k) = m;
else
    x(k) = m(k);
end
%end norminv()

function processResponse(hObject, respondedPresent)
v = guidata(hObject);
if ~v.WaitingForResponse
    disp('Response ignored: present a new trial');
    return; %no new trial
end;
v.lastResponseCorrect = false;
if respondedPresent
    if v.TargetLastTrial 
        v.Hits = v.Hits+1;
        v.lastResponseCorrect = true;
    else
        v.FalseAlarms = v.FalseAlarms + 1;
    end;
else
    if v.TargetLastTrial 
        v.Misses = v.Misses+1;
    else
        v.CorrectRejection = v.CorrectRejection + 1;
        v.lastResponseCorrect = true;

    end;    
end;
v.WaitingForResponse = false;
set(v.hPresentButton, 'Enable', 'off');
set(v.hAbsentButton, 'Enable', 'off');
guidata(v.hMainFigure,v);%store settings
if ((v.Hits+v.Misses)==0) || ((v.CorrectRejection+v.FalseAlarms)==0)
    disp('Acquire more trials to compute d-prime');
end;
if ((v.Hits+v.Misses)==0)
    v.pHit = 0.5
else %calculate proportion hits
    v.pHit = v.Hits/ (v.Hits+v.Misses);
end

if ((v.CorrectRejection+v.FalseAlarms)==0) 
   v.pFA = 0.5; 
else %calculate proportion false alarm
    v.pFA = v.FalseAlarms/(v.CorrectRejection+v.FalseAlarms);
end;
[v.d,v.beta] = dprime(v.pHit,v.pFA);
guidata(v.hMainFigure,v);%store settings
updateCrosshair(hObject)
%end processResponse()

function presentResponse_Callback(hObject, eventdata)
    processResponse(hObject, true);
%end presentResponse_Callback()

function absentResponse_Callback(hObject, eventdata)
    processResponse(hObject, false);
%end presentResponse_Callback()

function ClearTrials_Callback(hObject, eventdata)
v = guidata(hObject);
v.Hits = 0;
v.FalseAlarms = 0;
v.Misses = 0;
v.CorrectRejection = 0;
v.pFA = 0.5;
v.pHit = 0.5;
v.TargetLastTrial = false;
v.WaitingForResponse = false;
set(v.hPresentButton, 'Enable', 'off');
set(v.hAbsentButton, 'Enable', 'off');
guidata(v.hMainFigure,v);%store settings
%end ClearTrials_Callback()

function AboutMenu_Callback(hObject, eventdata)
v = guidata(hObject)
msgbox(v.AboutVersionString,'About');
%end AboutMenu_Callback()

% --- Show/Hide Figure Toolbar
function ToolbarMenu_Callback(hObject, eventdata)
if strcmpi(get(gcf, 'Toolbar'),'none')
    set(gcf,  'Toolbar', 'figure');
else
    set(gcf,  'Toolbar', 'none');
end
%end ToolbarMenu_Callback()

function setIntensity_Callback(hObject, eventdata)
v = guidata(hObject); %get settings
prompt = {'Sound intensity (0..100):', 'Sound frequency (Hz)', 'Sound duration (s)'};
dlg_title = 'Values for adjusting the image(s)';
num_lines = 1;
def = {int2str(v.Intensity),int2str(v.Hz),num2str(v.Duration) };
answer = inputdlg(prompt,dlg_title,num_lines,def);
v.Intensity = str2num(answer{1});
v.Hz = str2num(answer{2});
v.Duration = str2num(answer{3});
guidata(v.hMainFigure,v);%store settings
playSound(hObject);
%end setIntensity_Callback()

function playSound(hObject)
v = guidata(hObject); %get settings
if (v.Intensity == 0) || (v.Duration <= 0)
    return;
end
lSampleRate = 44100;%sample rate in Hz
lnSamples = lSampleRate * v.Duration;
lSamples = (1:lnSamples)/ lSampleRate;
lWav = (v.Intensity/100) *sin(2*pi* v.Hz * lSamples);
sound(lWav, lSampleRate);
% end playSound()
    
function nextTrial_Callback(hObject, eventdata)
v = guidata(hObject); %get settings
if ~v.WaitingForResponse %repeat trial
    v.TargetLastTrial = rand() > 0.5;
    set(v.hPresentButton, 'Enable', 'on');
    set(v.hAbsentButton, 'Enable', 'on');
end;
v.WaitingForResponse = true;
guidata(v.hMainFigure,v);%store settings
if (v.TargetLastTrial)
    playSound(hObject);
end;
%end presentTrial_Callback()

% -- save screenshot to selected filename
function saveBitmap_Callback(hObject, eventdata)
%user requested to specify filename so image can be saved as bitmap
[file,path] = uiputfile('*.png','Save image as');
if isequal(file,0), return; end;
saveBitmap(guidata(hObject),[path file]);
%end saveBitmap_Callback()

% --- copy bitmap to clipboard
function copyBitmap_Callback(hObject, eventdata)
copyBitmap (guidata(hObject));
%end copyBitmapUI()

% --- executed when the form closes
function DeleteFigure_Callback(~, ~)
%disp('goodbye'); %nothing to do, variables automatically released
%end DeleteFigure_Callback()
