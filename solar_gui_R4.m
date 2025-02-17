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

%% Create Main Window
main_window = figure(...
'Units','pixels',...
'Toolbar','none',...
'Position', [Xorigin Yorigin MaxWindowX MaxWindowY],...
'NumberTitle','off',...
'Name','Solar Calculator',...
'MenuBar','none',...
'Resize','off',...
'DockControls','off',...
'Color',white, 'resize', 'on');

%% Background 
% (1)Create axis which covers the entire GUI workspace
background_picture = axes('unit', 'pixels', 'position', [1,1,MaxWindowX,MaxWindowY]); 
% (2)import the background image and show it on the axes
background_image = imread('homepage_solar_background.jpg'); imagesc(background_image);
% (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(background_picture, 'bottom');

%%%%%%%%%%%%%%%%%



%% Create an Entry Button
% Create function for entry
    function entry_click(hObject, eventdata)
                set(enter_gui_button,'Visible','OFF') 
                set(text_solar_question,'Visible','ON') 
                set(button_yes_solar,'Visible','ON') 
                set(button_no_solar,'Visible','ON')             
    end

% Create a button to enter calculator
enter_gui_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Enter Solar Calculator', 'Visible', 'On','Callback', @entry_click,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);


%% Create solar question
text_solar_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Do you have a Solar System?', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_solar = uicontrol('Units', 'normalized', 'Position',[0.1 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @solar_click_yes, 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_solar = uicontrol('Units', 'normalized', 'Position',[0.6 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @solar_click_no, 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


%% Solar "YES" what is the size
    function solar_click_yes(hObject, eventdata)
                set(text_solar_question,'Visible','OFF') 
                set(button_yes_solar,'Visible','OFF') 
                set(button_no_solar,'Visible','OFF')
                
                set(solar_size_question,'Visible','ON') 
                set(KW_popupmenu,'Visible','ON')      
    end

solar_size_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'What is the size of your Solar System (KW)?', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   


    function display_solar_next_button(hObject, eventdata)
                set(solar_size_next_button,'Visible','ON') 

    end

KW_solar_size = [1 3.5 5 7 9 15];

%Set up pop up menu with pulldown data
KW_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu',...
    'String', KW_solar_size,'Callback', @display_solar_next_button, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);


% Create button if has exisiting solar
solar_size_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'On','Callback', @solar_click_no, 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

  % Create function for battery question
    function solar_click_no(hObject, eventdata)
                set(text_solar_question,'Visible','OFF') 
                set(button_yes_solar,'Visible','OFF') 
                set(button_no_solar,'Visible','OFF')       
                
                set(solar_size_question,'Visible','OFF') 
                set(KW_popupmenu,'Visible','OFF')                
                set(solar_size_next_button,'Visible','OFF')  
                
                set(text_battery_question,'Visible','ON') 
                set(button_yes_battery,'Visible','ON') 
                set(button_no_battery,'Visible','ON')    

                
    end   

text_battery_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Do you have a battery?', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_yes_battery = uicontrol('Units', 'normalized', 'Position',[0.1 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'Yes', 'Visible', 'On','Callback', @battery_click_yes,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

% Create button if has exisiting solar
button_no_battery = uicontrol('Units', 'normalized', 'Position',[0.6 0.3 0.3 0.3], 'Style', 'pushbutton',...
    'String', 'No', 'Visible', 'On','Callback', @battery_click_no,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function battery_click_yes(hObject, eventdata)
                set(text_battery_question,'Visible','OFF') 
                set(button_yes_battery,'Visible','OFF') 
                set(button_no_battery,'Visible','OFF')
                
                set(battery_size_question,'Visible','ON') 
                set(KWHR_popupmenu,'Visible','ON')      
    end


 battery_size_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'What is the size of your Battery (KWHR)?', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');   

KWHR_battery_size = [1 2 4 6 8 12];
%Set up pop up menu with pulldown data

KWHR_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu',...
    'String', KWHR_battery_size,'Callback', @display_battery_next_button, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);

% Create button if has exisiting solar
battery_size_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'On','Callback', @battery_click_no,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

    function display_battery_next_button(hObject, eventdata)
                set(battery_size_next_button,'Visible','ON') 
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
    'String', 'What is the angle of your roof (Degrees)?', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

