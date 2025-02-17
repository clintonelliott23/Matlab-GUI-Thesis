function solar_gui()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Script for Solar GUI Display %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial Clearing  (TAB JUMP)
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
        close all
        clc
 
%% Load Essential Data and Updates
% NASA Data
solar_psh_data = importdata('kwh_day_avg_month_nasa.mat');
kwhr_avg_data = importdata('gov_kwhr_avg_data.mat');
        
   %% Find Screen Size and Calculate Window
% Size of primary display, returned as a four-element vector of the form [left bottom width height].
set(0,'units','pixels');
ScreenSize = get(0, 'ScreenSize'); % SC will be an array of [u v x y]
MaxMonitorwidth = ScreenSize(3);
MaxMonitorheight = ScreenSize(4);
% Set figure window size
FigScale = 0.3; % adjustable parameter for changing figure size
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
        NumTabs = 5;               % Number of tabs to be generated
        TabLabels = {'Data Aquisition'; 'Input Data'; 'Estimated Production'; 'Finance Options'; 'Display';};
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
            'Name', 'Solar Solution',...
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

       % Set up the time
       clock_disp();
       
       
       

       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 1 content  (TAB JUMP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
prompt_page = 1;    
persistent index;


% Define Max number of inputs for progress bar
persistent number_of_inputs;
number_of_inputs = 13;
%% Create an Entry Button
% Create standard size for questions buttons and positions

standard_question = [0.5-0.35/2 0.7 0.35 0.12];
standard_yes = [0.2 0.4 0.2 0.2];
standard_no = [0.6 0.4 0.2 0.2];
% Create a button to enter calculator
enter_gui_button = uicontrol('Units', 'normalized', 'Position',[0.375 0.4 0.25 0.25], 'Style', 'pushbutton',...
    'String', 'Enter Solar Solution', 'Visible', 'On','Callback', @entry_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor',grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% Create function for entry
    function entry_click(~, eventdata)
                set(enter_gui_button,'Visible','OFF') 
                set(gas_mains_question,'Visible','ON') 
                set(button_yes_gas_mains,'Visible','ON') 
                set(button_no_gas_mains,'Visible','ON')  
   
               set(prefill_button,'Visible','On') 
               progress_bar(1);
    end



%% Gas Question
gas_mains_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'Do you have gas connected mains?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_gas_mains = uicontrol('Units', 'normalized', 'Position',standard_yes, 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @gas_click,'Parent', TabHandles{prompt_page,1},'tag', 'gas_yes',...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% persistent gas mains;
% Create button if has exisiting solar
button_no_gas_mains = uicontrol('Units', 'normalized', 'Position',standard_no, 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @gas_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

persistent gas_mains_input;

% Create function for entry
    function gas_click(hObject, eventdata)
                set(gas_mains_question,'Visible','Off') 
                set(button_yes_gas_mains,'Visible','Off') 
                set(button_no_gas_mains,'Visible','Off')                
        
                % Find the answer
                string = get(hObject, 'tag');               
                if strcmp(string, 'gas_yes') == 1
                gas_mains_input = 1
                set(gas_main_value, 'String', 'Yes')
                else
                 set(gas_main_value, 'String', 'No')  
                 gas_mains_input = 0   
                end
                
                set(pool_question,'Visible','ON') 
                set(button_yes_pool,'Visible','ON') 
                set(button_no_pool,'Visible','ON') 
                progress_bar(2);
    end

%% Pool Question
pool_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'Do you have a pool?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_pool = uicontrol('Units', 'normalized', 'Position',standard_yes, 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @pool_click,'Parent', TabHandles{prompt_page,1},'tag', 'pool_yes',...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_pool = uicontrol('Units', 'normalized', 'Position',standard_no, 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @pool_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

persistent pool_input;
% Create function for entry
    function pool_click(hObject, eventdata)
                set(pool_question,'Visible','Off') 
                set(button_yes_pool,'Visible','Off') 
                set(button_no_pool,'Visible','Off')                
  
              % Find the answer
                string = get(hObject, 'tag');               
                if strcmp(string, 'pool_yes') == 1
                pool_input = 1
                set(pool_value, 'String', 'Yes')
                else
                 set(pool_value, 'String', 'NO')
                 pool_input = 0   
                end 

                set(solar_size_value, 'String', '0') 
                set(solar_cost_value, 'String', '0')
                set(battery_size_value, 'String', '0') 
                set(battery_cost_value, 'String', '0')

                set(percentage_question,'Visible','ON')
                set(percentage_popupmenu,'Visible','ON')
                progress_bar(3);
    end
%% Percentage Usage Question
percentage_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'What percentage of your electricity do you use during the day?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'Off');

persistent percentage_input
percentage_input = 0;
    function percentage_next(hObject, eventdata)
               set(percentage_next_button,'Visible','On')                 
                index = get(hObject, 'Value');         
                percentage_input = percentage_list(index) 
%                 set(percentage_used_value, 'String', num2str(percentage_list(index)))

    end


percentage_list = [20 25 30 35 40 45];

%Set up pop up menu with pulldown data
percentage_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', percentage_list,'Callback', @percentage_next, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

% Create button if has exisiting solar
percentage_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'On','Callback', @percentage_next_click, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function percentage_next_click(hObject, eventdata)
                set(percentage_question,'Visible','Off')
                set(percentage_popupmenu,'Visible','Off')  
                set(percentage_next_button,'Visible','Off')              
                
                set(performance_question,'Visible','On')
                set(performance_popupmenu,'Visible','On')  
                    progress_bar(4) ;
    end
   
%% Performance Ratio Intake
performance_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'What is your performance ratio of the solar system?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

persistent performance_input
performance_input = 0;
    function performance_next(hObject, eventdata)
               set(performance_next_button,'Visible','On')                 
                index = get(hObject, 'Value');         
                performance_input = performance_list(index) 
%                 set(percentage_used_value, 'String', num2str(percentage_list(index)))

    end


performance_list = [0.70 0.75 0.80 0.85 0.90];

%Set up pop up menu with pulldown data
performance_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', performance_list,'Callback', @performance_next, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

% Create button if has exisiting solar
performance_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'On','Callback', @performance_next_click, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function performance_next_click(hObject, eventdata)
                set(performance_question,'Visible','Off')
                set(performance_popupmenu,'Visible','Off')  
                set(performance_next_button,'Visible','Off')              
                
                set(text_solar_question,'Visible','ON') 
                set(button_yes_solar,'Visible','ON') 
                set(button_no_solar,'Visible','ON')
                progress_bar(5);
    end




%% Solar Question
text_solar_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'Do you have a Solar System?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


% Create button if has exisiting solar
button_yes_solar = uicontrol('Units', 'normalized', 'Position',standard_yes, 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @solar_click_yes, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_solar = uicontrol('Units', 'normalized', 'Position',standard_no, 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @solar_click_no, 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


%% Solar "YES" what is the size
persistent solar_installed
    function solar_click_yes(hObject, eventdata)
                set(text_solar_question,'Visible','OFF') 
                set(button_yes_solar,'Visible','OFF') 
                set(button_no_solar,'Visible','OFF')
                solar_installed = 1
                set(solar_size_question,'Visible','ON') 
                set(KW_popupmenu,'Visible','ON')
              
    end

solar_size_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'What is the size of your Solar System (KW)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   


persistent solar_size_input
solar_size_input = 0;
    function size_next_button(hObject, eventdata)
                set(solar_size_next_button,'Visible','ON')
                index = get(hObject, 'Value');         
                solar_size_input = KW_solar_size(index) 
                set(solar_size_value, 'String', num2str(KW_solar_size(index)))
                progress_bar(5.25)      ;
    end


KW_solar_size = [1 3.5 5 7 9 15];

%Set up pop up menu with pulldown data
KW_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
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
cost_solar_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'How much did your solar system cost ($)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

persistent cost_solar_input
cost_solar_input = 0;
    function cost_next_button_call(hObject, eventdata)
                set(cost_next_button,'Visible','ON') 
                                                             
                index = get(hObject, 'Value');         
                cost_solar_input = solar_cost(index)*1000 
                set(solar_cost_value, 'String', num2str(solar_cost(index)))
                progress_bar(5.75);                
                
    end

solar_cost = [4 5 6 7 8 9 10 11 13 14 16];

%Set up pop up menu with pulldown data
cost_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
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
      
                
                set(cost_solar_question,'Visible','OFF') 
                set(cost_popupmenu,'Visible','OFF')                
                set(cost_next_button,'Visible','OFF')  
                
                set(text_battery_question,'Visible','ON') 
                set(button_yes_battery,'Visible','ON') 
                set(button_no_battery,'Visible','ON')
                progress_bar(6);
    end   

text_battery_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'Do you have a battery?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_battery = uicontrol('Units', 'normalized', 'Position',standard_yes, 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @battery_click_yes,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_battery = uicontrol('Units', 'normalized', 'Position',standard_no, 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @battery_click_no,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

persistent  battery_installed
battery_installed = 0;  
    function battery_click_yes(hObject, eventdata)
                set(text_battery_question,'Visible','OFF') 
                set(button_yes_battery,'Visible','OFF') 
                set(button_no_battery,'Visible','OFF')
                battery_installed = 1;
                set(battery_size_question,'Visible','ON') 
                set(KWHR_popupmenu,'Visible','ON')      
    end


battery_size_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'What is the size of your Battery (KWHR)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

KWHR_battery_size = [1 2 4 6 8 12];
%Set up pop up menu with pulldown data

KWHR_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', KWHR_battery_size,'Callback', @battery_size_next_pop, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

% Create button if has exisiting solar
battery_size_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'On','Callback', @battery_cost,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

persistent battery_size_input;
battery_size_input = 0;  
    function battery_size_next_pop(hObject, eventdata)
                set(battery_size_next_button,'Visible','On')      
                
                index = get(hObject, 'Value');         
                battery_size_input = KWHR_battery_size(index)
                set(battery_size_value, 'String', num2str(KWHR_battery_size(index))) 
                
    end

%% How much did ya solar cost bra 
    function battery_cost(hObject, eventdata)
                set(battery_size_question,'Visible','OFF') 
                set(KWHR_popupmenu,'Visible','OFF') 
                set(battery_size_next_button,'Visible','OFF')
       
                set(cost_battery_question,'Visible','ON') 
                set(battery_cost_popupmenu,'Visible','ON')
                  progress_bar(6.25);
    end

cost_battery_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'How much did your battery cost ($)?','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

battery_cost_list = [3000 4000 5000 6000 7000 8000 9000 10000];

battery_cost_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', battery_cost_list,'Callback', @cost_bat_next_button, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

persistent cost_battery_input;
cost_battery_input = 0;
    function cost_bat_next_button(hObject, eventdata)
                set(battery_cost_next_button,'Visible','ON') 
                                                             
                 index = get(hObject, 'Value')        
                 cost_battery_input = battery_cost_list(index) 
                 set(battery_cost_value, 'String', num2str(battery_cost_list(index)))               
                        progress_bar(6.75);
    end

% Create button if has exisiting solar
battery_cost_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'Off','Callback', @battery_click_no,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);


% Create function for battery question
    function battery_click_no(hObject, eventdata)
                set(text_battery_question,'Visible','OFF') 
                set(button_yes_battery,'Visible','OFF') 
                set(button_no_battery,'Visible','OFF')
                                   
                set(cost_battery_question,'Visible','Off') 
                set(battery_cost_popupmenu,'Visible','Off')         
                set(battery_cost_next_button,'Visible','Off') 
                  
                set(text_roof_question,'Visible','ON') 
                set(tilt_popupmenu,'Visible','ON')                       
                     progress_bar(7);  
    end


%% Create Roof Explanation
% % Create function for roof parameters
text_roof_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'What is the angle of your roof (Degrees)?', 'Visible', 'On','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

roof_tilt = [0 5 10 15 20 25 30 35 40 45];
%Set up pop up menu with pulldown data

tilt_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu','Parent', TabHandles{prompt_page,1},...
    'String', roof_tilt,'Callback', @roof_next, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);
   
persistent roof_tilt_input
    function roof_next(hObject, eventdata)
                set(roof_next_button,'Visible','ON')
                                 
                 index = get(hObject, 'Value');         
                  roof_tilt_input = roof_tilt(index) ;
                 set(tilt_value,'string', num2str(roof_tilt(index)))
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
                     progress_bar(8);              
    end

%% Roof Orientation
%% Orientation Image

text_orientation_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
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
    'tag','orientation_selection', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
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
                set(orientation_value, 'String', 'North');
            elseif strcmp(string, 'S')    
                set(orientation_edit_display, 'String', 'South') ; orientation_input = 3  
            elseif strcmp(string, 'E')
                set(orientation_edit_display, 'String', 'East')   ; orientation_input = 2             
            elseif strcmp(string, 'W')    
                set(orientation_edit_display, 'String', 'West')  ; orientation_input = 4  
            elseif strcmp(string, 'NE')    
                set(orientation_edit_display, 'String', 'North-East') ; orientation_input = 5  
                 set(orientation_value, 'String', 'North-East') ;
            elseif strcmp(string, 'NW')
                set(orientation_edit_display, 'String', 'North-West') ; orientation_input = 8  
                set(orientation_value, 'String', 'North-West') ;
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
                 set(text_state_codes,'Visible','On');
                 set(post_code_table,'Visible','On');
                        progress_bar(9);
    end




%% Create Area Code
% Create function for roof parameters
text_state_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'What is your post code?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

text_state_codes = uicontrol('Units', 'normalized', 'Position',[0.2 0.35 0.1 0.3], 'Style', 'text',...
    'String', '4814 TSV 4825 ISA 0800 DAR 6000 PER 3000 MEL 7000 HOB 2000 SYD 4000 BRI', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 15);

%Set up pop up menu with pulldown data for states
state_codes = [4814 4825 0800 6000 3000 7000 2000 4000];
state_names = ["Townsville, QLD", "Mount Isa, QLD", "Darwin, NT","Perth, WA", "Melbourne, VIC",...
    "Horbart, TAS", "Sydney, NSW", "Brisbane, QLD"];

postcode_edit = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.1], 'Style', 'edit','Parent', TabHandles{prompt_page,1},...
   'Callback', @state_check_next, 'tag', 'state_entry', 'Visible', 'Off', 'FontSize', 20);


state_names = {'Townsville, QLD'; 'Mount Isa, QLD'; 'Darwin, NT'; 'Perth, WA'; 'Melbourne, VIC';...
    'Horbart, TAS'; 'Sydney, NSW'; 'Brisbane, QLD'};


state_labels =[num2cell(state_codes') state_names] ; 
columnname =   {'Postcode', 'Location'};
columnformat = {'char', 'char'};
columneditable =  [false false]; 
post_code_table = uitable('Units','normalized','Position',[0.15 0.35 0.18 0.3],'Parent', TabHandles{prompt_page,1},...
          'Data', state_labels, 'Visible', 'Off',... 
          'ColumnName', columnname,...
          'ColumnFormat', columnformat,...
          'ColumnEditable', columneditable,...
          'RowName',[] ,'BackgroundColor',[.7 .9 .8],...
          'ForegroundColor',[0 0 0],'ColumnWidth',{'auto' 140},'FontSize',14);
       



persistent state_input
    function state_check_next(hObject, eventdata)    
       % Select the tag of each chosen object
        state_input = str2double(get(postcode_edit,'string'));
        set(state_display_button,'Visible','ON')  
        set(state_display_button, 'String', "Invalid")
        
        for i = 1:1:length(state_codes)       
                       if state_input == state_codes(i)
                         set(state_display_button, 'String', state_names(i))                              
                         set(state_next_button,'Visible','ON')
                         set(state_value, 'String', state_names(i)) 
                         set(postal_value, 'String', num2str(state_input)) 
                         set(tariff_value, 'String', '11')
                         set(supplier_value, 'String', 'Ergon')
                                        progress_bar(10);
                             if state_input == 4814||4825||0800                            
                                     errordlg('Error - We do not have benchmark data for mains gas for this postcode,... data without mains gas connected is shown instead.','Data Error')
                                     return
                             end  

                              if state_input == 6000                            
                                     errordlg('Error -  Your estimate will be based on WA consumption data from 2011, which is the most recent available to the AER. It assumes you have no pool and use an average amount of gas.','Data Error')
                                     return
                            end  
                                                   
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
                 set(text_state_codes,'Visible','Off');
                
                set(text_bill_question,'Visible','On')         
                set(bill_edit,'Visible','On') 
                set(bill_skip_button,'Visible','On')
                 set(post_code_table,'Visible','Off') 
                        progress_bar(11);
    end

%% Create Bill question
% Create function for roof parameters
text_bill_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'Cost of last quarter bill?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

bill_edit = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.1], 'Style', 'edit','Parent', TabHandles{prompt_page,1},...
   'Callback', @bill_next, 'tag', 'state_entry', 'Visible', 'Off', 'FontSize', 20);
 
persistent bill_input
bill_input=0;
    function bill_next(hObject, eventdata)    
       % Select the tag of each chosen object
        bill_input = str2double(get(bill_edit,'string'))
        set(bill_skip_button,'Visible','Off')        
        set(bill_next_button,'Visible','ON')
        set(bill_value, 'String', get(bill_edit,'string'))   

    end

% Create button for next
bill_skip_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Skip','Visible', 'Off','Callback', @bill_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% Create button for next
bill_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'Off','Callback', @bill_click,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);

