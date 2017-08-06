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

%% Tesing to see if Github is working

%% Set Front Page
% Set tabs and tab labels
NumTabs = 4; % will have 4 tabs
TabLabels = {'Inputs';'Outputs';'Graphs';'Interesting'};
% Get user screen size
% Size of primary display, returned as a four-element vector of the form [left bottom width height].
set(0,'units','pixels');
ScreenSize = get(0, 'ScreenSize') % SC will be an array of [u v x y]
MaxMonitorwidth = ScreenSize(3);
MaxMonitorheight = ScreenSize(4);
% Set figure window size
FigScale = .5; % adjustable parameter for changing figure size
MaxWindowX = round(MaxMonitorwidth*FigScale);
MaxWindowY = round(MaxMonitorheight*FigScale);
Xorigin = (MaxMonitorwidth-MaxWindowX)/2;
Yorigin = (MaxMonitorheight-MaxWindowY)/2;

% TabOffset = 0; % This value offsets the tabs inside the figure.
% ButtonHeight = 60;
% PanelHeight = MaxWindowY-ButtonHeight;
% ButtonWidth = round(MaxWindowX/NumTabs);%
% PanelWidth = MaxWindowX;
% Set colour variables
white = [1 1 1];
grey = 0.9*white;
%% Create the figure
hTabFig = figure(...
'Units','pixels',...
'Toolbar','none',...
'Position', [Xorigin Yorigin MaxWindowX MaxWindowY],...
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

% %% Define a cell array for panels and pushbutton handles, pushbutton labels and more
% TabHandles = cell(NumTabs,3); % rows are for eah tab + 2 additional data rows
% TabHandles(:,3) = TabLabels(:,1);
% TabHandles{NumTabs+1,1} = hTabFig; % Main figure handle
% TabHandles{NumTabs+1,2} = PanelWidth; % Width of tab panel
% TabHandles{NumTabs+1,3} = PanelHeight; % Height of tab panel
% TabHandles{NumTabs+2,1} = 0; % Handle to default tab 2 content(set later)
% TabHandles{NumTabs+2,2} = white; % Background color
% TabHandles{NumTabs+2,3} = grey; % Background color
% %% Build the tabs
% for TabNumber = 1:NumTabs
% TabHandles{TabNumber,1} = uipanel('Units','pixels',...
% 'Visible','off','BackgroundColor',white,'BorderWidth',1,...
% 'Position',[TabOffset TabOffset PanelWidth PanelHeight]);
% TabHandles{TabNumber,2} = uicontrol('Style','pushbutton',...
% 'Units','pixels','BackgroundColor',grey,...
% 'Position',[TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset...
% ButtonWidth ButtonHeight],'string',TabHandles{TabNumber,3},...
% 'HorizontalAlignment','center','FontName','arial','FontWeight','bold',...
% 'FontSize',10);
% end

% %% Define the callbacks for the Tab Buttons
% for CountTabs = 1:NumTabs
% set(TabHandles{CountTabs,2},'callback',{@TabSelectCallback,CountTabs});
% end


%% Create an entry button

% Create a text box to display the calculated setting 
enter_gui_button = uicontrol('Units', 'normalized', 'Position',[0.4 0.4 0.2 0.1], 'Style', 'text',...
    'String', 'Enter Solar Calculator', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 30, 'Visible', 'ON');

%% Working Setup for Menu
%Setup label text for popupmenu
KW_popupmenu_label = uicontrol('Units', 'normalized', 'Position', [0.4 0.3 0.2 0.05], 'Style', 'text',...
    'String', '(KW) Kilowatt', 'tag', 'label_for_EW', 'FontSize', 12);
%Set up Pull down data
KW_discrete_data = [0 3.5 5 7 9 15];
%Set up pop up menu with pulldown data
KW_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.4 0.2 0.2 0.1], 'Style', 'popupmenu',...
    'String', KW_discrete_data,'Callback', @display_selected_data, 'tag', 'KW_menu');
%Display the chosen variable data in a text box next to the popupmenu
KW_display = uicontrol('Units', 'Normalized', 'Position', [0.4 0.2 0.2 0.05],'String', 'Select KW', 'Style', 'text',...
    'tag', 'KW_selection', 'Callback', @display_selected_data);
%Set up function callback
    function display_selected_data(hObject, eventdata)
       % Select the tag of each chosen object
        string = get(hObject, 'tag')
        % Get the value of each object from the vector of discrete values
        index = get(hObject, 'Value')  
%Find which popupmenu was selected and update the variable display box
            if strcmp(string, 'KW_menu')
                % Display the new value
                set(KW_display, 'String', num2str(KW_discrete_data(index)))
%                  KW_value = (KW_discrete(index));
            end
    end











end