roof_tilt = [0 5 10 15 20 25 30 35 40 45];
%Set up pop up menu with pulldown data

tilt_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.15], 'Style', 'popupmenu',...
    'String', roof_tilt,'Callback', @roof_next, 'tag', 'KW_menu', 'Visible', 'OFF', 'FontSize', 20);
   
    function roof_next(hObject, eventdata)
                set(roof_next_button,'Visible','ON') 
    end
 
% Create button if has exisiting solar
roof_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'On','Callback', @roof_click,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


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
    'String', 'Which orientation is your roof?', 'Visible', 'Off',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);

% Load Compass Image
[x,map]=imread('compass.jpg'); I2=imresize(x, [280 300]);
compass_image=uicontrol('style','pushbutton','units','normalized','position',[0.333 0.13 0.33 0.55],'cdata',I2, 'Visible', 'Off');
   
 % Orientations  Major     
radio_north_button = uicontrol('Units', 'normalized', 'Position',[0.52 0.61 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','N'); 

radio_south_button = uicontrol('Units', 'normalized', 'Position',[0.52 0.14 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','S');   

radio_west_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.33 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','W');  

radio_east_button = uicontrol('Units', 'normalized', 'Position',[0.63 0.33 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','E');  
 
% Orientations  Minor  
radio_north_west_button = uicontrol('Units', 'normalized', 'Position',[0.39 0.57 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','NW');      

radio_north_east_button = uicontrol('Units', 'normalized', 'Position',[0.61 0.57 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','NE');   

radio_south_west_button = uicontrol('Units', 'normalized', 'Position',[0.39 0.19 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','SW');  

radio_south_east_button = uicontrol('Units', 'normalized', 'Position',[0.61 0.19 0.02 0.05], 'Style', 'radio',...
    'Backgroundcolor', 'white', 'FontSize', 20, 'Visible', 'off','callback', @orientation_click,...
    'tag','SE');  

% Create button if has exisiting solar
orientation_next_button = uicontrol('Units', 'normalized', 'Position',[0.67 0.26 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next', 'Visible', 'Off','Callback', @orientation_next,...
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
                set(orientation_edit_display, 'String', 'North')             
            elseif strcmp(string, 'S')    
                set(orientation_edit_display, 'String', 'South') 
            elseif strcmp(string, 'E')
                set(orientation_edit_display, 'String', 'East')             
            elseif strcmp(string, 'W')    
                set(orientation_edit_display, 'String', 'West')  
            elseif strcmp(string, 'NE')    
                set(orientation_edit_display, 'String', 'North-East') 
            elseif strcmp(string, 'NW')
                set(orientation_edit_display, 'String', 'North-West')             
            elseif strcmp(string, 'SE')    
                set(orientation_edit_display, 'String', 'South-East') 
            elseif strcmp(string, 'SW')    
                set(orientation_edit_display, 'String', 'South-West') 
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
    'String', 'What is your post code?', 'Visible', 'Off',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);

%Set up pop up menu with pulldown data for states
state_codes = [4814 4825 4820];
state_names = ["QLD", "NSW", "VIC"];

postcode_edit = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.1], 'Style', 'edit',...
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
                       end   
        end        
    end

% Create display of state to confirm
state_display_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'text',...
    'String', 'Location','Visible', 'Off',...
    'Backgroundcolor', 'green', 'Foregroundcolor', 'black', 'FontSize', 20);

% Create button for next
state_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.2 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'Off','Callback', @state_click,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);


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
    'String', 'Cost of last quarter bill?', 'Visible', 'Off',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);

bill_edit = uicontrol('Units', 'normalized', 'Position', [0.35 0.5 0.3 0.1], 'Style', 'edit',...
   'Callback', @bill_next, 'tag', 'state_entry', 'Visible', 'Off', 'FontSize', 20);
   
    function bill_next(hObject, eventdata)    
       % Select the tag of each chosen object
        bill = str2double(get(postcode_edit,'string'));
        set(bill_next_button,'Visible','ON')                    
    end

% Create button for next
bill_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.2 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'Off','Callback', @bill_click,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20);

% Create function for end of state codes
    function bill_click(hObject, eventdata)
                set(text_bill_question,'Visible','Off')         
                set(bill_edit,'Visible','Off') 
                set(bill_next_button,'Visible','Off')  
    end


end