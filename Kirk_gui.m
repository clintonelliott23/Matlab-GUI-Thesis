function board_simulator ()
% This simulation is set-up as though the user has just returned % home from work and has not yet organized their discharge/charge schedule. 
  
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
TabHandles{NumTabs+1,3} = PanelHeight;     % Height of tab panel TabHandles{NumTabs+2,1} = 0;               % Handle to default tab 2 content(set later) 
TabHandles{NumTabs+2,2} = white;           % Background color 
TabHandles{NumTabs+2,3} = grey;            % Background color 
  
%% Build the tabs 
    for TabNumber = 1:NumTabs 
        TabHandles{TabNumber,1} = uipanel('Units','pixels',... 
            'Visible','off','BackgroundColor',white,'BorderWidth',1,...
            'Position',[TabOffset TabOffset PanelWidth PanelHeight]); 

        TabHandles{TabNumber,2} = uicontrol('Style','pushbutton',... 
            'Units','pixels','BackgroundColor',grey,...         
            'Position',[TabOffset+(TabNumber-1)*ButtonWidth PanelHeight+TabOffset... 
            ButtonWidth 
        ButtonHeight],'string',TabHandles{TabNumber,3},... 
                'HorizontalAlignment','center','FontName','arial','FontWeight','bold ',... 
                'FontSize',10); 
    end   

    %% Define the callbacks for the Tab Buttons for CountTabs = 1:NumTabs 

    set(TabHandles{CountTabs,2},'callback',{@TabSelectCallback,CountTabs}); 
end 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
  
%% Initialise variables, handles and general equations 
  
% Variable initialisation 
lt_profit = 0;              % long-term profit from cycle 
st_profit = 0;              % short-term profit from cycle 
  
peave = 0;                  % variable for storing average price        
peave0 = 0;                 % variable for storing average price 
check = 0;                  % flag used for schedule optimization 
  
user_spec = 0;              % variable for user specification of next  
                            % travel start time                                                       
charge_f = 0;           % Flag for how user chooses to charge their EV 
                        % 0 = not set 
                        % 1 = charge from grid, 2 = charge from home 
ESS  
discharge_f = 0;        % Flag for how user chooses to discharge their EV 
                        % 0 = not set, 1 = V2G, 2 = V2H, 3 = none 
  
  
% Function Handle initialisation sched2_h = @sched2_callback; sched3_h = @sched3_callback; sched_opt_h = @sched_opt_callback; 
  vis_handle = @vis_func;     % Handle for function to display HAN 
  
  
% Other general info 
hr = 16;                        % current hour 
mins = 58;                      % current minute 
Location = 'Townsville QLD';    % user location 
Tempc = 28.4;                   % current temperature, degrees celcius 
Tempf = Tempc*1.8+32;           % eqn to convert to degrees fahrenheit 
  
% Current electricity tariff: (where element i represents the hour between 
% the (i-1)th hour and the ith hour) 
tariff = [.19203 .19203 .19203 .19203 .19203 .19203 .19203 .23048 .23048 ... 
    .23048 .23048 .23048 .23048 .23048 .23048 .23048 .3404 .3404 .3404 ... 
    .3404 .23048 .23048 .23048 .23048];    
  current_price = tariff(hr+1);   % current electricity price 
  
  
% Available discharge and charge times, 0 means not available, 1 means % available: 
discharge_avail = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0]; 
charge_avail =    [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 1 1]; 
  
% Charging Station info: 
nc = 0.93;                      % charging efficiency 
nd = 0.93;                      % discharging efficiency % Charge and discharge rates are based on the eqn: (P = V x I) 
c_rate = (240*70)/1000;         % charging rate, kW d_rate = (240*70)/1000;         % discharging rate, kW 
  
% General Battery info: 
btype = 'Lithium-ion';      % battery type 
  bsize = 53;                 % battery rated size/capacity, kWh %bcost = 500*bsize;          % battery cost, $ (2015) bcost = 200*bsize;          % battery cost, $ (2020) bavail = 47.7;              % accessible capacity of battery, kWh DODmax = bavail/bsize;      % eqn to determine maximum allowable DOD 
  
% Battery ACC-DOD characteristics (as specified by manufacturer): 
CLvals = [4300 2500 1900 1550 1450 1300 1200 1000 750 550]; 
DODvals = [10 20 30 40 50 60 70 80 90 100]; 
  
% Battery monitored info: 
SOC = 90;                       % current battery SOC, % cycles_used = 10;               % no. of cycles the battery has currently 
                                % gone through 
SOHvals = [100 99.998 99.998 99.997 99.997 99.997 99.996 99.995 99.995 ... 
    99.995 99.994];             % stored SOH values SOHcurrent = SOHvals(end);      % current battery SOH bcap = bsize*SOHcurrent/100;    % current battery capacity % SOH trendline obtained via regression analysis (note the below function 
% was actually derived using a line of best fit in Microsoft Excel of a 2nd 
% order polynomial): 
%               SOH(c) = -7*10^(-6)*(c)^2-0.0003*(c)+100 
% where c = cycle count 
% Cycle life will be equal to the value of c for when SOH(c) = 80%: cycle_life = 1670; lifeleft = (cycle_life-cycles_used)/cycle_life*100; % cycles left (%) 
  
% In initial description, it is stated the user cycles their battery every 
% 3 days. Therefore, to find calendar life:  
% 1670 cycles * 3 days/cycle = 5010 days 
% 5010 days * 1 year / 365.25 days = 13.7166 years = 13 years & 9 months 
calendar_life = '13 yrs 9 mths'; inst_date = '01-MAR-2015'; exp_repl_date = '01-DEC-2028'; 
SOHreg = zeros(1,cycle_life+1); % empty array to store SOH values                                 % calculated from regression analysis 
                                % for use in the capacity fade profile 
  
% Obtain expected SOHave over battery lifetime 
SOHave = SOH_ave(cycle_life); 
SOHave = double(SOHave);        % convert to decimal form 
  
% Obtain optimal DOD and the equivalent LET for the battery: [DODopt,LETopt,CLopt] = LET_DOD(CLvals,DODvals,bsize,nc,nd); 
  
  
% Driving info - note that this information would be monitored while the EV 
% is being driven; however because the vehicle is stationary in this 
% example, the monitored parameters are equal to 0.  
Pin = 0;                   % kW Pout = 0;                  % kW 
ud = 0.13;                 % average historical driving efficiency, kWh/km 
udworst = 0.15;            % worst historical driving efficiency, kWh/km ue = 0;                    % emissions efficiency, g CO2/km 
  
% Distance travelled since last charge (in this simulation, the value is 
% obtained using the average driving efficiency, whereas in reality it 
% would be obtained by keeping count of the number of km travelled) 
Rdone = round((bcap*(100-SOC)/100)/ud); 
% Remaining range (km) is calculated based on optimal DOD, not max DOD 
% Thus the actual remaining range before user MUST recharge is actually 
% greater than what is displayed on the screen 
Rrem = round((bcap*(SOC-(100-DODopt))/100)/ud); 
D = 0;                          % remaining trip distance, km 
SOCf = SOC-((D*ud)/bcap);       % arrival SOC for current trip (%) 
  
% Parameters for discharge schedule: 
Re = 40;                        % user specified emergency range = 
40 km 
% Threshold SOC value where discharging needs to stop (%): 
SOCcut = (1-DODmax+(Re*1.2*udworst)/bcap)*100; 
  