% Create function for end of state codes
    function bill_click(hObject, eventdata)
                set(text_bill_question,'Visible','Off')         
                set(bill_edit,'Visible','Off') 
                set(bill_next_button,'Visible','Off')
                set(bill_skip_button,'Visible','Off')  
                
                set(number_people_question,'Visible','On')  
                set(people_popupmenu,'Visible','On')   
                         progress_bar(12);           
    end
%% Create number of people questions
% Create function people
number_people_question = uicontrol('Units', 'normalized', 'Position',standard_question, 'Style', 'text',...
    'String', 'How many occupants in the residence?', 'Visible', 'Off','Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 20);   

persistent number_people_input;
    function display_people_next_button(hObject, eventdata)
                set(people_next_button,'Visible','ON')

                index = get(hObject, 'Value');         
                number_people_input = number_people(index) 
                set(occupants_value, 'String', num2str(number_people(index)))   
    end

number_people = [1 2 3 4];

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
PSH_and_KW_Calc(solar_size_input,performance_input, roof_tilt_input,state_input...
            ,number_people_input,gas_mains_input, pool_input, battery_size_input, solar_installed, battery_installed)                       
                
                TabSellectCallback(0,0,2);
                 set(enter_gui_button,'Visible','On')
                                     progress_bar(13);
    end   

% Create a reset button
for count = 1:1:NumTabs
reset_button = uicontrol('Units', 'normalized', 'Position',[0.95 0 0.05 0.05], 'Style', 'pushbutton',...
    'String', 'Reset', 'Visible', 'On','Callback', @reset,'Parent', TabHandles{count,1},...
    'Backgroundcolor',grey, 'Foregroundcolor', 'black', 'FontSize', 15);
end

% Create function to reset the program
    function reset(hObject, eventdata)       
             set(gas_main_value, 'String', '-');           set(pool_value, 'String', '-');
             set(solar_size_value, 'String', '-');          set(solar_cost_value, 'String', '-');                                          
             set(battery_size_value, 'String', '-' );       set(battery_cost_value, 'String', '-' );                              
             set(tilt_value, 'String', '-' );               set(orientation_value, 'String', '-');         
             set(bill_value, 'String', '-' );               set(occupants_value, 'String', '-');
             set(state_value, 'String', '-') ;              set(postal_value, 'String', '-');             
             set(tariff_value, 'String', '-');              set(supplier_value, 'String', '-') ;         
           pause(0.75)
             close(gcbf)%            
           errordlg('Error in program noob-cake restart session','Setup Error')            
%            pause(0.25)
%             solar_gui_overview2
            set(prefill_button,'Visible','On')
    end
    
% Create a Prefill button
prefill_button = uicontrol('Units', 'normalized', 'Position',[0.95 0.05 0.05 0.05], 'Style', 'pushbutton',...
    'String', 'E.X', 'Visible', 'On','Callback', @prefill,'Parent', TabHandles{prompt_page,1},...
    'Backgroundcolor',grey, 'Foregroundcolor', 'black', 'FontSize', 15);


% Pre fills all the data instead of going through the process
    function prefill(hObject, eventdata)
                set(gas_mains_question,'Visible','Off') 
                set(button_yes_gas_mains,'Visible','Off') 
                set(button_no_gas_mains,'Visible','Off')  ;   set(enter_gui_button,'Visible','OFF') 
                set(prefill_button,'Visible','OFF')

                    gas_mains_input = 0;                           set(gas_main_value, 'String', 'No')
                    pool_input = 0;                                set(pool_value, 'String', 'No')
                    percentage_input = 30;
                    performance_input = 0.85;
                    solar_installed = 1;                    
                    solar_size_input = 5;         set(solar_size_value, 'String', num2str(solar_size_input))
                    cost_solar_input = 6747;            set(solar_cost_value, 'String', num2str(cost_solar_input))
                    battery_installed = 1;
                    battery_size_input =  10;      set(battery_size_value, 'String', num2str(battery_size_input) )
                    cost_battery_input =  9700;      set(battery_cost_value, 'String', num2str(cost_battery_input) )                    
                    roof_tilt_input = 1;           set(tilt_value, 'String', num2str(roof_tilt_input) ) 
                    orientation_input = 1;          set(orientation_value, 'String', 'North')
                    bill_input = 550;                set(bill_value, 'String', num2str(bill_input) )
                    number_people_input = 3;        set(occupants_value, 'String', num2str(number_people_input))
                    state_input =  7000;            
                    set(state_value, 'String', 'QLD') ; 
                                                    set(postal_value, 'String', '4814')                                          
                                                    set(tariff_value, 'String', '11')
                                                    set(supplier_value, 'String', 'Ergon')
                      
                                                    set(enter_gui_button,'Visible','On')
                   
PSH_and_KW_Calc(solar_size_input,performance_input, roof_tilt_input,state_input...
            ,number_people_input,gas_mains_input, pool_input, battery_size_input, solar_installed, battery_installed)                     
  
%          loading_bar = waitbar(0,'Please wait...');
%         steps = 1000;
%         for step = 1:steps
%             % computations take place here
%             waitbar(step / steps)
%         end
%         close(loading_bar) 
%         
        
        TabSellectCallback(0,0,5); 
%         pause(0.5)
%         TabSellectCallback(0,0,3); 
%           pause(0.5)
%         TabSellectCallback(0,0,4); 
%           pause(0.5)
%         TabSellectCallback(0,0,5); 
%                   pause(0.5)
%         TabSellectCallback(0,0,2);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 2 content (TAB JUMP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create solar question
y_offset = -0.05;
input_page = 2;

solar_title = uicontrol('Units', 'normalized', 'Position',[0.3 0.9+y_offset 0.4 0.075], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Solar Parameter Inputs', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);

% Create the static text for labels
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.8+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Location', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

postal_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.7+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Post Code', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

bill_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.6+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Bill $', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

supplier_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.5+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Supplier', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

tariff_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.4+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Tariff', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

occupants_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.3+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', '# Occupants', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

gas_main_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.2+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Gas Mains', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

pool_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.1+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Pool Connected', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the edit update text inputs
state_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.8+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

postal_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.7+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

bill_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.6+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

supplier_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.5+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

tariff_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.4+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

occupants_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.3+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

gas_main_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.2+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

pool_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.1+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the static text for labels
system_title = uicontrol('Units', 'normalized', 'Position',[0.65 0.8+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'System Specifications', 'Visible', 'On','Backgroundcolor', 'green', 'Foregroundcolor', 'black', 'FontSize', 10);

solar_size_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.7+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Solar size (kW)', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

solar_cost_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.6+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Solar Cost $', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

battery_size_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.5+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Battery Size (kWhr)', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

battery_cost_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.4+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', ' Battery Cost $', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

tilt_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.2+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Roof Tilt (Degrees)', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

orientation_title = uicontrol('Units', 'normalized', 'Position',[0.55 0.1+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Roof Orientation', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the edit update text inputs

solar_size_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.7+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

solar_cost_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.6+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

battery_size_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.5+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

battery_cost_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.4+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

roofspec_title = uicontrol('Units', 'normalized', 'Position',[0.65 0.3+y_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{input_page,1},...
    'String', 'Roof Specifications', 'Visible', 'On','Backgroundcolor', 'green', 'Foregroundcolor', 'black', 'FontSize', 10);

tilt_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.2+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

orientation_value = uicontrol('Units', 'normalized', 'Position',[0.75 0.1+y_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{input_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 3 content (TAB JUMP)
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
daily_usuage_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

daily_production_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

daily_storage_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

daily_exported_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);




% Estimated daily savings
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.875+y_prod_offset 0.375 0.07], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Daily Cost', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);


% Create the static text for cost per kw
daily_normal_cost_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.8+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Standard', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

daily_solar_cost_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.725+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Import', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.65+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Export', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
current_system = uicontrol('Units', 'normalized', 'Position',[0.575 0.575+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{production_page,1},...
    'String', 'Actual Savings', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
% Edit boxes for cost per kw
daily_normal_cost_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

daily_import_cost_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

daily_export_cost_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

daily_savings_cost_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{production_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

% Calculation of PSH from tilt angle
persistent kw_produced_daily
persistent daily_savings
    function PSH_and_KW_Calc(solar_size_input,performance_input, roof_tilt_input,state_input...
            ,number_people_input,gas_mains_input, pool_input, battery_size_input, solar_installed, battery_installed)    
                 
        PSH_avg =  tilt_calculator (roof_tilt_input,13);
        disp('Peak Sun Hours');   disp(PSH_avg);   
        
        if bill_input == 0
        kwhr_avg_found = average_kwhr_finder(state_input,number_people_input,gas_mains_input, pool_input)    ;   
        else 
            kwhr_avg_found = average_kwhr_finder(state_input,number_people_input,gas_mains_input, pool_input)    ;   
            kwhr_avg_found = bill_input/(90*tariff_rate_normal_found)
        end
        disp('Average Kilowatts Hours For Household');   disp(kwhr_avg_found);   
        
       kw_produced_daily = solar_size_input *  PSH_avg * performance_input
       kwhr_used_from_solar = (10/percentage_input)*kw_produced_daily
       
      % Need to find the calculations
        daily_storage = battery_size_input;  
      if ((battery_installed == 1) & (solar_installed == 0))
          daily_exported = 0;
      elseif ((battery_installed == 0) & (solar_installed == 0))
            kw_produced_daily = 0;            
      else         
        daily_exported = (kw_produced_daily - kwhr_used_from_solar - daily_storage);
      end
      
      daily_imported = (kwhr_avg_found - kwhr_used_from_solar - daily_storage);
      daily_savings =   (kwhr_avg_found*tariff_rate_normal_found    -...
                        (daily_imported*tariff_rate_normal_found - daily_exported*solar_rate_feedin_found));
      
      
        Update_Values_prod(kwhr_avg_found,kw_produced_daily,daily_storage,tariff_rate_normal_found,daily_exported,daily_imported,daily_savings)
         production_graph() 
         cost_analysis(daily_savings)
         finance_graph()
         

       if (daily_storage == 0)
           pie_storage = 0.0000000000001;
       else
           pie_storage = daily_storage;
       end
        source_energy = [kwhr_used_from_solar    pie_storage    daily_imported]/...
            (kwhr_used_from_solar + pie_storage + daily_imported) 
  
        % Pie chart
         haxes_pie = axes('Parent', TabHandles{display_page,1}, ...
                                    'Units', 'normalized', ...
                                    'Position', [0.7 0.665 0.3 0.3]);              
        pie_face = pie(haxes_pie,source_energy);
        title(haxes_pie,'Daily Energy Sources');
         jooda  = pie_face(1); jooda.FaceColor = 'green'; jooda  = pie_face(2); jooda .FontSize = 12;
         jooda  = pie_face(3); jooda.FaceColor = 'yellow'; jooda  = pie_face(4); jooda .FontSize = 12;
         jooda  = pie_face(5); jooda.FaceColor = 'red'; jooda  = pie_face(6); jooda .FontSize = 10;  
         %         jooda .BackgroundColor = 'green';
            hText = findobj(pie_face,'Type','text'); % text object handles
            percentValues = get(hText,'String'); % percent values
            energy_sources = {'Solar offset: ';'Battery offset: ';'Grid Imports: '};
            combinedtxt = strcat(energy_sources,percentValues); % strings and percent values
            oldExtents_cell = get(hText,'Extent'); % cell array
            oldExtents = cell2mat(oldExtents_cell); % numeric array
            hText(1).String = combinedtxt(1);
            hText(2).String = combinedtxt(2);
            hText(3).String = combinedtxt(3);
            newExtents_cell = get(hText,'Extent'); % cell array
            newExtents = cell2mat(newExtents_cell); % numeric array 
            width_change = newExtents(:,3)-oldExtents(:,3);
            signValues = sign(oldExtents(:,1));
            offset = signValues.*(width_change/2);
            textPositions_cell = get(hText,{'Position'}); % cell array
            textPositions = cell2mat(textPositions_cell); % numeric array
            textPositions(:,1) = textPositions(:,1) + offset; % add offset 
            hText(1).Position = textPositions(1,:);
            hText(2).Position = textPositions(2,:);
            hText(3).Position = textPositions(3,:);
   
         
    end

% Function for findin the liner change between nasa data
    function [PSH_avg] =  tilt_calculator (roof_tilt_input,month)
        psh_row_index = 0;
        month = month + 1;
                switch state_input
                        case 4814                        
                        case 4825
                            psh_row_index =  5;
                        case 0800
                             psh_row_index =  10;
                        case 6000
                            psh_row_index =  15;
                        case 3000
                             psh_row_index =  20;
                        case 7000
                            psh_row_index =  25;
                        case 2000
                             psh_row_index =  30;
                       case 4000
                             psh_row_index =  35; 
                end   
                max_tilt0 = solar_psh_data(psh_row_index+1,1);
                max_tilt1 = solar_psh_data(psh_row_index+2,1); 
                max_tilt2 = solar_psh_data(psh_row_index+3,1); 
                max_tilt3 = solar_psh_data(psh_row_index+4,1); 
                max_tilt4 = solar_psh_data(psh_row_index+5,1); 
                    
                if  ((roof_tilt_input >= max_tilt0) & (roof_tilt_input <= max_tilt1))
                    max_tilt = max_tilt1;                      min_tilt = max_tilt0;
                    max_psh = solar_psh_data(2+psh_row_index,month);     min_psh = solar_psh_data(1+psh_row_index,month);
               elseif ((roof_tilt_input > max_tilt1) & (roof_tilt_input <= max_tilt2))
                    max_tilt = max_tilt2;                      min_tilt = max_tilt1;                
                    max_psh = solar_psh_data(3+psh_row_index,month);     min_psh = solar_psh_data(2+psh_row_index,month);
               elseif ((roof_tilt_input > max_tilt2) & (roof_tilt_input <= max_tilt3))
                    max_tilt = max_tilt3;                      min_tilt = max_tilt2;              
                    max_psh = solar_psh_data(4+psh_row_index,month);     min_psh = solar_psh_data(3+psh_row_index,month);
               elseif ((roof_tilt_input> max_tilt3) & (roof_tilt_input <= max_tilt4))
                    max_tilt = max_tilt4;                      min_tilt = max_tilt3;            
                    max_psh = solar_psh_data(5+psh_row_index,month);     min_psh = solar_psh_data(4+psh_row_index,month);
                end
                
                div_step = (max_psh - min_psh)/(max_tilt-min_tilt);
                tilt_offset = (roof_tilt_input - min_tilt) * div_step ;
                PSH_avg =  tilt_offset + min_psh;
                
                
    end



    function production_graph()

                    % Create axis for graph
                    %   Plot a sine function
                        PlotOffset = 40;
                        haxes2 = axes('Parent', TabHandles{production_page,1}, ...
                            'Units', 'normalized', ...
                            'Position', [0.075 0.1 0.9 0.45]);
       
            month_name = ({'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec';'Average'});         
        
        for i = 1:1:13
                        kw_produced_daily_plot = solar_size_input *  tilt_calculator (roof_tilt_input,i) * performance_input;
                        bar_data_plot(1,i) =  kw_produced_daily_plot;
                        hold all
        end
        
        bar(haxes2,bar_data_plot,'FaceColor',[0 .8 .5],'EdgeColor','yellow','LineWidth',1.5);
        set(gca, 'XTick', 1:13,'xticklabel',month_name)
        
                        % Label, Dimension and Legent the GRPAH
                title('Monthly Average kWhr Production','Color','yellow','FontSize', 13);
                xlabel('Month');                      ylabel('Production (kWhr)');  
                % legend({'RAW Signal'});
                set(gca, ...
                  'Box'         , 'off'     , ...
                  'TickDir'     , 'out'     , ...
                  'TickLength'  , [.01 .01] , ...
                  'XMinorTick'  , 'on'      , ...
                  'YMinorTick'  , 'on'      , ...
                  'YGrid'       , 'on'      , ...
                  'XGrid'       , 'off'      , ...
                  'Color',grey, 'FontSize', 13,...           
                  'XColor'      , 'yellow', ...
                  'YColor'      , 'yellow', ...
                  'LineWidth'   , 3         );
                % End of Graph Labelling

    end


% Values for Taffifs
 persistent tariff_found
 persistent tariff_rate_normal_found
 persistent solar_rate_feedin_found
 persistent kwhr_avg_found
    function [kwhr_avg_found] = average_kwhr_finder(state_input,number_people_input,gas_mains_input, pool_input)
                column = 5;
                row = 1;
        switch state_input
                        case 4814                        
                        case 4825
                            row = row + 16;
                        case 0800
                             row = row + 32;
                        case 6000
                            row = row + 48;
                        case 3000
                             row = row + 64;
                        case 7000
                            row = row + 80;
                        case 2000
                             row = row + 96;
                       case 4000
                             row = row + 112; 
                    end                            
        
                    switch number_people_input
                        case 3
                            row = row +4;
                        case 2
                            row = row +8;
                        case 1
                            row = row +12;
                    end

                       switch pool_input                     
                        case 1
                            row = row +2;
                       end
                       
                       switch gas_mains_input
                        case 1
                            row = row +1;
                       end
                       
              kwhr_avg_found = kwhr_avg_data(row,column);  
              tariff_found = kwhr_avg_data(row,column+2)
              tariff_rate_normal_found = kwhr_avg_data(row,column+3)
              solar_rate_feedin_found = kwhr_avg_data(row,column+4)
    end
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 4 content (TAB JUMP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAvings and Finance
y_finance_offset = 0.025;
finance_page = 4;

% Estimated production list
current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.875+y_prod_offset 0.35 0.07], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Finance Options', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);

% Create the static text for production
ALCC_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.8+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ALCC $/kWhr', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

ANNPMT_opt_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.725+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ANNPMT Optimistic', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

ANNPMT_likely_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.65+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ANNPMT Likely', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
ANNPMT_pess_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.575+y_prod_offset 0.175 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ANNPMT Pessimistic', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
   
ROI_title = uicontrol('Units', 'normalized', 'Position',[0.3 0.5+y_prod_offset 0.15/2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'ROI%', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
IRR_title = uicontrol('Units', 'normalized', 'Position',[0.1 0.5+y_prod_offset 0.175/2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'IRR%', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
     

% Edit boxes for production
ALCC_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

ANNPMT_opt_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

ANNPMT_likely_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

ANNPMT_pess_value = uicontrol('Units', 'normalized', 'Position',[0.3 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

ROI_value = uicontrol('Units', 'normalized', 'Position',[0.3+(0.15/2) 0.5+y_prod_offset 0.15/2 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);
IRR_value = uicontrol('Units', 'normalized', 'Position',[0.1+0.175/2 0.5+y_prod_offset 0.175/2 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);


persistent bar_data_finance
persistent yearly_savings_adj_infla
    function finance_graph()
        % Create axis for graph
            %   Plot a sine function
                PlotOffset = 40;
                haxes3 = axes('Parent', TabHandles{finance_page,1}, ...
                    'Units', 'normalized', ...
                    'Position', [0.075 0.1 0.9 0.35]);
                 
                yearly_cost_plot =  kwhr_avg_found*tariff_rate_normal_found*365;
                yearly_cost_witsol_plot = yearly_cost_plot - daily_savings*365;

        for i = 1:1:20 
                                          
                            if ((i == 10) & (battery_installed == 1))
                            bar_data_finance(1,i) = (yearly_cost_witsol_plot + cost_battery_input*(1+inflation_rate)^i)   ;                              
%                             bar_data_finance(1,i) = (yearly_cost_plot + yearly_cost_witsol_plot);  
                            else
                            bar_data_finance(2,i) = yearly_cost_plot;       
                            bar_data_finance(1,i) = yearly_cost_witsol_plot;
                            end

                       yearly_cost_plot = yearly_cost_plot *(1+inflation_rate);
                       yearly_cost_witsol_plot = yearly_cost_witsol_plot * (1+inflation_rate);
        end              
              buddy = bar(haxes3,bar_data_finance','stacked','FaceColor',[0 .8 .5],'EdgeColor','yellow','LineWidth',1.5);
               buddy(2).FaceColor = [.9 .1 .1];

                % Label, Dimension and Legent the GRPAH
        title('Yearly Cost of Electricity Comparison Between Normal Vs. Solar/Battery','Color','yellow','FontSize', 16);
        xlabel('Years','FontSize', 16);                      ylabel('Cost $AUD','FontSize', 16);          
         xlim([0, 21]);                  %ylim([4000, 6000]);
         legend({'Solar/Battery','Normal'},'Location','northwest');
        set(gca, ...
          'Box'         , 'off'     , ...
          'TickDir'     , 'out'     , ...
          'TickLength'  , [.01 .01] , ...
          'XMinorTick'  , 'on'      , ...
          'YMinorTick'  , 'on'      , ...
          'YGrid'       , 'off'      , ...
          'XGrid'       , 'on'      , ...
         'Color',grey, 'FontSize', 13,...      
          'XColor'      , 'yellow', ...
          'YColor'      , 'yellow', ...
          'LineWidth'   , 2         );
        % End of Graph Labelling

    end
% Estimated daily savings
savings_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.875+y_prod_offset 0.375 0.07], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Expected Savings', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);


% Create the static text for cost per kw
monthly_saving_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.8+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Monthly', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

yearly_saving_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.725+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Yearly', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

ten_year_saving_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.65+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', '10 Year Peiod', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

twen_year_saving_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.575+y_prod_offset 0.2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', '20 Year Period', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
payback_period_title = uicontrol('Units', 'normalized', 'Position',[0.575 0.5+y_prod_offset 0.2/2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'Payback', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
NPV_title = uicontrol('Units', 'normalized', 'Position',[0.8 0.5+y_prod_offset 0.15/2 0.05], 'Style', 'text','Parent', TabHandles{finance_page,1},...
    'String', 'NPV', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);
        
% Edit boxes for cost per kw
monthly_saving_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.8+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

yearly_saving_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.725+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

ten_year_saving_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.65+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

twen_year_saving_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.575+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

payback_saving_value = uicontrol('Units', 'normalized', 'Position',[0.575+0.1 0.5+y_prod_offset 0.1 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);
NPV_value = uicontrol('Units', 'normalized', 'Position',[0.8+0.15/2 0.5+y_prod_offset 0.15/2 0.05], 'Style', 'edit','Parent', TabHandles{finance_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Define Tab 5 content (TAB JUMP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display
y_disp_offset = 0.025;
display_page = 5;

% % Estimated production list
% current_system = uicontrol('Units', 'normalized', 'Position',[0.1 0.875+y_prod_offset 0.35 0.07], 'Style', 'text','Parent', TabHandles{finance_page,1},...
%     'String', 'Finance Options', 'Visible', 'On','Backgroundcolor',[0.5 1 0], 'Foregroundcolor', 'black', 'FontSize', 20);

% Create the static text for production
disp_prod_title = uicontrol('Units', 'normalized', 'Position',[0.375 0.5+y_disp_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{display_page,1},...
    'String', 'Daily Production', 'Visible', 'On','Backgroundcolor', 'green', 'Foregroundcolor', 'black', 'FontSize', 15);

% Edit boxes for production
disp_prod_value = uicontrol('Units', 'normalized', 'Position',[0.375 0.43+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{display_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the static text for production
disp_stored_title = uicontrol('Units', 'normalized', 'Position',[0.375 0.195+y_disp_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{display_page,1},...
    'String', 'Daily Storage', 'Visible', 'On','Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 15);

% Edit boxes for production
disp_stored_value = uicontrol('Units', 'normalized', 'Position',[0.375 0.125+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{display_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the static text for production
disp_used_title = uicontrol('Units', 'normalized', 'Position',[0.725 0.195+y_disp_offset 0.15 0.05], 'Style', 'text','Parent', TabHandles{display_page,1},...
    'String', 'Daily Usage', 'Visible', 'On','Backgroundcolor', 'red', 'Foregroundcolor', 'black', 'FontSize', 15);

% Edit boxes for production
disp_used_value = uicontrol('Units', 'normalized', 'Position',[0.725 0.125+y_prod_offset 0.15 0.05], 'Style', 'edit','Parent', TabHandles{display_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);


% Create the static text for production
disp_exported_title = uicontrol('Units', 'normalized', 'Position',[0.725 0.5+y_disp_offset 0.07 0.05], 'Style', 'text','Parent', TabHandles{display_page,1},...
    'String', 'Export', 'Visible', 'On','Backgroundcolor', 'green', 'Foregroundcolor', 'black', 'FontSize', 15);

% Edit boxes for production
disp_exported_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.5+y_prod_offset 0.07 0.05], 'Style', 'edit','Parent', TabHandles{display_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

% Create the static text for production
disp_imported_title = uicontrol('Units', 'normalized', 'Position',[0.725 0.43+y_disp_offset 0.07 0.05], 'Style', 'text','Parent', TabHandles{display_page,1},...
    'String', 'Import', 'Visible', 'On','Backgroundcolor', 'red', 'Foregroundcolor', 'black', 'FontSize', 15);

% Edit boxes for production
disp_imported_value = uicontrol('Units', 'normalized', 'Position',[0.8 0.43+y_prod_offset 0.07 0.05], 'Style', 'edit','Parent', TabHandles{display_page,1},...
    'String', '-', 'Visible', 'On','Backgroundcolor', grey, 'Foregroundcolor', 'black', 'FontSize', 10);

                      





%%   Save the TabHandles in guidata
        guidata(hTabFig,TabHandles);

%%   Make Tab 1 active
        TabSellectCallback(0,0,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%   Background Images (TAB JUMP)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1)Create axis which covers the entire GUI workspace
background_picture = axes('Parent', TabHandles{5,1},'unit', 'pixels', 'position', [10,10,MaxWindowX-10,MaxWindowY-10]); 
% (2)import the background image and show it on the axes
background_image = imread('diagram_of_system.png'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');

%
%% Cost Analysis (TAB JUMP)
persistent inflation_rate
persistent investment_cost
persistent IRR_val
persistent NPV
function cost_analysis(daily_savings)
            inflation_rate = 0.03;        mortgage_rates = [0.01 0.035 0.06];
            discount_rate = 0.04;        
            n_years = 20; % or maybe 25
            x_unitless = (1 + inflation_rate)/(1 + discount_rate);
            pa = (1 - x_unitless^(n_years))/(1 - x_unitless);
            pa1 = x_unitless*pa  ;


%              maintenance_cost = 0.015*cost_solar_input*20
%             salvage_cost = solar_size_input*0.21*1000;

            LCC = cost_solar_input + cost_battery_input*2 
            ALCC = LCC/pa;

                for i = 1:1:3 
                     mort = mortgage_rates(1,i);
                    ANNPMT(1,i) = LCC *mort*(   ((1+mort)^n_years)  /  (((1+mort)^n_years)-1)  ) ;       
                    electricity_cost_ANNPMT(1,i) = ANNPMT(1,i)/(kw_produced_daily*365);
                end      
            electricity_cost_ALCC = ALCC/(kw_produced_daily*365);

            investment_cost = cost_solar_input + cost_battery_input*2
            payback_period = investment_cost/ (daily_savings*365);
            

             % investment_cost
            yearly_savings_adj_infla = daily_savings*365; 
            IRR_sym = sym('IRR_sym') ;
             IRR_eqn = 0;            
            for i = 1:1:20
                if i == 10
                cash_flow_in(1,i) = yearly_savings_adj_infla - cost_battery_input   ;
                else
                cash_flow_in(1,i) = yearly_savings_adj_infla ;
                end
                yearly_savings_adj_infla = yearly_savings_adj_infla  * (1+inflation_rate);             
                cash_flows_discounted(1,i) =  cash_flow_in(1,i) / ((1 + discount_rate)); 
                IRR_eqn = IRR_eqn + ( cash_flows_discounted(1,i) / (1 + IRR_sym)^i );                
            end
%             disp(cash_flows_discounted);
             NPV = sum(cash_flows_discounted)-investment_cost  
             % I think the method is a better indication not the blanked
             % out version (this takes into account inflation and discount)
%              ROI = ((daily_savings*365*20 - investment_cost) / investment_cost)*100/20
             ROI = ((NPV - investment_cost )*100/20) / investment_cost
             
             %Solve IRR Equation
            IRR_eqn = IRR_eqn - investment_cost == 0;
            IRR_sol = real(double(solve(IRR_eqn, IRR_sym)));
            % Find the positive value
            Positive = IRR_sol > 0;
            IRR_sol(~Positive) = 0;
            IRR_val = 0;
            element = 0;
            if (IRR_sol(1,1) == 0)
            for i = 1:1:4
                element = IRR_sol(i,1);
                    if element > IRR_val
                        IRR_val = element;
                    end
            end
            end
            %Display the IRR Value
            disp('IRR Value:')
            disp(IRR_val*100)
          
            Update_Values_cost(electricity_cost_ALCC,electricity_cost_ANNPMT,daily_savings,payback_period,ROI)       
end


function Update_Values_prod(kwhr_avg_found,kw_produced_daily,daily_storage,tariff_rate_normal_found,daily_exported,daily_imported,daily_savings)
      set(daily_usuage_value,'string', num2str(kwhr_avg_found))
      set(daily_production_value,'string', num2str(kw_produced_daily))
      set(daily_storage_value , 'String', num2str(daily_storage))
      set(daily_exported_value , 'String', num2str(daily_exported))     
      set(daily_normal_cost_value , 'String', num2str(kwhr_avg_found*tariff_rate_normal_found)) 
      set(daily_import_cost_value , 'String', num2str(daily_imported*tariff_rate_normal_found)) 
      set(daily_export_cost_value , 'String', num2str(daily_exported*solar_rate_feedin_found))     
      set(daily_savings_cost_value , 'String', num2str(daily_savings))     
      
      set(disp_used_value,'string', num2str(kwhr_avg_found))
      set(disp_prod_value,'string', num2str(kw_produced_daily))
      set(disp_stored_value , 'String', num2str(daily_storage))
      set(disp_exported_value , 'String', num2str(daily_exported))
       set(disp_imported_value , 'String', num2str(daily_imported))
      
      
end
function Update_Values_cost(electricity_cost_ALCC,electricity_cost_ANNPMT,daily_savings,payback_period,ROI)
      set(ALCC_value,'string', num2str(electricity_cost_ALCC))
      set(ANNPMT_opt_value,'string', num2str(electricity_cost_ANNPMT(1,1)))
      set(ANNPMT_likely_value , 'String', num2str(electricity_cost_ANNPMT(1,2)))
      set(ANNPMT_pess_value , 'String', num2str(electricity_cost_ANNPMT(1,3)))
      set(NPV_value, 'String', num2str(NPV)) 
      set(ROI_value, 'String', num2str(ROI)) 
      set(IRR_value, 'String', num2str(IRR_val*100))   
      
      set(monthly_saving_value,'string', num2str(daily_savings*30)) 
      set(yearly_saving_value,'string', num2str(daily_savings*365))   
      set(ten_year_saving_value,'string', num2str(daily_savings*3650))   
      set(twen_year_saving_value,'string', num2str(daily_savings*3650*2))   
       set(payback_saving_value,'string', num2str(payback_period))    
end
    function clock_disp()
        time_all = fix(clock);
        hr = time_all(1,4);
        min = time_all(1,5);
        uicontrol('Style','text','Units', 'normalized','Position',[0.0 0.0 0.04 0.03],... 
            'string',sprintf('%d:%d',hr,min),'BackgroundColor', white,... 
            'HorizontalAlignment','left','FontName','arial','FontWeight','bold', ... 
            'FontSize',14); 
        axis off;
    end

function progress_bar(progress_step)
        %  Progess bar in yellow to help user
        axes('Units','normalized','Position',[0.3 0.05 0.4 0.07],'Parent', TabHandles{1,1}); 
        axis off;
        area1 = area([0 progress_step/number_of_inputs],[1 1]); 
        set(gca,'xtick',[]); set(gca,'ytick',[]); 
        set(gca,'xlim',[0 1]);  
        set(gca,'ylim',[0 1]); 
        set(area1,'FaceColor','yellow');   
        uicontrol('Style', 'text','Units', 'normalized','Position', [0.3 0.05-0.038 0.4 0.038],'Parent', TabHandles{1,1},... 
            'string',sprintf('Progress: %i%%',round(progress_step*100/number_of_inputs)),'BackgroundColor',grey,... 
            'HorizontalAlignment','center','FontName','arial','FontWeight','bold', ... 
            'FontSize', 12);        
end


end
%%   Callback for Tab Selection (TAB JUMP)
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

 