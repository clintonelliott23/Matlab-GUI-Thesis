function solar_gui()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Script for Solar GUI Display %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial Clearing
clear all
close all
clc
%This function docks the figures...
set(0,'DefaultFigureWindowStyle','normal') 
... *reverse by using "normal"
set(0,'DefaultFigureVisible','on');

%%   Set up some varables
%   First clear everything
        clear all
        clc
 
%% Load Essential Data and Updates
% NASA Data
solar_psh_data = importdata('kwh_day_avg_month_nasa.mat');
       
        
   %% Find Screen Size and Calculate Window
% Size of primary display, returned as a four-element vector of the form [left bottom width height].
set(0,'units','pixels');
ScreenSize = get(0, 'ScreenSize') % SC will be an array of [u v x y]
MaxMonitorwidth = ScreenSize(3);
MaxMonitorheight = ScreenSize(4);
% Set figure window size
FigScale = 0.6; % adjustable parameter for changing figure size
% Get user screen size
MaxWindowX = round(MaxMonitorwidth*FigScale);
MaxWindowY = round(MaxMonitorheight*FigScale);
Xorigin = (MaxMonitorwidth-MaxWindowX)/2;
Yorigin = (MaxMonitorheight-MaxWindowY)/2;
%Set Color
white = [1 1 1];
grey = 0.9*white;
        
%   Set Number of tabs and tab labels.  Make sure the number of tab labels
%   match the HumberOfTabs setting.
        NumTabs = 4;               % Number of tabs to be generated
        TabLabels = {'Data Aquisition'; 'Input Data'; 'Estimated Production'; 'Finance Options';};
        if size(TabLabels,1) ~= NumTabs
            errordlg('Number of tabs and tab labels must be the same','Setup Error');
            return
        end
        
%   Get user screen size
        SC = get(0, 'ScreenSize');
        MaxMonitorX = SC(3);
        MaxMonitorY = SC(4);
        
 %   Set the figure window size values
        MainFigScale = .8;          % Change this value to adjust the figure size
        MaxWindowX = round(MaxMonitorX*MainFigScale);
        MaxWindowY = round(MaxMonitorY*MainFigScale);
        XBorder = (MaxMonitorX-MaxWindowX)/2;
        YBorder = (MaxMonitorY-MaxWindowY)/2; 
        TabOffset = 0;              % This value offsets the tabs inside the figure.
        ButtonHeight = 40;
        PanelWidth = MaxWindowX-2*TabOffset+4;
        PanelHeight = MaxWindowY-ButtonHeight-2*TabOffset;
        ButtonWidth = round((PanelWidth-NumTabs)/NumTabs);
                
 %   Set the color varables.  
        White = [1  1  1];            % White - Selected tab color     
        BGColor = .9*White;           % Light Grey - Background color
            
%%   Create a figure for the tabs
        hTabFig = figure(...
            'Units', 'pixels',...
            'Toolbar', 'none',...
            'Position',[ XBorder, YBorder, MaxWindowX, MaxWindowY ],...
            'NumberTitle', 'off',...
            'Name', 'Solar Calculator',...
            'MenuBar', 'none',...
            'Resize', 'off',...
            'DockControls', 'off',...
            'Color', White);
    
%%   Define a cell array for panel and pushbutton handles, pushbuttons labels and other data
    %   rows are for each tab + two additional rows for other data
    %   columns are uipanel handles, selection pushbutton handles, and tab label strings - 3 columns.
            TabHandles = cell(NumTabs,3);
            TabHandles(:,3) = TabLabels(:,1);
    %   Add additional rows for other data
            TabHandles{NumTabs+1,1} = hTabFig;         % Main figure handle
            TabHandles{NumTabs+1,2} = PanelWidth;      % Width of tab panel
            TabHandles{NumTabs+1,3} = PanelHeight;     % Height of tab panel
            TabHandles{NumTabs+2,1} = 0;               % Handle to default tab 2 content(set later)
            TabHandles{NumTabs+2,2} = White;           % Selected tab Color
            TabHandles{NumTabs+2,3} = BGColor;         % Background color
            
