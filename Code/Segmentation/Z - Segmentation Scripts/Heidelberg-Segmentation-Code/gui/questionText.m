function answer = questionText(text)
% NOTIFIERTEXT A little GUI window
% Displays a text with OK and Chancel buttons. That's all.
%
% First final Version: Some time in 2010
% Revised comments: November 2015

if ispc()
    FONTSIZE = 10;
else
    FONTSIZE = 12;
end

if nargin < 1
    questiontext = 'That does not work.';
end

answer = 0;

%--------------------------------------------------------------------------
% GUI Components
%--------------------------------------------------------------------------

f = figure('Visible','off','Position',[360,500,310,130],...
    'CloseRequestFcn', {@figure_CloseRequestFcn},...
    'WindowStyle', 'Modal',...
    'Color', 'white');
movegui(f,'center');

htext = uicontrol('Style','text',...
    'String', 'notext',...
    'BackgroundColor', 'white',...
    'FontSize', FONTSIZE,...
    'HorizontalAlignment', 'center',...
    'Position',[10,60,290,60]);

temp = cell(1,1);
temp{1} = text;
[outstring, newpos] = textwrap(htext,temp);
set(htext,...
   'String', outstring,...
   'HorizontalAlignment', 'center'...
   ...'Position', newpos...
   );

hOK = uicontrol('Style','pushbutton','String','OK',...
    'Position',[160,10,90,40],...
    'Callback',{@hOK_Callback});
hChancel = uicontrol('Style','pushbutton','String','Cancel',...
    'Position',[60,10,90,40],...
    'Callback',{@hChancel_Callback});

%--------------------------------------------------------------------------
% GUI Init
%--------------------------------------------------------------------------

set([f, htext, hOK, hChancel],'Units','normalized');
set(f,'Name','Notifier')

movegui(f,'center')
set(f,'Visible','on');

uiwait(f);

%--------------------------------------------------------------------------
% GUI Component Handlers
%--------------------------------------------------------------------------

    function hOK_Callback(hObject, eventdata)
        answer = 1;
        uiresume(f);
        delete(f);
    end

    function hChancel_Callback(hObject, eventdata)
        answer = 0;
        uiresume(f);
        delete(f);
    end

    function figure_CloseRequestFcn(hObject, eventdata, handles)
        answer = 0;
        uiresume(hObject);
        delete(hObject);
    end

end
