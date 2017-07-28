function solar_gui()
%% Script for Solar GUI Display

%% Initial clearing
clear all
close all
clc
%This function docks the figures...
set(0,'DefaultFigureWindowStyle','normal') 
... *reverse by using "normal"
set(0,'DefaultFigureVisible','on');



%% Set Front Page
% Set tabs and tab labels
NumTabs = 4; % will have 4 tabs
TabLabels = {'Inputs';'Outputs';'Graphs';'Interesting'};
% Get user screen size
% Size of primary display, returned as a four-element vector of the form [left bottom width height].
ScreenSize = get(0, 'ScreenSize') % SC will be an array of [u v x y]
MaxMonitorwidth = ScreenSize(3);
MaxMonitorheight = ScreenSize(4);
% Set figure window size
FigScale = .6; % adjustable parameter for changing figure size
MaxWindowX = round(MaxMonitorwidth*FigScale);
MaxWindowY = round(MaxMonitorheight*FigScale);
Xorigin = (MaxMonitorwidth-MaxWindowX)/2;
Yorigin = (MaxMonitorheight-MaxWindowY)/2;
TabOffset = 0; % This value offsets the tabs inside the figure.
ButtonHeight = 60;
PanelHeight = MaxWindowY-ButtonHeight;
ButtonWidth = round(MaxWindowX/NumTabs);
PanelWidth = MaxWindowX;
% Set colour variables
white = [1 1 1];
grey = 0.9*white;
%% Create the figure
hTabFig = figure(...
'Units','pixels',...
'Toolbar','none',...
'Position', [Xorigin,Yorigin,MaxWindowX,MaxWindowY],...
'NumberTitle','off',...
'Name','Solar Calculator',...
'MenuBar','none',...
'Resize','off',...
'DockControls','off',...
'Color',white);

%% Back Ground
% (1)Create axis which covers the entire GUI workspace
background_picture = axes('unit', 'pixels', 'position', [1,1,MaxWindowX,MaxWindowY]); 
% (2)import the background image and show it on the axes
background_image = imread('homepage_solar_background.jpg'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');


%% Define a cell array for panels and pushbutton handles, pushbutton labels and more
TabHandles = cell(NumTabs,3); % rows are for eah tab + 2 additional data rows
TabHandles(:,3) = TabLabels(:,1);
TabHandles{NumTabs+1,1} = hTabFig; % Main figure handle
TabHandles{NumTabs+1,2} = PanelWidth; % Width of tab panel
TabHandles{NumTabs+1,3} = PanelHeight; % Height of tab panel
TabHandles{NumTabs+2,1} = 0; % Handle to default tab 2 content(set later)
TabHandles{NumTabs+2,2} = white; % Background color
TabHandles{NumTabs+2,3} = grey; % Background color
%% Build the tabs
for TabNumber = 1:NumTabs
TabHandles{TabNumber,1} = uipanel('Units','pixels',...
'Visible','off','BackgroundColor',white,'BorderWidth',1,...
'Position',[TabOffset TabOffset PanelWidth PanelHeight]);
TabHandles{TabNumber,2} = uicontrol('Style','pushbutton',...
'Units','pixels','BackgroundColor',grey,...
'Position',[TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset...
ButtonWidth ButtonHeight],'string',TabHandles{TabNumber,3},...
'HorizontalAlignment','center','FontName','arial','FontWeight','bold',...
'FontSize',10);
end

%% Define the callbacks for the Tab Buttons
for CountTabs = 1:NumTabs
set(TabHandles{CountTabs,2},'callback',{@TabSelectCallback,CountTabs});
end


%% Create an entry button

% Create a text box to display the calculated setting 
enter_gui_button = uicontrol('Units', 'pixels', 'Position',[Xorigin Yorigin PanelWidth/3 PanelHeight/4], 'Style', 'text', 'String', 'Enter Solar Calculator', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 30, 'Visible', 'ON');













end