%%   Build the Tabs
        for TabNumber = 1:NumTabs
        % create a UIPanel   
            TabHandles{TabNumber,1} = uipanel('Units', 'pixels', ...
                'Visible', 'off', ...
                'Backgroundcolor', White, ...
                'BorderWidth',1, ...
                'Position', [TabOffset TabOffset ...
                PanelWidth PanelHeight]);

        % create a selection pushbutton
            TabHandles{TabNumber,2} = uicontrol('Style', 'pushbutton',...
                'Units', 'pixels', ...
                'BackgroundColor', BGColor, ...
                'Position', [TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset...
                    ButtonWidth ButtonHeight], ...          
                'String', TabHandles{TabNumber,3},...
                'HorizontalAlignment', 'center',...
                'FontName', 'arial',...
                'FontWeight', 'bold',...
                'FontSize', 10);

        end

%%   Define the callbacks for the Tab Buttons
%   All callbacks go to the same function with the additional argument being the Tab number
        for CountTabs = 1:NumTabs
            set(TabHandles{CountTabs,2}, 'callback', ...
                {@TabSellectCallback, CountTabs});
        end

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 1 content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
prompt_page = 1;    



%% Create an Entry Button

% Create a button to enter calculator
enter_gui_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Enter Solar Calculator', 'Visible', 'On','Callback', @entry_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor',grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% Create function for entry
    function entry_click(hObject, eventdata)
                set(enter_gui_button,'Visible','OFF') 
                set(gas_mains_question,'Visible','ON') 
                set(button_yes_gas_mains,'Visible','ON') 
                set(button_no_gas_mains,'Visible','ON')  
   
               set(prefill_button,'Visible','On') 
    end



