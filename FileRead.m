function varargout = FileRead(varargin)
% FILEREAD MATLAB code for FileRead.fig
%      FILEREAD, by itself, creates a new FILEREAD or raises the existing
%      singleton*.
%
%      H = FILEREAD returns the handle to a new FILEREAD or the handle to
%      the existing singleton*.
%
%      FILEREAD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILEREAD.M with the given input arguments.
%
%      FILEREAD('Property','Value',...) creates a new FILEREAD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FileRead_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileRead_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FileRead

% Last Modified by GUIDE v2.5 28-Dec-2021 22:56:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileRead_OpeningFcn, ...
                   'gui_OutputFcn',  @FileRead_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before FileRead is made visible.
function FileRead_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileRead (see VARARGIN)

% Choose default command line output for FileRead
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FileRead wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FileRead_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% ** this button is for select a file and see sample of its data******
%------------------------------------
% --- Executes on button press in selectButton.
function selectButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.*'}, 'File Selector');
global globl_filename;
globl_filename= filename;
fullpathname = strcat(pathname, filename);
text = fileread(fullpathname);      % reading information inside the file
set(handles.text4, 'String', fullpathname); % showing full path name
set(handles.text5, 'String', text); % showing information


% *** this button is for ploting the dta whether the file is txt or mat***
%------------------------------------
% --- Executes on button press in plotbutton.
function plotbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global globl_filename;
[fPath, fName, fExt] = fileparts(globl_filename);
switch lower(fExt)
     % .txt file
     case '.txt'
        data = importdata(globl_filename);
        x = data(:, 1);
        y = data(:, 2);
        plot(x, y, 'b-', 'LineWidth',0.01);
        title('ECG Signal', 'FontSize', 15);
        xlabel('Time', 'FontSize', 10);
        ylabel('Voltage', 'FontSize', 10);
        grid on;
        
    % .mat file    
     case '.mat'
        val = importdata(globl_filename);
        ECGsignal = (val - 0)/200;  %(val - base)/gain (we got them from info file with the downloaded data)
        fs = 360;                    % Sampling frequency
        n = length(ECGsignal);
        t = (0 : n-1)/fs;
        plot(t, ECGsignal);
 
  otherwise  
    error('Unexpected file extension: %s', fExt);
end


% --- Executes on button press in calcButton.
function calcButton_Callback(hObject, eventdata, handles)
% hObject    handle to calcButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global globl_filename;
sig = importdata(globl_filename);

% Remove trend from data
detrendedECG = detrend(sig);

beat_count = 0;

for k = 2 : length(sig)-1
    if(sig(k) > sig(k-1) && sig(k) > sig(k+1) && sig(k) > 1)
        beat_count = beat_count + 1;
    end
end

% Divide the beats counted by the signal duration
fs = 360;                  % Sampling frequency
N = length(detrendedECG);

duration_in_seconds = N/fs;
PPS_avg = beat_count/duration_in_seconds;

duration_in_minutes = duration_in_seconds/60;
BPM_avg = beat_count/duration_in_minutes;
set(handles.res_in_sec, 'String', PPS_avg); % showing pulse per second
set(handles.res_per_min, 'String', BPM_avg); % showing beats per minute
global pulse;
pulse=BPM_avg;


% Detect any myocardial dysfunction
% --- Executes on button press in myodys.
function myodys_Callback(hObject, eventdata, handles)
% hObject    handle to myodys (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pulse;

   if pulse >100
        set(handles.notification, 'String', "This Patient has a (Tachycardia) as heart rate is above 100 beats a minute");
   elseif pulse < 60 
       set(handles.notification, 'String', "This Patient has a (bradycardia) as heart rate is below 60 beats a minute");
   else
       set(handles.notification, 'String', "This Person is normal and there is no problem");
   end
    
