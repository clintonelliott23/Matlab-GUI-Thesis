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
'Color',white);

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
%% Orientation Image
% (1)Create axis which covers the entire GUI workspace
compass_image = axes('unit', 'pixels', 'position', [0.4 0.4 0.3 0.3]); 
% (2)import the background image and show it on the axes
background_image = imread('compass.jpg'); imagesc(compass_image);
% % (3) Turn the axis off and stop plotting from being permitable over the background
set(compass_image,'handlevisibility','off','visible','off')
% (4)Ensure all the other objects in the GUI are infront of the background
uistack(compass_image, 'top');
set(compass_image,'handlevisibility','ON','visible','ON')
%%%%%%%%%%%%%%


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
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'ON');


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
    end

%% Background 
% (1)Create axis which covers the entire GUI workspace
compass_image = axes('unit', 'pixels', 'position', [0.4 0.4 0.3 0.3]); 
% (2)import the background image and show it on the axes
background_image = imread('compass.jpg'); imagesc(compass_image);
% % (3) Turn the axis off and stop plotting from being permitable over the background
set(background_picture,'handlevisibility','off','visible','off')
% % (4)Ensure all the other objects in the GUI are infront of the background
% uistack(background_picture, 'bottom');
%% Roof Orientation
% Create function for roof parameters



text_orientation_question = uicontrol('Units', 'normalized', 'Position',[0.35 0.7 0.3 0.15], 'Style', 'text',...
    'String', 'Which orientation is your roof?', 'Visible', 'On',...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');

   
    function orientation_next(hObject, eventdata)
                set(orientation_next_button,'Visible','ON') 
    end
 
% Create button if has exisiting solar
orientation_next_button = uicontrol('Units', 'normalized', 'Position',[0.35 0.4 0.3 0.1], 'Style', 'pushbutton',...
    'String', 'Next','Visible', 'On','Callback', @orientation_click,...
    'Backgroundcolor', 'yellow', 'Foregroundcolor', 'black', 'FontSize', 20, 'Visible', 'OFF');


% Create function for battery question
    function orientaiton_click(hObject, eventdata) 
                set(Orientaiton_next_button,'Visible','OFF')                             
                
    end


%% Working Setup for Menu
% % Setup label text for popupmenu
% KW_popupmenu_label = uicontrol('Units', 'normalized', 'Position', [0.4 0.3 0.2 0.05], 'Style', 'text',...
%     'String', '(KW) Kilowatt', 'tag', 'label_for_EW', 'FontSize', 12);
% %Set up Pull down data
% KW_discrete_data = [0 3.5 5 7 9 15];
% %Set up pop up menu with pulldown data
% KW_popupmenu = uicontrol('Units', 'normalized', 'Position', [0.4 0.2 0.2 0.1], 'Style', 'popupmenu',...
%     'String', KW_discrete_data,'Callback', @display_selected_data, 'tag', 'KW_menu');
% %Display the chosen variable data in a text box next to the popupmenu
% KW_display = uicontrol('Units', 'Normalized', 'Position', [0.4 0.2 0.2 0.05],'String', 'Select KW', 'Style', 'text',...
%     'tag', 'KW_selection', 'Callback', @display_selected_data);
% %Set up function callback
%     function display_selected_data(hObject, eventdata)
%        % Select the tag of each chosen object
%         string = get(hObject, 'tag')
%         % Get the value of each object from the vector of discrete values
%         index = get(hObject, 'Value')  
% %Find which popupmenu was selected and update the variable display box
%             if strcmp(string, 'KW_menu')
%                 % Display the new value
%                 set(KW_display, 'String', num2str(KW_discrete_data(index)))
% %                  KW_value = (KW_discrete(index));
%             
%                 set(enter_gui_button,'Visible','OFF') 
% 
%             end
%     end











end