%% Gas Question
gas_mains_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Do you have gas connected mains?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_gas_mains = uicontrol('Units', 'normalized', 'Position',[0.1 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @gas_click,'Parent', TabHandles{prompt_page,1},'tag', 'gas_yes',...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% persistent gas mains;
% Create button if has exisiting solar
button_no_gas_mains = uicontrol('Units', 'normalized', 'Position',[0.6 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @gas_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


% Create function for entry
    function gas_click(hObject, eventdata)
                set(gas_mains_question,'Visible','Off') 
                set(button_yes_gas_mains,'Visible','Off') 
                set(button_no_gas_mains,'Visible','Off')                
        
                % Find the answer
                string = get(hObject, 'tag');               
                if strcmp(string, 'gas_yes') == 1
                gas_mains = 1
                set(gas_main_value, 'String', 'Yes')
                else
                 gas_mains = 0   
                end
                
                set(pool_question,'Visible','ON') 
                set(button_yes_pool,'Visible','ON') 
                set(button_no_pool,'Visible','ON')  
    end

%% Pool Question
pool_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Do you have a pool?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_pool = uicontrol('Units', 'normalized', 'Position',[0.1 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @pool_click,'Parent', TabHandles{prompt_page,1},'tag', 'pool_yes',...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_pool = uicontrol('Units', 'normalized', 'Position',[0.6 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @pool_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


% Create function for entry
    function pool_click(hObject, eventdata)
                set(pool_question,'Visible','Off') 
                set(button_yes_pool,'Visible','Off') 
                set(button_no_pool,'Visible','Off')                
  
              % Find the answer
                string = get(hObject, 'tag');               
                if strcmp(string, 'pool_yes') == 1
                pool_connected = 1
                set(pool_value, 'String', 'Yes')
                else
                 pool_connected = 0   
                end 
                
                set(text_solar_question,'Visible','ON') 
                set(button_yes_solar,'Visible','ON') 
                set(button_no_solar,'Visible','ON')  
    end

%% Solar Question
text_solar_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Do you have a Solar System?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


% Create button if has exisiting solar
button_yes_solar = uicontrol('Units', 'normalized', 'Position',[0.1 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @solar_click_yes, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_solar = uicontrol('Units', 'normalized', 'Position',[0.6 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @solar_click_no, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


%% Solar "YES" what is the size
    function solar_click_yes(hObject, eventdata)
                set(text_solar_question,'Visible','OFF') 
                set(button_yes_solar,'Visible','OFF') 
                set(button_no_solar,'Visible','OFF')
                solar_installed = 1

                set(solar_size_question,'Visible','ON') 
                set(KW_popupmenu,'Visible','ON')      
    end

solar_size_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'What is the size of your Solar System (KW)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

persistent index;
    function size_next_button(hObject, eventdata)
                set(solar_size_next_button,'Visible','ON')
                index = get(hObject, 'Value');         
                solar_size_input = KW_solar_size(index) 
                set(solar_size_value, 'String', num2str(KW_solar_size(index)))

    end


KW_solar_size = [1 3.5 5 7 9 15];

%Set up pop up menu with pulldown data
KW_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu',...
    'String', KW_solar_size,'Callback', @size_next_button, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);


% Create button if has exisiting solar
solar_size_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'On','Callback', @cost_display, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function cost_display(hObject, eventdata)
                set(solar_size_next_button,'Visible','off') 
                set(KW_popupmenu,'Visible','off')                
                set(solar_size_question,'Visible','off')

                set(cost_solar_question,'Visible','ON') 
                set(cost_popupmenu,'Visible','ON')               
    end

%% How much did ya solar cost bra
cost_solar_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'How much did your solar system cost ($)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

    function cost_next_button_call(hObject, eventdata)
                set(cost_next_button,'Visible','ON') 
                                                             
                index = get(hObject, 'Value');         
                cost_solar_input = solar_cost(index) 
                set(solar_cost_value, 'String', num2str(KW_solar_size(index)))               
    end

solar_cost = [4 5 6 7 8 9 10 11 13 14 16];

%Set up pop up menu with pulldown data
cost_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu',...
    'String', solar_cost,'Callback', @cost_next_button_call, 'tag', 'cost_menu', 'Visible', 'OFF', 'FontSize', 20);


% Create button if has exisiting solar
cost_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'Off','Callback', @solar_click_no,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

%% Battery
  % Create function for battery question
    function solar_click_no(hObject, eventdata)
                set(text_solar_question,'Visible','OFF') 
                set(button_yes_solar,'Visible','OFF') 
                set(button_no_solar,'Visible','OFF')       
 
                set(solar_size_value, 'String', '0') 
                set(solar_cost_value, 'String', '0')                  
                
                set(cost_solar_question,'Visible','OFF') 
                set(cost_popupmenu,'Visible','OFF')                
                set(cost_next_button,'Visible','OFF')  
                
                set(text_battery_question,'Visible','ON') 
                set(button_yes_battery,'Visible','ON') 
                set(button_no_battery,'Visible','ON')    
    end   

text_battery_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Do you have a battery?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_battery = uicontrol('Units', 'normalized', 'Position',[0.1 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @battery_click_yes,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_battery = uicontrol('Units', 'normalized', 'Position',[0.6 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @battery_click_no,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function battery_click_yes(hObject, eventdata)
                set(text_battery_question,'Visible','OFF') 
                set(button_yes_battery,'Visible','OFF') 
                set(button_no_battery,'Visible','OFF')
       
                set(battery_size_question,'Visible','ON') 
                set(KWHR_popupmenu,'Visible','ON')      
    end


 battery_size_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'What is the size of your Battery (KWHR)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

KWHR_battery_size = [1 2 4 6 8 12];
%Set up pop up menu with pulldown data

KWHR_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', KWHR_battery_size,'Callback', @display_battery_next_button, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

% Create button if has exisiting solar
battery_size_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'On','Callback', @battery_click_no,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function display_battery_next_button(hObject, eventdata)
                set(battery_size_next_button,'Visible','ON') 
                
                index = get(hObject, 'Value');         
                battery_size_input = KWHR_battery_size(index)
                set(battery_size_value, 'String', num2str(KWHR_battery_size(index)))  
    end

% 
% Create function for battery question
    function battery_click_no(hObject, eventdata)
                set(text_battery_question,'Visible','OFF') 
                set(button_yes_battery,'Visible','OFF') 
                set(button_no_battery,'Visible','OFF')
                
                set(battery_size_question,'Visible','OFF') 
                set(KWHR_popupmenu,'Visible','OFF')      
                set(battery_size_next_button,'Visible','OFF') 
                  
                set(text_roof_question,'Visible','ON') 
                set(tilt_popupmenu,'Visible','ON')                       
    end


%% Create Roof Explanation
% % Create function for roof parameters
text_roof_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'What is the angle of your roof (Degrees)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

roof_tilt = [0 5 10 15 20 25 30 35 40 45];
%Set up pop up menu with pulldown data

tilt_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', roof_tilt,'Callback', @roof_next, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);
   
    function roof_next(hObject, eventdata)
                set(roof_next_button,'Visible','ON')
                                 
                 index = get(hObject, 'Value');         
                 roof_tilt_input = roof_tilt(index) 
    end
 
% Create button if has exisiting solar
roof_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'On','Callback', @roof_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


% Create function for battery question
    function roof_click(hObject, eventdata)
                set(text_roof_question,'Visible','OFF') 
                set(tilt_popupmenu,'Visible','OFF')  
                set(roof_next_button,'Visible','OFF')                             
      
                set(text_orientation_question,'Visible','ON')
                
                set(orientation_next_button,'Visible','On')         
                set(orientation_edit_display,'Visible','On') 
                set(text_orientation_question,'Visible','On')  
                set(compass_image,'Visible','On')                 

                set(radio_north_button,'Visible','On');                set(radio_north_west_button,'Visible','On')    
                set(radio_east_button,'Visible','On');                 set(radio_north_east_button,'Visible','On')  
                set(radio_south_button,'Visible','On');                set(radio_south_east_button,'Visible','On')  
                set(radio_west_button,'Visible','On');                 set(radio_south_west_button,'Visible','On')               
               
    end

%% Roof Orientation
%% Orientation Image

text_orientation_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Which orientation is your roof?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% Load Compass Image
[x,map]=imread('compass.jpg'); I2=imresize(x, [280 300]);
compass_image=uicontrol('style','pushbutton','units','normalized','position',[0.333 0.13 0.33 0.55],'cdata',I2, 'Visible', 'Off','Parent', TabHandles{prompt_page,1});
   
 % Orientations  Major     
radio_north_button = uicontrol('Units', 'normalized', 'Position',[0.52 0.57 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','N'); 

radio_south_button = uicontrol('Units', 'normalized', 'Position',[0.52 0.19 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','S');   

radio_west_button = uicontrol('Units', 'normalized', 'Position',[0.38 0.33 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','W');  

radio_east_button = uicontrol('Units', 'normalized', 'Position',[0.6 0.33 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','E');  
 
% Orientations  Minor  
radio_north_west_button = uicontrol('Units', 'normalized', 'Position',[0.39 0.57 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','NW');      

radio_north_east_button = uicontrol('Units', 'normalized', 'Position',[0.58 0.57 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','NE');   

radio_south_west_button = uicontrol('Units', 'normalized', 'Position',[0.39 0.19 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','SW');  

radio_south_east_button = uicontrol('Units', 'normalized', 'Position',[0.58 0.19 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,'Parent', TabHandles{prompt_page,1},...
    'tag','SE');  

% Create button if has exisiting solar
orientation_next_button = uicontrol('Units', 'normalized', 'Position',[0.67 0.26 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'Off','Callback', @orientation_next,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);

% Create button if has exisiting solar
orientation_edit_display = uicontrol('Units', 'normalized', 'Position',[0.67 0.37 0.3 0.1], 'Style', 'text',...
    'tag','orientation_selection', 'Visible', 'Off',...
    'Backgroundcolor', 'white', 'Foregroundcolor', 'black', 'FontSize', 20);

% Create function for entry
    function orientation_click(hObject, eventdata)
                set(orientation_next_button,'Visible','On')         
                set(orientation_edit_display,'Visible','On') 
                set(text_orientation_question,'Visible','On')  
       
                % Select the tag of each chosen object
        string = get(hObject, 'tag');
                    
% Find which popupmenu was selected and update the variable display box
            if strcmp(string, 'N')
                set(orientation_edit_display, 'String', 'North'); orientation_input = 1               
            elseif strcmp(string, 'S')    
                set(orientation_edit_display, 'String', 'South') ; orientation_input = 3  
            elseif strcmp(string, 'E')
                set(orientation_edit_display, 'String', 'East')   ; orientation_input = 2             
            elseif strcmp(string, 'W')    
                set(orientation_edit_display, 'String', 'West')  ; orientation_input = 4  
            elseif strcmp(string, 'NE')    
                set(orientation_edit_display, 'String', 'North-East') ; orientation_input = 5  
            elseif strcmp(string, 'NW')
                set(orientation_edit_display, 'String', 'North-West') ; orientation_input = 8               
            elseif strcmp(string, 'SE')    
                set(orientation_edit_display, 'String', 'South-East') ; orientation_input = 6   
            elseif strcmp(string, 'SW')    
                set(orientation_edit_display, 'String', 'South-West'); orientation_input = 7    
            end 
            
            if orientation_input ~=1
              set(orientation_next_button,'Visible','Off') 
                 errordlg('Error only Northern facing arrays','Setup Error') 
                return
            end
    end

% Create function for battery question
    function orientation_next(hObject, eventdata)
                set(orientation_next_button,'Visible','Off')         
                set(orientation_edit_display,'Visible','Off') 
                set(text_orientation_question,'Visible','Off')  
                set(compass_image,'Visible','Off')                 

                set(radio_north_button,'Visible','Off');                set(radio_north_west_button,'Visible','Off')    
                set(radio_east_button,'Visible','Off');                 set(radio_north_east_button,'Visible','Off')  
                set(radio_south_button,'Visible','Off');                set(radio_south_east_button,'Visible','Off')  
                set(radio_west_button,'Visible','Off');                 set(radio_south_west_button,'Visible','Off')  
   
                 set(text_state_question,'Visible','On'); 
                 set(postcode_edit,'Visible','On'); 
    end




%% Create Area Code
% Create function for roof parameters
text_state_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'What is your post code?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

%Set up pop up menu with pulldown data for states
state_codes = [4814 4825 4820];
state_names = ["QLD", "NSW", "VIC"];

postcode_edit = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.1], 'Style', 'edit','Parent', TabHandles{prompt_page,1},...
   'Callback', @state_check_next, 'tag', 'state_entry', 'Visible', 'Off', 'FontSize', 20);
   
    function state_check_next(hObject, eventdata)    
       % Select the tag of each chosen object
        value = str2double(get(postcode_edit,'string'));
        set(state_display_button,'Visible','ON')  
        set(state_display_button, 'String', "Invalid")
        
        for i = 1:1:length(state_codes)       
                       if value == state_codes(i)
                         set(state_display_button, 'String', state_names(i))                              
                         set(state_next_button,'Visible','ON')
                         disp(state_names(i))
                       end   
        end        
    end

% Create display of state to confirm
state_display_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'text',...
    'String', 'Location','Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', 'green', 'Foregroundcolor', 'black', 'FontSize', 20);

% Create button for next
state_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.2 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'Off','Callback', @state_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);


% Create function for end of state codes
    function state_click(hObject, eventdata)
                set(state_display_button,'Visible','Off')         
                set(state_next_button,'Visible','Off') 
                set(text_state_question,'Visible','Off')  
                set(postcode_edit,'Visible','Off')      

                set(text_bill_question,'Visible','On')         
                set(bill_edit,'Visible','On') 
    end

%% Create Bill question
% Create function for roof parameters
text_bill_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Cost of last quarter bill?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

bill_edit = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.1], 'Style', 'edit','Parent', TabHandles{prompt_page,1},...
   'Callback', @bill_next, 'tag', 'state_entry', 'Visible', 'Off', 'FontSize', 20);
   
    function bill_next(hObject, eventdata)    
       % Select the tag of each chosen object
        bill = str2double(get(bill_edit,'string'))
        set(bill_next_button,'Visible','ON')
    end

% Create button for next
bill_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.2 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'Off','Callback', @bill_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% Create function for end of state codes
    function bill_click(hObject, eventdata)
                set(text_bill_question,'Visible','Off')         
                set(bill_edit,'Visible','Off') 
                set(bill_next_button,'Visible','Off')  
                
                set(number_people_question,'Visible','On')  
                set(people_popupmenu,'Visible','On')                
    end
%% Create number of people questions
% Create function people
number_people_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'How many occupants in the residence?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);   


    function display_people_next_button(hObject, eventdata)
                set(people_next_button,'Visible','ON')

                index = get(hObject, 'Value');         
                number_people_input = number_people(index)              
    end

number_people = [0 1 2 3 4];

%Set up pop up menu with pulldown data
people_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', number_people,'Callback', @display_people_next_button, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

% Create button if has exisiting solar
people_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'Off','Callback', @people_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% persistent run_prompts;
  % Create function for battery question
    function people_click(hObject, eventdata)
                set(number_people_question,'Visible','Off')  
                set(people_popupmenu,'Visible','Off') 
                set(people_next_button,'Visible','Off') 
                
                TabSellectCallback(0,0,2);
                 set(enter_gui_button,'Visible','On') 
    end   



% Create a reset button
for count = 1:1:4
reset_button = uicontrol('Units', 'normalized', 'Position',[0.95 0 0.05 0.05], 'Style', 'pushbutton',...
    'String', 'Reset', 'Visible', 'On','Callback', @reset,'Parent', TabHandles{count,1},...
    'Backgroundcolor','cyan', 'Foregroundcolor', 'black', 'FontSize', 15);
end
% Create function to reset the program
    function reset(hObject, eventdata)
       close(gcbf)%            
       errordlg('Error in program noob-cake restart session','Setup Error')            
       pause(1)
       solar_gui_overview2
       
    end
    
% Create a Prefill button
prefill_button = uicontrol('Units', 'normalized', 'Position',[0.45 0.025 0.1 0.1], 'Style', 'pushbutton',...
    'String', 'Fill', 'Visible', 'On','Callback', @prefill,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor','red', 'Foregroundcolor', 'black', 'FontSize', 15);


% Pre fills all the data instead of going through the process
    function prefill(hObject, eventdata)

                    set(enter_gui_button,'Visible','OFF') 
                    set(prefill_button,'Visible','OFF')

                    solar_installed = 1
                    solar_size_input =5
                    cost_solar_input =9
                    battery_size_input =  6
                    roof_tilt_input = 25
                    orientation_input = 1
                    bill = 550
                    number_people_input = 3

            TabSellectCallback(0,0,2);   
            set(enter_gui_button,'Visible','On') 
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 2 content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create solar question
y_offset = -0.05;
input_page = 2;

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.9+y_offset 0.4 0.075], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Solar Parameter Inputs', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);

% Create the static text for labels
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.8+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Location', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.7+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Post Code', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.6+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Bill $', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.5+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Supplier', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.4+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Tariff', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.3+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', '# Occupants', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

gas_main_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.2+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Gas Mains', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

pool_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.1+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Pool Connected', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the edit update text inputs
current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.8+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', 'QLD', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.7+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '4814', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.6+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '550', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.5+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', 'Ergon', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.4+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '11', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.3+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '3 People', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

gas_main_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.2+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', 'No', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

pool_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.1+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', 'No', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the static text for labels
current_system = uicontrol('Units', 'normalized', 'Position',[0.65 0.8+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'System Specifications', 'Visible', 'On','Backgroundcolor', 'cyan', 'Foregroundcolor', 'black', 'FontSize', 10);

solar_size_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.7+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Solar size (kW)', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

solar_cost_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.6+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Solar Cost $', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

battery_size_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.5+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Battery Size (kWhr)', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

battery_cost_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.4+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', ' Battery Cost $', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.55 0.2+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Roof Tilt (Degrees)', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.55 0.1+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Roof Orientation', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the edit update text inputs

solar_size_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.7+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '5', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

solar_cost_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.6+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '6700', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

battery_size_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.5+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '13.2', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

battery_cost_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.4+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '8800', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.65 0.3+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Roof Specifications', 'Visible', 'On','Backgroundcolor', 'cyan', 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.75 0.2+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '25', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.75 0.1+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', 'North', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 3 content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Production tab
y_prod_offset = 0.025;
production_page = 3;

% Estimated production list
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.875+y_prod_offset 0.35 0.07], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Estimated Daily Production', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);

% Create the static text for production
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.8+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Usuage', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.725+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Solar Production', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.65+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Storage', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.575+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Total Exported', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
% Edit boxes for production
current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);


% Create axis for graph
    %   Plot a sine function
        PlotOffset = 40;
        haxes2 = axes('Parent', TabHandles{production_page,1}, ...
            'Units', 'normalized', ...
            'Position', [0.075 0.1 0.9 0.45]);
        plot(haxes2, 1:12, sin((1:12)./12));
        
        % Label, Dimension and Legent the GRPAH
title('Raw Siganal with Associated Noise','Color','yellow');
xlabel('Months)');                      ylabel('Production (kWhr)');          
% xlim([4000, 6000]);                  %ylim([4000, 6000]);
% legend({'RAW Signal'});
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.01 .01] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'off'      , ...
  'XGrid'       , 'on'      , ...
  'XColor'      , 'yellow', ...
  'YColor'      , 'yellow', ...
  'LineWidth'   , 2         );
% End of Graph Labelling


% Estimated daily savings
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.875+y_prod_offset 0.375 0.07], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Cost Per kWhr', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);


% Create the static text for cost per kw
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.8+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Cost - Normal', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.725+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Cost - Solar', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.65+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Cost - Solar/Battery', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.575+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Total Savings', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
% Edit boxes for cost per kw
current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 4 content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAvings and Finance
y_finance_offset = 0.025;
finance_page = 4;

% Estimated production list
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.875+y_prod_offset 0.35 0.07], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Finance Options', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);

% Create the static text for production
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.8+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ALCC $/kWhr', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.725+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ANNPMT $/kWhr Optimistic', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.65+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ANNPMT $/kWhr Pessimistic', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.575+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Payback Period', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
% Edit boxes for production
current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.3 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);


% Create axis for graph
    %   Plot a sine function
        PlotOffset = 40;
        haxes2 = axes('Parent', TabHandles{finance_page,1}, ...
            'Units', 'normalized', ...
            'Position', [0.075 0.1 0.9 0.45]);
        plot(haxes2, 1:12, sin((1:12)./12));
        
        % Label, Dimension and Legent the GRPAH
title('Raw Siganal with Associated Noise','Color','yellow');
xlabel('Months)');                      ylabel('Production (kWhr)');          
% xlim([4000, 6000]);                  %ylim([4000, 6000]);
% legend({'RAW Signal'});
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.01 .01] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'off'      , ...
  'XGrid'       , 'on'      , ...
  'XColor'      , 'yellow', ...
  'YColor'      , 'yellow', ...
  'LineWidth'   , 2         );
% End of Graph Labelling


% Estimated daily savings
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.875+y_prod_offset 0.375 0.07], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Expected Savings', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);


% Create the static text for cost per kw
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.8+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Monthly', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.725+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Yearly', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.65+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', '10 Year Peiod', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.575+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', '20 Year Peiod', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
% Edit boxes for cost per kw
current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

current_system = uicontrol('Units', 'normalized', 'Position',[0.8 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);






%%   Save the TabHandles in guidata
        guidata(hTabFig,TabHandles);

%%   Make Tab 1 active
        TabSellectCallback(0,0,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Background Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (1)Create axis which covers the entire GUI workspace
background_picture = axes('Parent', TabHandles{1,1},'unit', 'pixels', 'position', [1,1,MaxWindowX,MaxWindowY]); 
% (2)import the background image and show it on the axes
background_image = imread('homepage_solar_background.jpg'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');
%%%%%%%%%%%%%%%%%
% (1)Create axis which covers the entire GUI workspace
background_picture = axes('Parent', TabHandles{2,1},'unit', 'pixels', 'position', [1,1,MaxWindowX,MaxWindowY]); 
% (2)import the background image and show it on the axes
background_image = imread('homepage_solar_background.jpg'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');
%%%%%%%%%%%%%%%%%
% (1)Create axis which covers the entire GUI workspace
background_picture = axes('Parent', TabHandles{3,1},'unit', 'pixels', 'position', [1,1,MaxWindowX,MaxWindowY]); 
% (2)import the background image and show it on the axes
background_image = imread('homepage_solar_background.jpg'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');
%%%%%%%%%%%%%%%%%
% (1)Create axis which covers the entire GUI workspace
background_picture = axes('Parent', TabHandles{4,1},'unit', 'pixels', 'position', [1,1,MaxWindowX,MaxWindowY]); 
% (2)import the background image and show it on the axes
background_image = imread('homepage_solar_background.jpg'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');

%
%% Cost Analysis
size_system = 5
kwhr_year = 18*365

install_cost = 5000
maintenance_cost = 0.015*install_cost
salvage_cost = size_system*0.21*1000

LCC = install_cost + maintenance_cost - salvage_cost

inflation_rate = 0.03
discount_rate = 0.04
mortgage_rate_best = 0.01
mortgage_rate_worst = 0.06
n_years = 20 % or maybe 25
 
x_unitless = (1 + inflation_rate)/(1 + discount_rate)
pa = (1 - x_unitless^(n_years))/(1 - x_unitless)
pa1 = x_unitless*pa

ALCC = LCC/pa

ANNPMT = LCC *mortgage_rate_best*(   ((1+mortgage_rate_best)^n_years)  /  (((1+mortgage_rate_best)^n_years)-1)  )

electricity_cost_ALCC = ALCC/kwhr_year
electricity_cost_ANNPMT = ANNPMT/kwhr_year




end
%%   Callback for Tab Selection
function TabSellectCallback(~,~,SelectedTab)
%   All tab selection pushbuttons are greyed out and uipanels are set to
%   visible off, then the selected panel is made visible and it's selection
%   pushbutton is highlighted.

    %   Set up some varables
        TabHandles = guidata(gcf);
        NumberOfTabs = size(TabHandles,1)-2;
        White = TabHandles{NumberOfTabs+2,2};            % White      
        BGColor = TabHandles{NumberOfTabs+2,3};          % Light Grey
        
    %   Turn all tabs off
        for TabCount = 1:NumberOfTabs
            set(TabHandles{TabCount,1}, 'Visible', 'off');
            set(TabHandles{TabCount,2}, 'BackgroundColor', BGColor);
        end
        
    %   Enable the selected tab
        set(TabHandles{SelectedTab,1}, 'Visible', 'on');        
        set(TabHandles{SelectedTab,2}, 'BackgroundColor', White);
       
        
end