% If the SOC value calculated above is less than SOCopt (i.e. 1 - 
DODopt),  
% then use SOCopt as the discharging threshold value if SOCcut <= (100-DODopt)     SOCcut = (100-DODopt); end 
AWCopt = bcost/(cycle_life*2*((100-SOCcut)/100)*bsize*SOHave/100); 
% Home info 
ESS = 60;                   % Home Energy Storage System SOC, %   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%   %% Tables: 
% The following are data arrays to be used in the various tables included % in this GUI. 
  
% Driving data (to be used when driving the EV): 
u_info = {'Power In' Pin '  kW'; 'Power Out' Pout '  kW';      'Efficiency' ud '  kWh / km'; 'Emissions' ue '  g CO2 / km';     'Arrival SOC' SOCf '  %'}; 
% Charging info (to be used when EV is charging): 
charge_info = {'Percent Complete' 0 ' %'; 'Remaining Time' 0 ' hours'; 
    'Power In' 0 ' kW'; 'Charge Rate' 0 ' kW'; 
    'Efficiency' nc*100 ' %'; 'Current Price' current_price ' $ / kWh'; 
    'Average Price' 0 ' $ / kWh'; 'Current Emissions' 0 ' g CO2 / kW'; 
    'Average Emissions' 0 'g CO2 / kWh';  'Total Cost' 0 ' $'; 
    'Total Emissions' 0 ' g CO2'}; 
% Discharging info (to be used when EV is discharging): discharge_info = {'Percent Complete' 0 ' %'; 'Remaining Time' 0 ' hours'; 
    'Power Out' 0 ' kW'; 'Power Received' 0 ' kW'; 
    'Efficiency' nd*100 ' %'; 'Current Price' current_price ' $ / kWh'; 
    'Average Price' 0 ' $ / kWh'; 'Total Income' 0 ' $'}; % Economics info (general info on the user's economic status): economics_info = {'Battery Cost' bcost ' $' ... 
    'Battery AWC' AWCopt ' $ / kWh';  
    'Average P/L per cycle' lt_profit ' $' ...     'Current P/L' lt_profit*cycles_used ' $'; 
    'Best cycle P/L' lt_profit ' $' ... 
    'Worst cycle P/L' lt_profit ' $'; 
    'Cycles Completed' cycles_used 'cycles' ... 
    'Cycles Remaining' (cycle_life-cycles_used) 'cycles'; 
    'Forecasted Total P/L' 0 ' $' '' '' ''; 
    'Total fuel P/L' 0 ' $' 'Fuel P/L per km' 0 ' $/km'; 
    'Total Expected km' 0 ' km' 'Total P/L per km' 0 ' $/km'}; % Battery info (general info on the EV battery, its health and current % condition: battery_info = {'Battery Type:' btype ... 
    'Rated Capacity' sprintf('%g kWh',bsize); 
    'Actual capacity:' sprintf('%g kWh',(bsize*SOHcurrent/100)) ... 
    'Available Capacity:' sprintf('%g kWh',bsize*SOHcurrent*DODmax/100);     'Installation Date:' inst_date ... 
    'Expected Replacement Date:' exp_repl_date; 
    'Calendar Life:' calendar_life ... 
    'Cycle Life:' sprintf('%g cycles',cycle_life); 
    'Optimal Depth of Discharge:' sprintf('%g %%',DODopt) ... 
    'Battery Cost:' sprintf('$ %g',bcost)';  
    'Cycles used:' sprintf('%g cycles',cycles_used) ... 
    'Average Wear Cost' sprintf('%g $ / kWh',AWCopt)};   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
  
%% Define content for the bottom panel of display % Display the time in the bottom left corner of the GUI uicontrol('Style','text','Position',[10 15 round(PanelWidth/2) 18],... 
    'string',sprintf('%d:%d',hr,mins),'BackgroundColor',white,... 
    
'HorizontalAlignment','left','FontName','arial','FontWeight','bold', ... 
    'FontSize',14); 
  
% Display the SOC gauge in the bottom right corner of the GUI axes('Units','pixels','Position',[980 18 100 15]); area1 = area([(1-SOC/100) 1],[1 1]); 
set(gca,'xtick',[]); set(gca,'ytick',[]); set(gca,'xlim',[0 1]);  set(gca,'ylim',[0 1]); if SOC <= 25         set(area1,'FaceColor','red');       % display as red if SOC is low elseif SOC <= 40     set(area1,'FaceColor','yellow');    % display as yellow if SOC is  
                                        % intermediate else 
    set(area1,'FaceColor','green');     % display as green if SOC is high end 
% Display the actual SOC percentage as text next to the gauge uicontrol('Style', 'text','Position', [830 15 140 18],... 
    'string',sprintf('Battery SOC: 
%d%%',SOC),'BackgroundColor','white',... 
    
'HorizontalAlignment','left','FontName','arial','FontWeight','bold', ... 
    'FontSize', 12); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
  
%% Define content for Home Tab % Create text string for the temperature celc = sprintf('%cC', char(176)); fahr = sprintf('%cF', char(176)); 
  
% Information box for temperature and location in upper right corner of GUI axes('Parent',TabHandles{1,1},'Units','pixels',... 
    'Position',[935 483 152 85]); area([0 1],[1 1], 'FaceColor', grey); axis off; axes('Parent',TabHandles{1,1},'Units','pixels','Position',[945 496 
40 40]); imsc=4; 
suni=imread('sunny.jpg');           % Assume sunny weather sunj=imresize(suni,imsc); image(sunj); axis off; uicontrol('Style','text','Parent', TabHandles{1,1},... 
    'Position', [943 540 120 20],'string', Location,... 
    'BackgroundColor',grey,'HorizontalAlignment','left',...     'FontName','arial','FontWeight','bold','FontSize',11); tempt = uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position', [990 496 90 36],'string', num2str(Tempc),... 
    'BackgroundColor', grey,'HorizontalAlignment', 'left',...     'FontName', 'arial','FontWeight', 'normal','FontSize', 28); 
tempb = uicontrol('Style', 'pushbutton','Parent', TabHandles{1,1},... 
    'Position', [1065 510 18 18],'string', celc,....     'BackgroundColor',0.1*grey,'ForegroundColor',white,'FontSize', 9,... 
    
'HorizontalAlignment','left','FontName','arial','FontWeight','bold')
;   
tempf = 0;              % temp flag (0 means celcius, 1 mean fahrenheit) set(tempb,'Callback',{@temp_callback}); 
    % function for converting between degrees celcius and fahrenheit     function temp_callback(hObject,eventdata,handles)         if tempf == 0             tempf = 1;             set(tempb,'string',fahr);             set(tempt,'string',num2str(Tempf));         elseif tempf == 1             tempf = 0;             set(tempb,'string',celc);             set(tempt,'string',num2str(Tempc));         end     end 
  
% Information box for remaining range display axes('Parent',TabHandles{1,1},'Units','pixels','Position',[5 483 925 
85]); 
area([0 1],[1 1], 'FaceColor', grey); axis off; uicontrol('Style', 'text','Parent', TabHandles{1,1},...     'Position',[20 520 910 35],... 
    'string',sprintf('Remaining Range: %d km',Rrem),... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 16); uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position',[20 485 910 35],... 
    'string',...     sprintf('Distance travelled since last charge: %d km',Rdone),...     'BackgroundColor', grey,'HorizontalAlignment', 'center',... 
    'FontName', 'arial','FontWeight', 'bold','FontSize', 16); 
  
