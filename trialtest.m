function clicktest()
    fig = figure
    hax = axes('Units','pixels');
    surf(peaks)
    uicontrol('Style', 'pushbutton', 'String', 'Clear',...
        'Position', [20 20 50 20],...
        'Callback', 'surf(randi(5,49,49)*peaks)');        
% The pushbutton string callback
% calls a MATLAB function

      ustring = uicontrol('Style','text',...
          'Position',[400 45 120 20],...
          'String','clicked objectt')
      edit1= uicontrol('Style','edit',...
          'Position',[400 95 120 20],...
          'String','clicked object')
      edit2= uicontrol('Style','edit',...
          'Position',[400 115 120 20],...
          'String','clicked object')
       set(fig,'WindowButtonDownFcn',{@position,ustring});

end

function position(hobject,event,ustring)
C = get(hobject,'CurrentPoint');
set(ustring,'String',num2str(C));
end
