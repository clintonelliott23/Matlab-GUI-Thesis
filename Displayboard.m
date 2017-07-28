function solar_display
%This is to be the home screen
%% Initial clearing
clear all
close all
clc
%This function docks the figures...
set(0,'DefaultFigureWindowStyle','normal') 
... *reverse by using "normal"
set(0,'DefaultFigureVisible','on');

%% Set Front Page and is home page
% Set tabs and tab labels
NumTabs = 4; % will have 7 tabs
TabLabels = {'Inputs';'Outputs';'Graphs';'Interesting'};
% Get user screen size
SC = get(0, 'ScreenSize') % SC will be an array of [1 1 Width Height]
MaxMonitorwidth = SC(3);
MaxMonitorheight = SC(4);
% Set figure window size
MainFigScale = .6; % adjustable parameter for changing figure size
MaxWindowX = round(MaxMonitorwidth*MainFigScale);
MaxWindowY = round(MaxMonitorheight*MainFigScale);
Xorigin = (MaxMonitorwidth-MaxWindowX)/2
Yorigin = (MaxMonitorheight-MaxWindowY)/2


TabOffset = 2; % This value offsets the tabs inside the figure.
ButtonHeight = 80;
PanelWidth = MaxWindowX-TabOffset+4;
PanelHeight = MaxWindowY-ButtonHeight;
ButtonWidth = round((PanelWidth-2*NumTabs)/NumTabs);
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

% Consumption and expense profiles:
% axes(consumption_ax);
% [cons_ax1,c2,c1] = plotyy(x1,y3,x1,y1,'bar','plot');
% xlabel('Time of day [hr]','FontWeight','bold');
% ylabel(cons_ax1(2),'Hourly Consumption [kWh]','FontWeight', 'bold');
% ylabel(cons_ax1(1),'Hourly Cost [$]','FontWeight', 'bold');
% set(cons_ax1, 'xlim', [0 24]);
% set(cons_ax1, 'xtick', [0:1:24]);
% set(cons_ax1, 'FontSize', 7.5);
% set(cons_ax1(1), 'YColor', [0.95 0 0]);
% set(cons_ax1(1), 'ytick', [0:0.05:0.2]);
% set(cons_ax1(2), 'YColor', [0 0 0.65]);
% set(cons_ax1(2), 'XColor', [0 0 0.65]);
% Martel Electric Vehicle Display Board
% 94
% set(cons_ax1(1), 'XColor', [0 0 0.65]);
% set(cons_ax1(2), 'ytick', [0:0.1:0.6]);
% set(cons_ax1(2), 'ygrid', 'on');
% set(c2, 'BarWidth', 1);
% set(c2, 'FaceColor', [0.95 0 0]);
% set(c1, 'Color', [0 0 0.65]);
% set(c1, 'LineWidth', 2);
% set(cons_ax1,'Visible','off');
% set(c1,'Visible','off');
% set(c2,'Visible','off');
% % Tariff graph:
% axes(price_ax);
% dgf = bar(x1,y22,1);
% xlabel('Time of day [hr]','FontWeight','bold');
% ylabel('Electricity Price [cents/kWh]','FontWeight', 'bold');
% set(gca, 'xlim', [0 24]);
% set(gca, 'ylim', [0 40]);
% set(gca, 'xtick', [0:1:24]);
% set(gca, 'ytick', [0:5:40]);
% set(gca, 'ygrid', 'on');
% set(gca, 'YColor', [0 0.4 0]);
% set(gca, 'XColor', [0 0.4 0]);
% set(dgf, 'FaceColor', [0 0.7 0]);
% set(price_ax,'Visible','off');
% set(get(price_ax,'children'),'Visible','off');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define content for Smart Home Tab
% Create two sub-tabs within smart home page
home_tabs = 2;
home_labels = {'Household Consumption';'Home Area Connection'};
TabHandles2 = cell(home_tabs,2);
TabHandles2(:,2) = home_labels(1:home_tabs,1);
for tabnumber = 1:home_tabs
% Create pushbuttons
TabHandles2{tabnumber,1} = uicontrol('Style', 'pushbutton',...
'Parent', TabHandles{4,1},'Units', 'pixels',...
'Position', [5 465+(tabnumber-1)*(55) 200 45],...
'String', TabHandles2(tabnumber,2),...
'FontName', 'arial','FontWeight', 'bold','FontSize', 9);
end
set(TabHandles2{2,1}, 'Backgroundcolor', 'white');
netshow = 1; % variable for displaying home network in smart home tab
set(TabHandles2{2,1}, 'Callback', {@connect_callback});
set(TabHandles2{1,1}, 'Callback', {@home_callback});

%%%%%%%%%%%%%%%%%%%%% HOME AREA CONNECTION TAB %%%%%%%%%%%%%%%%%%%%%%%%%
% SMART METER
meterb = uicontrol('Style', 'pushbutton',...
'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...
'Units','pixels','Position',[540 330 150 50],...
'String','SMART METER','Visible','on',...
'ForegroundColor', [1 1 1],...
'FontName','arial','FontWeight','bold','FontSize',10);
% HOUSEHOLD
homeb = uicontrol('Style', 'pushbutton',...
'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...
'Units','pixels','Position',[540 450 155 50],...
'String','HOUSEHOLD','Visible','on',...
'ForegroundColor', [1 1 1],...
'FontName','arial','FontWeight','bold','FontSize',10);
% BATTERY
batb = uicontrol('Style', 'pushbutton',...
'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...
'Units','pixels','Position',[340 415 155 50],...
'String','BATTERY SYSTEM','Visible','on',...
'ForegroundColor', [1 1 1],...
'FontName','arial','FontWeight','bold','FontSize',10);
% RENEWABLE SOURCE
renb = uicontrol('Style', 'pushbutton',...
'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...
'Units','pixels','Position',[420 215 155 50],...
'String','RENEWABLE SOURCE','Visible','on',...
'ForegroundColor', [1 1 1],...
'FontName','arial','FontWeight','bold','FontSize',10);
% CHARGE STATION
chargb = uicontrol('Style', 'pushbutton',...
'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...
'Units','pixels','Position',[660 215 155 50],...
'String','CHARGING STATION','Visible','on',...
'ForegroundColor', [1 1 1],...
'FontName','arial','FontWeight','bold','FontSize',10);
% EV DISPLAY
dispb = uicontrol('Style', 'pushbutton',...
'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...
'Units','pixels','Position',[740 415 155 50],...
'String','IN-VEHICLE DISPLAY','Visible','on',...
'ForegroundColor', [1 1 1],...
'FontName','arial','FontWeight','bold','FontSize',10);