% Driving Information Table: 
uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position', [8 452 355 25],'string', 'DRIVING',... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); ustat = uitable('Position',[8 255 355 195],'Parent', TabHandles{1,1},... 
    'Data',u_info,'RowName',[],'ColumnName',[],'FontSize',12,... 
    'ColumnWidth',{151 81 121}); 
  
% Charging Information Table: 
uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position', [368 452 355 25],'string', 'CHARGING',... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); cstat = uitable('Position',[368 255 355 195],'Parent', TabHandles{1,1},... 
    
'Data',charge_info,'RowName',[],'ColumnName',[],'FontSize',12,... 
    'ColumnWidth',{151 81 121}); 
  
% Discharging Information Table: 
uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position', [728 452 355 25],'string', 'DISCHARGING',... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); dstat = uitable('Position',[728 255 355 195],'Parent', TabHandles{1,1},... 
    
'Data',discharge_info,'RowName',[],'ColumnName',[],'FontSize',12,... 
    'ColumnWidth',{151 81 121}); 
  
% Vehicle Economics Table: uicontrol('Style', 'text','Parent', TabHandles{1,1},... 
    'Position', [8 215 1076 25],'string', 'VEHICLE ECONOMICS',...     'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); economics = uitable('Position',[123 46 842 164],... 
    'Parent', TabHandles{1,1},... 
    
'Data',economics_info,'RowName',[],'ColumnName',[],'FontSize',12,... 
    'ColumnWidth',{200 100 120 200 100 120}); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
  
%% Define content for Battery Tab % Battery Information Table: 
ColumnWidths = {900*1.22/4 900*.78/4 900*1.22/4 900*.78/4}; uicontrol('Style', 'text','Parent', TabHandles{2,1},... 
    'Position', [8 545 1076 25],'string', 'BATTERY INFORMATION',...     'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); uitable('Position',[80 400 900 140],'Parent', TabHandles{2,1},... 
    'ColumnWidth', ColumnWidths,'FontSize', 11,'RowName',[],... 
    'ColumnName',[],'Data', battery_info); 
  
% Capacity Fade Profile: 
uicontrol('Style', 'text','Parent', TabHandles{2,1},...     'Position', [8 370 1076 25],'string', 'CAPACITY FADE PROFILE',... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); bcapax = axes('Parent',TabHandles{2,1},'Units','pixels','Visible','on',... 
    'Position', [80 205 900 150]); for c1 = 0:1:cycle_life 
    SOHreg(c1+1) = (-7*10^(-6)*(c1)^2-0.0003*(c1)+100); end 
plot(0:1:cycles_used,SOHvals,'b--*',0:1:cycle_life,SOHreg,'r') set(bcapax, 'ylim', [80 100])   % bottom SOH value = 80% as this is the  
                                % recommended replacement SOH based on 
                                % literature set(bcapax, 'xlim', [0 cycle_life]); xlabel('Cycle Count'); ylabel('SOH (%)'); grid on; 
  
