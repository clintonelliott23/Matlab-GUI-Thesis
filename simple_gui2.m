function simple_gui2
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.
%This function docks the figures...

clear all
close all
clc

numtabs = 3;
tablabels = {'Inputs','outputs','finance'};
%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[360,500,450,285]);

% Assign the a name to appear in the window title.
f.Name = 'Simple GUI';

% Move the window to the center of the screen.
movegui(f,'center')

% Make the window visible.
f.Visible = 'on';

% Construct the components.
hsurf    = uicontrol('Style','pushbutton',...
             'String','Surf','Position',[350,240,70,50],...
             'Callback',@surfbutton_Callback);
hmesh    = uicontrol('Style','pushbutton',...
             'String','Mesh','Position',[315,190,70,50],...
             'Callback',@meshbutton_Callback);
hcontour = uicontrol('Style','pushbutton',...
             'String','Contour','Position',[315,130,70,50],...
             'Callback',@contourbutton_Callback);
htext  = uicontrol('Style','text','String','Select',...
           'Position',[325,110,60,15]);
hpopup = uicontrol('Style','popupmenu',...
           'String',{'Peaks','Membrane','Sinc'},...
           'Position',[300,40,100,25],...
           'Callback',@popup_menu_Callback);
ha = axes('Units','pixels','Position',[50,70,200,185]);
align([hsurf,hmesh,hcontour,htext,hpopup],'Top','None');





end