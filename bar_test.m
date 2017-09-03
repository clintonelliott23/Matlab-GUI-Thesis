  
%% Initial clearing 
clear all 
close all 
clc 
  
%% Set up 
% Set tabs and tab labels 
NumTabs = 4;    % will have 7 tabs 
TabLabels = {'Home';'Battery';'Schedule';'Smart Home'}; 
  
% Get user screen size 
SC = get(0, 'ScreenSize');  % SC will be an array of [u v x y] 
MaxMonitorX = SC(3); 
MaxMonitorY = SC(4); 
  
% Set figure window size 
MainFigScale = .8;   % adjustable parameter for changing figure size 
MaxWindowX = round(MaxMonitorX*MainFigScale); 
MaxWindowY = round(MaxMonitorY*MainFigScale); 
XBorder = (MaxMonitorX-MaxWindowX)/2; 
YBorder = (MaxMonitorY-MaxWindowY)/2;  
TabOffset = 0;              % This value offsets the tabs inside the figure. 
ButtonHeight = 40; 
PanelWidth = MaxWindowX-2*TabOffset+4; 
PanelHeight = MaxWindowY-ButtonHeight-2*TabOffset; 
ButtonWidth = round((PanelWidth-NumTabs)/NumTabs); 
  
% Set colour variables 
white = [1 1 1]; grey = 0.9*white; 
  
%% Create the figure 
hTabFig = figure(... 
    'Units','pixels',... 
    'Toolbar','none',... 
    'Position', [XBorder,YBorder,MaxWindowX,MaxWindowY],... 
    'NumberTitle','off',... 
    'Name','EV Board Simulator',... 
    'MenuBar','none',... 
    'Resize','off',... 
    'DockControls','off',... 
    'Color',white); 
  
%% Define a cell array for panels and pushbutton handles, pushbutton labels and more 
TabHandles = cell(NumTabs,3);   % rows are for eah tab + 2 additional data rows 
TabHandles(:,3) = TabLabels(:,1); 
  
TabHandles{NumTabs+1,1} = hTabFig;         % Main figure handle 
TabHandles{NumTabs+1,2} = PanelWidth;      % Width of tab panel 
TabHandles{NumTabs+1,3} = PanelHeight;     % Height of tab panel 
TabHandles{NumTabs+2,1} = 0;               % Handle to default tab 2 content(set later) 
TabHandles{NumTabs+2,2} = white;           % Background color 
TabHandles{NumTabs+2,3} = grey;            % Background color 
  
%% Build the tabs 
     for TabNumber = 1:NumTabs 
        TabHandles{TabNumber,1} = uipanel('Units','pixels',... 
            'Visible','off','BackgroundColor',white,'BorderWidth',1,...
            'Position',[1 0 PanelWidth PanelHeight]); 

        TabHandles{TabNumber,2} = uicontrol('Style','pushbutton',... 
            'Units','pixels','BackgroundColor',grey,...         
            'Position',[TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset... 
            ButtonWidth ButtonHeight],'string',TabHandles{TabNumber,3},... 
                'HorizontalAlignment','center','FontName','arial','FontWeight','bold ',... 
                'FontSize',10); 
     end  

    %% Define the callbacks for the Tab Buttons 
    for CountTabs = 1:NumTabs 

    set(TabHandles{CountTabs,2},'callback',{@TabSelectCallback,CountTabs}); 
    
    end 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position', [368 452 355 25],'string', 'CHARGING',... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     
    'FontName', 'arial','FontWeight', 'bold','FontSize', 14); 
charge_info = [ 1 9 3]

cstat = uitable('Position',[368 255 355 195],'Parent', TabHandles{1,1},...   
'Data',charge_info,'RowName',[],'ColumnName',[],'FontSize',12,... 
    'ColumnWidth',{151 81 121}); 
  

%Set up pop up menu with pulldown data for states
state_codes = [4814 4825 0800 6000 3000 7000 2000 4000];
state_names = ["Townsville, QLD", "Mount Isa, QLD", "Darwin, NT","Perth, WA", "Melbourne, VIC",...
    "Horbart, TAS", "Sydney, NSW", "Brisbane, QLD"];