% Life Expectancy Bar: 
uicontrol('Style', 'text','Parent', TabHandles{2,1},... 
    'Position', [8 136 1076 25],'string','% CYCLES USED',... 
    'BackgroundColor', grey,'HorizontalAlignment', 'center',...     'FontName', 'arial','FontWeight', 'bold','FontSize', 14); leb = axes('Parent', TabHandles{2,1},... 
    'Units', 'pixels',... 
    'Visible', 'off',... 
    'Position', [15 68 (PanelWidth-50) 40]); area3 = area([((100-lifeleft)/100)*cycle_life cycle_life],[1 1],... 
    'FaceColor', 'green'); set(leb,'Color','b'); set(gca, 'xtick',[0:(cycle_life/5):cycle_life]); set(gca, 'ytick',[]); set(gca, 'xlim', [0 cycle_life]);             set(gca, 'ylim', [0 1]); battlife = sprintf('%g%% used                                                    
%g%% remaining', (100-lifeleft), lifeleft); title(battlife) xlabel('Battery Life (cycles)'); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%% 
  
%% Define content for Schedule Tab 
  
% Set up all corresponding texts and buttons for the prompts included in % the schedule tab: sched_b = uicontrol('Style','pushbutton','Parent',TabHandles{3,1},...     'Position',[445 280 200 50],'string','Organize Schedule',... 
    'FontName','arial','FontSize',14,'Visible','on'); sched_b1 = uicontrol('Style','pushbutton','Parent',TabHandles{3,1},...     'Position',[345 280 200 50],'string','From Grid',...     'FontName','arial','FontSize',14,'Visible','off'); sched_b2 = uicontrol('Style','pushbutton','Parent',TabHandles{3,1},...     'Position',[545 280 200 50],'string','From Home',...     'FontName','arial','FontSize',14,'Visible','off'); sched_b3 = uicontrol('Style','pushbutton','Parent',TabHandles{3,1},... 
    'Position',[445 230 200 50],'string','None',...     'FontName','arial','FontSize',14,'Visible','off'); sched_b4 = uicontrol('Style','pushbutton','Parent',TabHandles{3,1},...     'Position',[445 180 200 50],'string','Enter',...     'FontName','arial','FontSize',14,'Visible','off'); sched_e1 = uicontrol('Style','edit','Position',[445 280 200 50],... 
    'String','','Visible','off','Parent',TabHandles{3,1},... 
    'FontSize',14,'BackgroundColor','white'); sched_s1 = uicontrol('Style','text','Position',[405 330 280 50],... 
    
'BackgroundColor',white,'Visible','off','Parent',TabHandles{3,1},... 
    'string','How would you like to charge today?','FontSize',16); sched_s2 = uicontrol('Style','text','Position',[445 230 200 50],... 
    
'BackgroundColor',white,'Visible','off','Parent',TabHandles{3,1},...     'string','e.g. 7 (7am) or 14 (2pm) (0 = midnight)','FontSize',11); sched_s3 = uicontrol('Style','text','Position',[445 120 200 50],... 
    
'BackgroundColor',white,'Visible','off','Parent',TabHandles{3,1},... 
    'ForegroundColor',[1 0 0],'string','INCORRECT FORMAT','FontSize',11); sched_s4 = uicontrol('Style','text','Position',[15 490 400 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',14,'string','Your vehicle is scheduled to charge at:'); sched_s5 = uicontrol('Style','text','Position',[645 490 400 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',14,'string','Your vehicle is scheduled to discharge at:'); sched_s6 = uicontrol('Style','text','Position',[15 440 400 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',... 
    'FontSize',18,'string',''); sched_s7 = uicontrol('Style','text','Position',[645 440 400 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',... 
    'FontSize',18,'string',''); sched_s8 = uicontrol('Style','text','Position',[50 380 400 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',... 
    'FontSize',14,'string','Charging Duration:',... 
    'HorizontalAlignment','left'); sched_s9 = uicontrol('Style','text','Position',[50 330 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',... 
    'FontSize',14,'string','Charging Costs:',... 
    'HorizontalAlignment','left'); sched_s10 = uicontrol('Style','text','Position',[665 380 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',... 
    'FontSize',14,'string','Discharging Duration:',... 
    'HorizontalAlignment','left'); sched_s11 = uicontrol('Style','text','Position',[665 330 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',... 
    'FontSize',14,'string','Discharging Revenue/Savings:',... 
    'HorizontalAlignment','left'); sched_s12 = uicontrol('Style','text','Position',[300 380 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',14,'string','','HorizontalAlignment','left'); sched_s13 = uicontrol('Style','text','Position',[300 330 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',14,'string','','HorizontalAlignment','left'); sched_s14 = uicontrol('Style','text','Position',[945 380 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',14,'string','','HorizontalAlignment','left'); sched_s15 = uicontrol('Style','text','Position',[945 330 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',14,'string','','HorizontalAlignment','left'); sched_s16 = uicontrol('Style','text','Position',[50 230 240 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',15,'string','Short-term Profit/Loss for this cycle:',... 
    'HorizontalAlignment','left'); sched_s17 = uicontrol('Style','text','Position',[50 180 240 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',15,'string','Long-term Profit/Loss for this cycle:',... 
    'HorizontalAlignment','left'); sched_s18 = uicontrol('Style','text','Position',[300 230 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',15,'string','','HorizontalAlignment','left'); sched_s19 = uicontrol('Style','text','Position',[300 180 300 50],... 
    
'Parent',TabHandles{3,1},'BackgroundColor',white,'Visible','off',...     'FontSize',15,'string','','HorizontalAlignment','left'); clear_button = uicontrol('Style','pushbutton','Parent',TabHandles{3,1},... 
    'Position',[445 60 200 50],'string','Clear and Restart',... 
    'FontName','arial','FontSize',14,'Visible','on'); 
  
% Create pushbutton functions         set(sched_b,'Callback',{@sched1_callback}); set(clear_button,'Callback',{@clear_callback}); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
  
%% Define content for Smart Home Tab % Create two sub-tabs within smart home page home_tabs = 2; home_labels = {'Household Consumption';'Home Area Connection'}; 
TabHandles2 = cell(home_tabs,2); 
TabHandles2(:,2) = home_labels(1:home_tabs,1); for tabnumber = 1:home_tabs 
    % Create pushbuttons 
    TabHandles2{tabnumber,1} = uicontrol('Style', 'pushbutton',... 
        'Parent', TabHandles{4,1},'Units', 'pixels',... 
        'Position', [5 465+(tabnumber-1)*(55) 200 45],... 
        'String', TabHandles2(tabnumber,2),... 
        'FontName', 'arial','FontWeight', 'bold','FontSize', 9); end set(TabHandles2{2,1}, 'Backgroundcolor', 'white'); 
  
netshow = 1;      % variable for displaying home network in smart home tab 
set(TabHandles2{2,1}, 'Callback', {@connect_callback}); set(TabHandles2{1,1}, 'Callback', {@home_callback});   
%%%%%%%%%%%%%%%%%%%%% HOME AREA CONNECTION TAB 
%%%%%%%%%%%%%%%%%%%%%%%%% 
% SMART METER meterb = uicontrol('Style', 'pushbutton',... 
    'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},...     'Units','pixels','Position',[540 330 150 50],...     'String','SMART METER','Visible','on',... 
    'ForegroundColor', [1 1 1],... 
    'FontName','arial','FontWeight','bold','FontSize',10); 
% HOUSEHOLD homeb = uicontrol('Style', 'pushbutton',... 
    'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},... 
    'Units','pixels','Position',[540 450 155 50],... 
    'String','HOUSEHOLD','Visible','on',... 
    'ForegroundColor', [1 1 1],... 
    'FontName','arial','FontWeight','bold','FontSize',10); 
% BATTERY batb = uicontrol('Style', 'pushbutton',... 
    'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},... 
    'Units','pixels','Position',[340 415 155 50],... 
    'String','BATTERY SYSTEM','Visible','on',... 
    'ForegroundColor', [1 1 1],... 
    'FontName','arial','FontWeight','bold','FontSize',10); 
% RENEWABLE SOURCE renb = uicontrol('Style', 'pushbutton',... 
    'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},... 
    'Units','pixels','Position',[420 215 155 50],... 
    'String','RENEWABLE SOURCE','Visible','on',... 
    'ForegroundColor', [1 1 1],... 
    'FontName','arial','FontWeight','bold','FontSize',10); 
% CHARGE STATION chargb = uicontrol('Style', 'pushbutton',... 
    'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},... 
    'Units','pixels','Position',[660 215 155 50],... 
    'String','CHARGING STATION','Visible','on',... 
    'ForegroundColor', [1 1 1],... 
    'FontName','arial','FontWeight','bold','FontSize',10); 
% EV DISPLAY dispb = uicontrol('Style', 'pushbutton',... 
    'BackgroundColor',[0 0.04 0.25],'Parent',TabHandles{4,1},... 
    'Units','pixels','Position',[740 415 155 50],... 
    'String','IN-VEHICLE DISPLAY','Visible','on',... 
    'ForegroundColor', [1 1 1],... 
    'FontName','arial','FontWeight','bold','FontSize',10); 
%%% ARROWS arr1 = axes('Parent', TabHandles{4,1},'Units', 'pixels',...     'Visible', 'on','Position', [705 357 120 50]); imsc = 4; 
read1 = imread('arrow1.jpg');arrow1 = imresize(read1,imsc);image(arrow1); axis off;   arr2 = axes('Parent', TabHandles{4,1}, ... 
    'Units', 'pixels', ... 
    'Visible', 'on',...     'Position', [410 355 120 50]); imsc = 4; 
read1 = imread('arrow2.jpg');arrow2 = imresize(read1,imsc);image(arrow2); axis off;   arr3 = axes('Parent', TabHandles{4,1}, ... 
    'Units', 'pixels', ... 
    'Visible', 'on',...     'Position', [604 382 20 64]); imsc = 4; 
read1 = imread('arrow3.jpg');arrow3 = imresize(read1,imsc);image(arrow3); axis off;   arr4 = axes('Parent', TabHandles{4,1}, ... 
    'Units', 'pixels', ... 
    'Visible', 'on',...     'Position', [490 270 40 80]); imsc = 4; 
read1 = imread('arrow4.jpg');arrow4 = imresize(read1,imsc);image(arrow4); axis off;   arr5 = axes('Parent', TabHandles{4,1}, ... 
    'Units', 'pixels', ... 
    'Visible', 'on',...     'Position', [705 270 40 80]); imsc = 4; 
read1 = imread('arrow5.jpg');arrow5 = imresize(read1,imsc);image(arrow5); axis off; 
  
%%% CONNECTION STATUSES yes1b = uicontrol('Style','pushbutton',... 
    'Parent',TabHandles{4,1},...     'Visible','on',...     'Position',[455 358 30 20]); 
read1 = imread('yes.jpg');imsc = 0.27;yes1 = imresize(read1,imsc); set(yes1b, 'CData', yes1); 
  yes2b = uicontrol('Style','pushbutton',... 
    'Parent',TabHandles{4,1},...     'Visible','on',...     'Position',[600 405 30 20]); 
read1 = imread('yes.jpg');imsc = 0.27;yes2 = imresize(read1,imsc); set(yes2b, 'CData', yes2); 
  yes3b = uicontrol('Style','pushbutton',... 
    'Parent',TabHandles{4,1},...     'Visible','on',...     'Position',[750 356 30 20]); 
read1 = imread('yes.jpg');imsc = 0.27;yes3 = imresize(read1,imsc); set(yes3b, 'CData', yes3); 
  yes4b = uicontrol('Style','pushbutton',... 
    'Parent',TabHandles{4,1},...     'Visible','on',...     'Position',[480 300 30 20]); 
read1 = imread('yes.jpg');imsc = 0.27;yes4 = imresize(read1,imsc); set(yes4b, 'CData', yes4); 
  yes5b = uicontrol('Style','pushbutton',... 
    'Parent',TabHandles{4,1},...     'Visible','on',...     'Position',[719 300 30 20]); 
read1 = imread('yes.jpg');imsc = 0.27;yes5 = imresize(read1,imsc); set(yes5b, 'CData', yes5); 
  
% Communication Link descriptions: 
hstr1 = sprintf('Battery System to Smart Meter:\nCurrent Energy Density, Maximum Capacity, Current Activity Status'); hstr2 = sprintf('Home to Smart Meter:\nCurrent Consumption, Active 
Appliances, Appliance Schedule\nSmart Meter to Home:\nElectricity Prices'); hstr3 = sprintf('Smart Meter to EV Display:\nElectricity Prices, Home Consumption, Battery Status, Renewable Generation Status\nEV Display to Smart Meter:\nCharge and Discharge Schedule (Times and Durations)'); 
hstr4 = sprintf('Renewable Source to Smart Meter:\nCurrent Generation (kW)'); 
hstr5 = sprintf('Smart Meter to Charging Station:\nCharge and 
Discharge Times and Durations'); 
  txt1 = uicontrol('Style', 'text','Parent',TabHandles{4,1},... 
    'Visible', 'off','Position', [328 80 600 100],...     'BackgroundColor', white,'string', hstr1,'FontSize',13); txt2 = uicontrol('Style', 'text','Parent',TabHandles{4,1},... 
    'Visible', 'off','Position', [328 80 600 100],...     'BackgroundColor', white,'string', hstr2,'FontSize',13); txt3 = uicontrol('Style', 'text','Parent',TabHandles{4,1},... 
    'Visible', 'off','Position', [328 80 600 100],...     'BackgroundColor', white,'string', hstr3,'FontSize',13); txt4 = uicontrol('Style', 'text','Parent',TabHandles{4,1},... 
    'Visible', 'off','Position', [328 80 600 100],...     'BackgroundColor', white,'string', hstr4,'FontSize',13); txt5 = uicontrol('Style', 'text','Parent',TabHandles{4,1},... 
    'Visible', 'off','Position', [328 80 600 100],... 
    'BackgroundColor', white,'string', hstr5,'FontSize',13);   
% Create function callbacks for displaying the communication link 
% descriptions 
set(yes1b, 'Callback', {@yes1b_callback}); set(yes2b, 'Callback', {@yes2b_callback}); set(yes3b, 'Callback', {@yes3b_callback}); set(yes4b, 'Callback', {@yes4b_callback}); set(yes5b, 'Callback', {@yes5b_callback}); 
    
%%%%%%%%%%%%%%%%%%%%% CONSUMPTION TAB %%%%%%%%%%%%%%%%%%%%%%%%% 
% Hours of the day x1 = 0.5:1:23.5; 
% Hourly Household Energy Consumption, kWh (arbitrary data) y1 = [0.22 0.25 0.25 0.25 0.24 0.28 0.31 0.34 0.36 0.33 0.32 0.3 0.3 
0.28 0.29 0.34 0.36 0.41 0.46 0.51 0.49 0.4 0.33 0.25]; % Hourly Prices 
y22 = [19.2 19.2 19.2 19.2 19.2 19.2 19.2 23.0 23.0 23.0 23.0 23.0 
23.0 23.0 23.0 23.0 34 34 34 34 23.0 23.0 19.2 19.2]; % Consumption Costs y3 = (y1.*y22)/100; 
% Calculated daily cost and expected monthly bill: 
todcost = sum(y3); montcost = todcost*12; estcost = todcost*30; % Display these costs: 
ctxt = sprintf('Cost Today:\n$%g\nCost This Month To 
Date:\n$%g\nEstimated Month Bill:\n$%g',todcost,montcost,estcost); bill_txt = uicontrol('Style', 'text',... 
    'Parent', TabHandles{4,1},... 
    'Position',[30 90 140 120],... 
    'string','Household Costs:',...     'BackgroundColor',white,...     'FontName','arial',... 
    'FontWeight','bold',...     'FontSize',12); bill_txt2 = uicontrol('Style', 'text',... 
    'Parent', TabHandles{4,1},... 
    'Position',[15 55 170 130],... 
    'string',ctxt,... 
    'BackgroundColor',white,... 
    'FontName','arial',... 
    'FontWeight','bold',... 
    'FontSize',11); % Display Home ESS SOC Gauge axes('Units','pixels','Parent',TabHandles{4,1},'Position',[30 230 
140 200]); 
area2 = area([0 1],[(ESS/100) (ESS/100)]); 
set(gca,'xtick',[]); set(gca,'ytick',[]); set(gca,'xlim',[0 1]); set(gca,'ylim',[0 1]); if ESS <= 25     set(area2,'FaceColor','red'); elseif ESS <= 40     set(area2,'FaceColor','yellow'); else 
    set(area2,'FaceColor','green'); end uicontrol('Style', 'text','Position', [30 430 140 20],'Parent',TabHandles{4,1},... 
    'string', sprintf('Home ESS: %d%%',ESS),'BackgroundColor', 'white',... 
    'HorizontalAlignment', 'center','FontName', 'arial','FontWeight', 'bold',... 
    'FontSize', 12); 
  
% Display consumption (kWh) and expense ($) profiles and electrity tariff: consumption_ax = axes('Parent', TabHandles{4,1},... 
    'Units', 'pixels',... 
    'xlim', [0 24],... 
    'ylim', [0 30],... 
    'Visible','off',... 
    'Position', [330 330 630 200]); price_ax = axes('Parent', TabHandles{4,1},... 
    'Units', 'pixels',... 
    'xlim', [0 24],... 
    'ylim', [0 30],... 
    'Visible','off',... 
    'Position', [330 80 630 200],... 
    'FontSize',9); 
  
% Consumption and expense profiles: 
axes(consumption_ax); 
[cons_ax1,c2,c1] = plotyy(x1,y3,x1,y1,'bar','plot'); xlabel('Time of day [hr]','FontWeight','bold'); 
ylabel(cons_ax1(2),'Hourly Consumption [kWh]','FontWeight', 'bold'); ylabel(cons_ax1(1),'Hourly Cost [$]','FontWeight', 'bold'); set(cons_ax1, 'xlim', [0 24]); set(cons_ax1, 'xtick', [0:1:24]); set(cons_ax1, 'FontSize', 7.5); set(cons_ax1(1), 'YColor', [0.95 0 0]); set(cons_ax1(1), 'ytick', [0:0.05:0.2]); set(cons_ax1(2), 'YColor', [0 0 0.65]); set(cons_ax1(2), 'XColor', [0 0 0.65]); 
set(cons_ax1(1), 'XColor', [0 0 0.65]); set(cons_ax1(2), 'ytick', [0:0.1:0.6]); set(cons_ax1(2), 'ygrid', 'on'); set(c2, 'BarWidth', 1); set(c2, 'FaceColor', [0.95 0 0]); set(c1, 'Color', [0 0 0.65]); set(c1, 'LineWidth', 2); set(cons_ax1,'Visible','off'); set(c1,'Visible','off'); set(c2,'Visible','off'); 
  
% Tariff graph: axes(price_ax); dgf = bar(x1,y22,1); 
xlabel('Time of day [hr]','FontWeight','bold'); ylabel('Electricity Price [cents/kWh]','FontWeight', 'bold'); set(gca, 'xlim', [0 24]); set(gca, 'ylim', [0 40]); set(gca, 'xtick', [0:1:24]); set(gca, 'ytick', [0:5:40]); set(gca, 'ygrid', 'on'); set(gca, 'YColor', [0 0.4 0]); set(gca, 'XColor', [0 0.4 0]); set(dgf, 'FaceColor', [0 0.7 0]); set(price_ax,'Visible','off'); 
set(get(price_ax,'children'),'Visible','off'); 
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
  
%% Nested Functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%% SCHEDULE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%% % Clear Callback: 
    function clear_callback(hObject,eventdata,handles)         set(sched_b,'Visible','on');  
        set(sched_b1,'Style','pushbutton','Parent',TabHandles{3,1},...             'Position',[345 280 200 50],'string','From Grid',... 
            'FontName','arial','FontSize',14,'Visible','off'); 
        set(sched_b2,'Style','pushbutton','Parent',TabHandles{3,1},...             'Position',[545 280 200 50],'string','From Home',... 
            'FontName','arial','FontSize',14,'Visible','off');  
        set(sched_b3,'Style','pushbutton','Parent',TabHandles{3,1},...             'Position',[445 230 200 50],'string','None',... 
            'FontName','arial','FontSize',14,'Visible','off'); 
        set(sched_b4,'Style','pushbutton','Parent',TabHandles{3,1},... 
            'Position',[445 180 200 50],'string','Enter',...             'FontName','arial','FontSize',14,'Visible','off');          set(sched_e1,'Style','edit','Position',[445 280 200 50],...             'String','','Visible','off','Parent',TabHandles{3,1},... 
            'FontSize',14,'BackgroundColor','white');         set(sched_s1,'Style','text','Position',[405 330 280 50],... 
            'BackgroundColor',white,'Visible','off',...             'Parent',TabHandles{3,1},... 
            'string','How would you like to charge today?');          set(sched_s2,'Visible','off');         set(sched_s3,'Visible','off');          set(sched_s4,'Visible','off');         set(sched_s5,'Visible','off');          set(sched_s6,'Visible','off');         set(sched_s7,'Visible','off');          set(sched_s8,'Visible','off');         set(sched_s9,'Visible','off');          set(sched_s10,'Visible','off');         set(sched_s11,'Visible','off');          set(sched_s12,'Visible','off');         set(sched_s13,'Visible','off');          set(sched_s14,'Visible','off');         set(sched_s15,'Visible','off');         set(sched_s16,'Visible','off');         set(sched_s17,'Visible','off');         set(sched_s18,'Visible','off');         set(sched_s19,'Visible','off');         charge_f = 0;         discharge_f = 0;     end   
    function sched1_callback(hObject,eventdata,handles)         set(sched_b,'Visible','off');         set(sched_s1,'Visible','on');         set(sched_b1,'Visible','on');         set(sched_b2,'Visible','on'); 
        set(sched_b1,'Callback',{@charge_grid_callback});         set(sched_b2,'Callback',{@charge_home_callback});         function charge_grid_callback(hObject,eventdata,handles)             charge_f = 1;             sched2_h();         end         function charge_home_callback(hObject,eventdata,handles)             charge_f = 2;             sched2_h();         end     end   
    function sched2_callback(hObject,eventdata,handles)         set(sched_s1,'string','How would you like to discharge today?');         set(sched_b1,'string','To Grid');         set(sched_b2,'string','To Home');         set(sched_b3,'Visible','on'); 
        set(sched_b1,'Callback',{@discharge_grid_callback});         set(sched_b2,'Callback',{@discharge_home_callback});         set(sched_b3,'Callback',{@none_callback}); 
        function discharge_grid_callback(hObject,eventdata,handles)             discharge_f = 1;             sched3_h();         end         function discharge_home_callback(hObject,eventdata,handles)             discharge_f = 2;             sched3_h();         end         function none_callback(hObject,eventdata,handles)             discharge_f = 3;             sched3_h();         end 
    end   
    function sched3_callback(hObject,eventdata,handles)         set(sched_s1,'string','Please specify what hour you will next require your vehicle:');         set(sched_s2,'Visible','on');         set(sched_b1,'Visible','off');         set(sched_b2,'Visible','off');         set(sched_b3,'Visible','off');         set(sched_b4,'Visible','on');         set(sched_e1,'Visible','on'); 
        set(sched_b4,'Callback',{@user_spec_callback}); 
         
        function user_spec_callback(hObject,eventdata,handles)             format = 0;             user_spec = str2num(get(sched_e1,'string'));             for i = 0:23                 if user_spec == i                     format = 1;                 end             end             if format == 0 
                set(sched_s3,'Visible','on'); 
                             else                 set(sched_s3,'Visible','off');                 set(sched_s1,'Visible','off');                 set(sched_s2,'Visible','off');                 set(sched_b4,'Visible','off');                 set(sched_e1,'Visible','off');                 sched_opt_h();                                  end         end     end       function sched_opt_callback(hObject,eventdata,handles) 
        % Organize discharge schedule: 
        if discharge_f == 1 || discharge_f == 2 
            % Find discharge duration:             discharge_dur = ((SOC-SOCcut)/100*bcap)/(d_rate/nd); 
            % Find timeslot with highest average price:             for i = (hr+2):(24-ceil(discharge_dur)+1)                 check = 0; 
                if discharge_avail(i) == 1                     for j = 1:ceil(discharge_dur)                         if discharge_avail(i+j-1) == 1                             check = check + 1;                         end                     end 
                    if check == ceil(discharge_dur) 
                        % It will be possible to start discharging at that 
                        % time - check the price of that time                         peave = 0; 
                        for j = 1:ceil(discharge_dur)                             if discharge_dur-j < 0                                 peave = peave+tariff(i+j-
1)*(discharge_dur-floor(discharge_dur));                             else 
                                peave = peave+tariff(i+j-1); 
                            end                         end 
                        peave = peave/discharge_dur;                         if peave0 == 0                             discharge_start = i-1;                             peave0 = peave;                         elseif peave > peave0                             discharge_start = i-1;                             peave0 = peave;                         end                     end                 end             end 
            % Once this function is ended, the start time will be equal to 
            % (discharge_start). Remember we want to maximize price for 
            % discharging and thus find the highest value for peave         elseif discharge_f == 3             discharge_dur = 0;             discharge_start = NaN;         end 
        % Discharge revenue as given by eqn 32: 
        discharge_rev = peave0*d_rate*discharge_dur; 
        % Equivalent AWC cost for discharging: 
        discharge_awc = AWCopt*(d_rate/nd)*discharge_dur; 
         
        % Find equivalent averages of these parameters for  
        % long term profit/loss analysis: 
        if discharge_f == 3             discharge_dur_ave = 0;         else             discharge_dur_ave = ((SOCSOCcut)/100*bsize*SOHave/100)/(d_rate/nd);         end            discharge_revave = peave0*d_rate*discharge_dur_ave;         discharge_awcave = AWCopt*(d_rate/nd)*discharge_dur_ave; 
         
        % Charging occurs from V2G cutoff SOC back to 100% SOC         charge_dur = ((100-SOCcut)/100*bcap)/(c_rate*nc);         peave0 = 0;         check1 = 0; 
        % Organize charge schedule: 
        if discharge_f ~= 3 
            % i.e. if user has specified discharging         if charge_f == 1             for i = 
(discharge_start+1+ceil(discharge_dur)):(25+user_specceil(charge_dur))                 check = 0;                 if i < 25 
                    if charge_avail(i) ==  1                         check1 = 1;                     end                 else                     if charge_avail(i-24) == 1                         check1 = 1;                     end                 end                 if check1 == 1                     for j =1:ceil(charge_dur)                         if (i+j-1) < 25 
                            if charge_avail(i+j-1) == 1                                 check = check + 1;                             end                         else 
                            if charge_avail(i+j-25) == 1                                 check = check + 1;                             end                         end                     end                     if check == ceil(charge_dur)                         peave = 0; 
                        for j = 1:ceil(charge_dur)                             if charge_dur-j < 0                                 if (i+j-1) < 25 
                                    peave = peave+tariff(i+j-
1)*(charge_dur-floor(charge_dur));                                 else                                     peave = peave+tariff(i+j-
25)*(charge_dur-floor(charge_dur));                                 end                             else                                 if (i+j-1) < 25 
                                    peave = peave+tariff(i+j-1);                                 else 
                                    peave = peave+tariff(i+j-25);                                 end                             end                         end 
                        peave = peave/charge_dur;                         if peave0 == 0                             if i < 25                                 charge_start = i-1;                             else 
                                charge_start = i-25;                             end                             peave0 = peave;                         elseif peave < peave0                             if i < 25                                 charge_start = i-1;                             else 
                                charge_start = i-25;                             end                             peave0 = peave;                         end                     end                 end             end 
            % Charge expense due to purchasing electricity: 
            charge_expense = peave0*c_rate*charge_dur; 
            % Equivalent AWC cost for charging: 
            charge_awc = AWCopt*c_rate*nc*charge_dur;         elseif charge_f == 2 
            % This schedule algorithm hasn't accounted for when the home 
            % ESS is sufficiently full, nor has household consumption been  
            % taken into account in this algorithm. 
            charge_start = discharge_start+ceil(discharge_dur);             charge_expense = 0; 
            charge_awc = AWCopt*c_rate*nc*charge_dur; 
end 
        else 
            % i.e. if user specified no discharging         if charge_f == 1             for i = (hr+2):(25+user_spec-ceil(charge_dur))                 check = 0;                 if i < 25 
                    if charge_avail(i) ==  1                         check1 = 1;                     end                 else                     if charge_avail(i-24) == 1                         check1 = 1;                     end                 end                 if check1 == 1                     for j =1:ceil(charge_dur)                         if (i+j-1) < 25                             if charge_avail(i+j-1) == 1                                 check = check + 1;                             end                         else 
                            if charge_avail(i+j-25) == 1                                 check = check + 1;                             end                         end                     end                     if check == ceil(charge_dur)                         peave = 0;                         for j = 1:ceil(charge_dur)                             if charge_dur-j < 0                                 if (i+j-1) < 25 
                                    peave = peave+tariff(i+j-
1)*(charge_dur-floor(charge_dur));                                 else                                     peave = peave+tariff(i+j-
25)*(charge_dur-floor(charge_dur));                                 end                             else                                 if (i+j-1) < 25 
                                    peave = peave+tariff(i+j-1);                                 else 
                                    peave = peave+tariff(i+j-25);                                 end                             end                         end 
                        peave = peave/charge_dur;                         if peave0 == 0                             if i < 25                                 charge_start = i-1;                             else 
                                charge_start = i-25;                             end                             peave0 = peave;                         elseif peave < peave0                             if i < 25                                 charge_start = i-1;                             else 
                                charge_start = i-25;                             end                             peave0 = peave; 
                        end                     end                 end             end 
            % Charge expense due to purchasing electricity: 
            charge_expense = peave0*c_rate*charge_dur; 
            % Equivalent AWC cost for charging: 
            charge_awc = AWCopt*c_rate*nc*charge_dur;         elseif charge_f == 2 
            % This schedule algorithm hasn't accounted for when the home 
            % ESS is sufficiently full, nor has household consumption been  
            % taken into account in this algorithm. 
            charge_start = (hr+1);             charge_expense = 0; 
            charge_awc = AWCopt*c_rate*nc*charge_dur;         end         end 
         
        % Equivalent battery wear cost from driving part of cycle: 
        drive_awc = AWCopt*(100-SOC)/100*bcap; 
         
        % Find averages for long term profit/loss analysis: 
        charge_dur_ave = ((100-
SOCcut)/100*bsize*SOHave/100)/(c_rate*nc);         charge_expenseave = peave0*c_rate*charge_dur_ave;         charge_awcave = AWCopt*c_rate*nc*charge_dur_ave;         drive_awcave = AWCopt*(100-SOC)/100*bsize*SOHave/100; 
  
        % Short term profit eqn (i.e. difference between revenue received 
        % and expense paid for the transferral of electricity - these are 
        % the fuel costs alone) 
        st_profit = discharge_rev-charge_expense; 
        % Long term profit eqn(these are the fuel costs as well as          % battery cost - representing total financial status from the  
        % battery purchase date to the expected replacement date): 
        lt_profit = discharge_rev-
(charge_expense+drive_awc+discharge_awc+charge_awc); 
         
        % Find average long-term profit for an accurate prediction of the 
        % final profit/loss made at the battery replacement date (this 
        % assumes the same cycling nature for every cycle throughout the 
        % battery's life):         disp(discharge_revave) 
        st_profit_ave = discharge_revave-charge_expenseave;         lt_profit_ave = discharge_revave-
(charge_expenseave+drive_awcave+discharge_awcave+charge_awcave);         pl_forecast = round(lt_profit_ave*cycle_life);     
         
        % Compute the equivalent lifetime travel costs:         % i.e. transport efficiency, by estimating total km travelled over 
        % battery lifetime based on the expected cycling nature.         Rave = ((bsize*SOHave/100)*(100-SOC)/100)/ud; 
Rt_forecast = round(Rave*cycle_life);  % expected total km driven  
                                               % over battery lifetime 
        % Equivalent cost per km based on both fuel cost/income and battery 
        % purchase cost: 
        km_cost = (pl_forecast/Rt_forecast); 
         
        % Equivalent cost/income per km based on fuel cost/income alone:         fuelcost_forecast = round(st_profit_ave*cycle_life);         fuel_km = (fuelcost_forecast/Rt_forecast); 
  
        % Display the final schedule information: 
        set(sched_s4,'Visible','on');         set(sched_s5,'Visible','on'); 
        
set(sched_s6,'Visible','on','string',sprintf('%d:00',charge_start)); 
        
set(sched_s7,'Visible','on','string',sprintf('%d:00',discharge_start
)); 
        set(sched_s8,'Visible','on');         set(sched_s9,'Visible','on');         set(sched_s10,'Visible','on');         set(sched_s11,'Visible','on');         set(sched_s12,'Visible','on','string',sprintf('%g hours',charge_dur));         set(sched_s13,'Visible','on','string',sprintf('$ 
%g',charge_expense)); 
        set(sched_s14,'Visible','on','string',sprintf('%g hours',discharge_dur));         set(sched_s15,'Visible','on','string',sprintf('$ %g', discharge_rev)); 
        set(sched_s16,'Visible','on');         set(sched_s17,'Visible','on');         set(sched_s18,'Visible','on','string',sprintf('$ 
%g',st_profit)); 
        set(sched_s19,'Visible','on','string',sprintf('$ 
%g',lt_profit)); 
         
        % Update economics table on home page:         economics_info = {'Battery Cost' bcost ' $' 'Battery AWC' 
AWCopt ' $ / kWh';  
        'Average P/L per cycle' lt_profit ' $' 'Current P/L' lt_profit*cycles_used ' $'; 
        'Best cycle P/L' lt_profit ' $' 'Worst cycle P/L' lt_profit 
' $'; 
        'Cycles Completed',cycles_used,'cycles','Cycles 
Remaining',(cycle_life-cycles_used),'cycles'; 
        'Forecasted Total P/L' pl_forecast ' $' '' '' '';         'Total fuel P/L' fuelcost_forecast ' $' 'Fuel P/L per km' fuel_km ' $/km'; 
        'Total Expected km' Rt_forecast ' km' 'Total P/L per km' km_cost ' $/km'}; 
             set(economics,'Data',economics_info); 
             end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%% SMART HOME FUNCTIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % functions for displaying the respective communication link  
    % description 
    function yes1b_callback(hObject,eventdata,handles)         set(txt1,'Visible','on');         set(txt2,'Visible','off');         set(txt3,'Visible','off');         set(txt4,'Visible','off');         set(txt5,'Visible','off');     end     function yes2b_callback(hObject,eventdata,handles)             set(txt1,'Visible','off');         set(txt2,'Visible','on');         set(txt3,'Visible','off');         set(txt4,'Visible','off');         set(txt5,'Visible','off');     end     function yes3b_callback(hObject,eventdata,handles)             set(txt1,'Visible','off');         set(txt2,'Visible','off');         set(txt3,'Visible','on');         set(txt4,'Visible','off');         set(txt5,'Visible','off');     end     function yes4b_callback(hObject,eventdata,handles)             set(txt1,'Visible','off');         set(txt2,'Visible','off');         set(txt3,'Visible','off');         set(txt4,'Visible','on');         set(txt5,'Visible','off');     end     function yes5b_callback(hObject,eventdata,~)             set(txt1,'Visible','off');         set(txt2,'Visible','off');         set(txt3,'Visible','off');         set(txt4,'Visible','off');         set(txt5,'Visible','on');     end 
  
    % function for displaying information in Home Area Connection tab 
    function connect_callback(hObject,eventdata,handles)         netshow = 1;         vis_handle() 
        set(meterb, 'Visible', 'on'); 
        set(TabHandles2{2,1}, 'Backgroundcolor', 'white');         set(TabHandles2{1,1}, 'Backgroundcolor', [0.94 0.94 0.94]);         set(cons_ax1,'Visible','off');         set(c1,'Visible','off');         set(c2,'Visible','off');         set(price_ax, 'Visible', 'off');         set(get(price_ax,'children'),'Visible','off');     end 
     
    % function for displaying information in Household Consumption tab 
    function home_callback(hObject,eventdata,handles)         netshow = 2; 
vis_handle() 
        set(TabHandles2{2,1}, 'Backgroundcolor', [0.94 0.94 0.94]);         set(TabHandles2{1,1}, 'Backgroundcolor', 'white');         set(cons_ax1,'Visible','on');         set(c1,'Visible','on');         set(c2,'Visible','on');         set(price_ax, 'Visible', 'on');         set(get(price_ax,'children'),'Visible','on');     end 
     
    % function for displaying/hiding HAN diagram     function vis_func()         if netshow == 1             set(meterb, 'Visible', 'on');             set(homeb, 'Visible', 'on');             set(batb, 'Visible', 'on');             set(renb, 'Visible', 'on');             set(chargb, 'Visible', 'on');             set(dispb, 'Visible', 'on');             set(get(arr1,'children'),'Visible', 'on');             set(get(arr2,'children'),'Visible', 'on');             set(get(arr3,'children'),'Visible', 'on');             set(get(arr4,'children'),'Visible', 'on');             set(get(arr5,'children'),'Visible', 'on');             set(yes1b, 'Visible', 'on');             set(yes2b, 'Visible', 'on');             set(yes3b, 'Visible', 'on');             set(yes4b, 'Visible', 'on');             set(yes5b, 'Visible', 'on');         else             set(meterb, 'Visible', 'off');             set(homeb, 'Visible', 'off');             set(batb, 'Visible', 'off');             set(renb, 'Visible', 'off');             set(chargb, 'Visible', 'off');             set(dispb, 'Visible', 'off'); 
            % Want to hide contents of axes (not axes themselves), so specify 
            % children ... 
            set(get(arr1,'children'),'Visible', 'off');             set(get(arr2,'children'),'Visible', 'off');             set(get(arr3,'children'),'Visible', 'off');             set(get(arr4,'children'),'Visible', 'off');             set(get(arr5,'children'),'Visible', 'off');             set(yes1b, 'Visible', 'off');             set(yes2b, 'Visible', 'off');             set(yes3b, 'Visible', 'off');             set(yes4b, 'Visible', 'off');             set(yes5b, 'Visible', 'off');             set(txt1, 'Visible', 'off');             set(txt2, 'Visible', 'off');             set(txt3, 'Visible', 'off');             set(txt4, 'Visible', 'off');             set(txt5, 'Visible', 'off');         end     end 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%% 
  
  
%% Save the TabHandles in guidata guidata(hTabFig,TabHandles); 
  
%% Make Tab 1 the active tab upon initialisation 
TabSelectCallback(0,0,1); 
end

function TabSelectCallback(~,~,SelectedTab)
% All tab selection pushbuttons are greyed out and uipanels are set to 
% visible off, then the selected panel is made visible and its selection 
% pushbutton is highlighted. 
  
% Set up variables 
TabHandles = guidata(gcf); NumTabs = size(TabHandles,1)-2; white = TabHandles{NumTabs+2,2}; grey = TabHandles{NumTabs+2,3}; 
  
% Turn off all tabs for TabCount = 1:NumTabs     set(TabHandles{TabCount,1},'Visible','off');     set(TabHandles{TabCount,2},'BackgroundColor',grey); end 
  
% Enable the selected tab 
set(TabHandles{SelectedTab,1},'Visible','on'); set(TabHandles{SelectedTab,2},'BackgroundColor',white); 
  end 
%% Models 
% Average SOH over battery lifetime: function SOHave = SOH_ave(cycle_life)     syms c 
    SOHave = (1/cycle_life)*int((-7*10^(-6)*(c)^2-
0.0003*(c)+100),c,0,cycle_life); end     function [DODopt,LETopt,CLopt] = LET_DOD(CLvals,DODvals,bsize,nc,nd) 
    LET = zeros(length(CLvals),1); 
     
    % Obtain the equivalent AWC for each ACC/DOD based on specifications: 
    for i = 1:length(CLvals) 
        LET(i) = (CLvals(i)*2*(DODvals(i)/100)*bsize*(nc*nd));     end 
    % Optimal DOD to consistently cycle to will be that which yields the 
    % lowest AWC (or yields the highest lifetime energy throughput) 
    [minv,o] = max(LET); 
    DODopt = DODvals(o);                % optimal DOD 
    LETopt = LET(o);                    % Equivalent AWC 
    CLopt = CLvals(o);                  % Equivalent cycle life 
end
end
