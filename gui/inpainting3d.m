function varargout = inpainting3d(varargin)
% INPAINTING3D MATLAB code for inpainting3d.fig
%      INPAINTING3D, by itself, creates a new INPAINTING3D or raises the existing
%      singleton*.
%
%      H = INPAINTING3D returns the handle to a new INPAINTING3D or the handle to
%      the existing singleton*.
%
%      INPAINTING3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPAINTING3D.M with the given input arguments.
%
%      INPAINTING3D('Property','Value',...) creates a new INPAINTING3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inpainting3d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inpainting3d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inpainting3d

% Last Modified by GUIDE v2.5 01-Oct-2011 18:24:34

% add main folder containing all the files
addpath(fileparts(which(mfilename)));
addpath(fullfile(fileparts(which(mfilename)), 'inpainting3d'));

% if GUI already running, then exit
set(0, 'showhiddenhandles','on');
p = findobj('tag','inpainting3d_gui','parent',0);
set(0,'showhiddenhandles','off');
if ishandle(p)
    delete(p);
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inpainting3d_OpeningFcn, ...
                   'gui_OutputFcn',  @inpainting3d_OutputFcn, ...
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


% --- Executes just before inpainting3d is made visible.
function inpainting3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inpainting3d (see VARARGIN)

% Choose default command line output for inpainting3d
handles.output = hObject;

% disallow figure to have dockacble controls
set(hObject, 'DockControls','off');

% add any paths required for running the GUI
addpath(fullfile(fileparts(which(mfilename)), '..','make3d'));
addpath(fullfile(fileparts(which(mfilename)), '..','criminisi_inpainting'));

% init user params
handles = globalDataUtils('setUserDataDefaults', handles);

% init GUI params
handles = globalDataUtils('guiDataDefaults', handles);

% init the GUI
handles = globalGuiUtils('initGui', handles, hObject, eventdata);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes inpainting3d wait for user response (see UIRESUME)
% uiwait(handles.inpainting3d_gui);


% --- Outputs from this function are returned to the command line.
function varargout = inpainting3d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
