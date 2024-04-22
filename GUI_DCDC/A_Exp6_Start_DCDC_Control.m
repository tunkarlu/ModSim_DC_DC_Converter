function A_Start_Ansteuerung_DCDC_Wandler

    fclose('all'); % close all open files
    close all; % close all figures
    clear all; % clear all workspace variables
    clc; % clear the command line
    delete(instrfindall); % Reset Com Port
    delete(timerfindall); % Delete Timers
    
    ActPath = pwd;
    addpath([ActPath '/Funktionen']);
    clear ActPath
       
    % Konstanten
    BAUDERATE = 115200;
    INPUTBUFFER = 4096;
    TMR_PERIOD_DATA = 0.005;
    COM_PORT = 'COM3';
    
    % Variablen
    COM_available = 0;

    % Erzeugen der Figure mit Plots und UIControls
    %% Figure
    %  ------
    clf
    Figure.Ausgabe = figure(1);
    set(Figure.Ausgabe,'Name','Control DC-DC Converter','Units','normalized','Position',[0.75 0.6 0.2 0.3],'MenuBar','none','ToolBar','none','Visible','off');

    %% UIControls
    %  ----------
                     
    % Serielle Datenübertragung aktivieren/deaktivieren
    UI.Seriell_EinAus = uicontrol('Parent',Figure.Ausgabe,'Style','toggle','Units','normalized','Position',[0.05 0.75 0.9 0.2],'String','open serial data connection');
    UI.Seriell_EinAus.Enable = 'off';
    UI.Seriell_EinAus.FontSize = 16;
    
    
    %Rahmen für Frequenz UIs
    UI.Frame_Freq = uicontrol(Figure.Ausgabe,'Style','edit','enable','off','units','normalized','Position',[0.03 0.47 0.94 0.25],...
                      'HandleVisibility','off','FontSize',16,'FontWeight','bold');
    
    % Text Frequenz
    UI.Freq_Text = uicontrol(Figure.Ausgabe,'Style','text','String','Frequency','units','normalized','Position',[0.05 0.55 0.3 0.1],...
                      'HandleVisibility','off','FontSize',14,'FontWeight','bold');
    
    % Edit Frequenz             
    UI.Freq_PD = uicontrol('Parent',Figure.Ausgabe,'Style','popupmenu','Units','normalized','Position',[0.4 0.55 0.35 0.1]);
    %UI.Freq_PD.String = {'2','5','10','20'};
    UI.Freq_PD.String = {'5','10','20'};
    UI.Freq_PD.Value = 2;
    UI.Freq_PD.FontSize = 16;
    UI.Freq_PD.FontWeight = 'bold';
    UI.Freq_PD.HorizontalAlignment = 'center';
    UI.Freq_PD.Enable = 'off';
    
    % Einheit Frequenz
    UI.Freq_Einheit = uicontrol(Figure.Ausgabe,'Style','text','String','kHz','units','normalized','Position',[0.8 0.55 0.15 0.1],...
                      'HandleVisibility','off','FontSize',16,'FontWeight','bold');
                  
    %Rahmen Tastverhältnis UIs
    UI.Frame_TV = uicontrol(Figure.Ausgabe,'Style','edit','enable','off','units','normalized','Position',[0.03 0.05 0.94 0.4],...
                      'HandleVisibility','off','FontSize',12,'FontWeight','bold');
    
    % Text Tastverhältnis
    UI.TV_Text = uicontrol(Figure.Ausgabe,'Style','text','String','PWM DC','units','normalized','Position',[0.05 0.25 0.25 0.1],...
                      'HandleVisibility','off','FontSize',14,'FontWeight','bold');
    
    % Edit Tastverhältnis             
    UI.TV_Edit = uicontrol('Parent',Figure.Ausgabe,'Style','Edit','Units','normalized','Position',[0.3 0.25 0.55 0.1]);
    UI.TV_Edit.String = '50';
    UI.TV_Edit.FontSize = 16;
    UI.TV_Edit.FontWeight = 'bold';
    UI.TV_Edit.HorizontalAlignment = 'center';
    UI.TV_Edit.Enable = 'off';
    
    % Einheit Tastverhältnis
    UI.TV_Einheit = uicontrol(Figure.Ausgabe,'Style','text','String','%','units','normalized','Position',[0.85 0.25 0.1 0.1],...
                      'HandleVisibility','off','FontSize',16,'FontWeight','bold');            
    
    % Pushbuttons Tastverhältnis
    FontSize_PB = 9;
    UI.TV_PushButton_0 = uicontrol(Figure.Ausgabe,'Style','pushbutton','String','0%','units','normalized','Position',[0.3 0.12 0.11 0.13],...
                      'HandleVisibility','off','FontSize',FontSize_PB,'FontWeight','normal');
    UI.TV_PushButton_0.Enable = 'off';
    
    UI.TV_PushButton_25 = uicontrol(Figure.Ausgabe,'Style','pushbutton','String','25%','units','normalized','Position',[0.41 0.12 0.11 0.13],...
                      'HandleVisibility','off','FontSize',FontSize_PB,'FontWeight','normal');
    UI.TV_PushButton_25.Enable = 'off';
    
    UI.TV_PushButton_50 = uicontrol(Figure.Ausgabe,'Style','pushbutton','String','50%','units','normalized','Position',[0.52 0.12 0.11 0.13],...
                      'HandleVisibility','off','FontSize',FontSize_PB,'FontWeight','normal');
    UI.TV_PushButton_50.Enable = 'off';
    
    UI.TV_PushButton_75 = uicontrol(Figure.Ausgabe,'Style','pushbutton','String','75%','units','normalized','Position',[0.63 0.12 0.11 0.13],...
                      'HandleVisibility','off','FontSize',FontSize_PB,'FontWeight','normal');
    UI.TV_PushButton_75.Enable = 'off';
    
    UI.TV_PushButton_100 = uicontrol(Figure.Ausgabe,'Style','pushbutton','String','100%','units','normalized','Position',[0.74 0.12 0.11 0.13],...
                      'HandleVisibility','off','FontSize',FontSize_PB,'FontWeight','normal');
    UI.TV_PushButton_100.Enable = 'off';
    
    %% Erzeugen des seriellen Objekts
    board = serial(COM_PORT, 'BaudRate', BAUDERATE, 'DataBits',8);
    % Setzen der Buffer-Größe des seriellen Objekts
    set(board,'InputBufferSize', INPUTBUFFER);
    
    %Prüfen ob COM-Ports verfügbar (abhängig von Matlab-Version, ab 2019 anders)
    Matlab_Version = version('-release');
    Matlab_Version = str2num(Matlab_Version(1:end-1));
    if Matlab_Version < 2019
        COM_Ports_verf = instrhwinfo('serial');
        COM_Ports_verf = COM_Ports_verf.AvailableSerialPorts;
    else
        COM_Ports_verf = serialportlist("available");
    end
    
    %COM-Port öffnen
    if (~isempty(COM_Ports_verf))
        if (max(strcmp(COM_Ports_verf,COM_PORT)) == 0)
            errordlg(['COM-Port ' COM_PORT ' nicht verfügbar'],'COM-Port Error');          
        else
            UI.Seriell_EinAus.Enable = 'on';
            %% Timer-Setup
            % Der Timer t_data hat eine callback-Funktion (getData), die die seriellen Daten liest 
            t_data = timer('Period', TMR_PERIOD_DATA);
            set(t_data,'ExecutionMode','fixedRate');
            set(t_data,'TimerFcn', @(x,y)getData(board));
            COM_available = 1;
            Figure.Ausgabe.Visible = 'on';
        end
    else
        errordlg('Kein COM-Port verfügbar','COM-Port Error');
    end
    
    %% Definition der Callbacks für UIControls
    if COM_available == 1
        UI.Seriell_EinAus.Callback = {@UI_Seriell_EinAus,board,UI,t_data,COM_available};
    end
    UI.Freq_PD.Callback = {@UI_send_Freq,board,UI};
    UI.TV_Edit.Callback = {@UI_send_TV,board,UI};
    UI.TV_PushButton_0.Callback = {@UI_TV_PushButton_0,board,UI};
    UI.TV_PushButton_25.Callback = {@UI_TV_PushButton_25,board,UI};
    UI.TV_PushButton_50.Callback = {@UI_TV_PushButton_50,board,UI};
    UI.TV_PushButton_75.Callback = {@UI_TV_PushButton_75,board,UI};
    UI.TV_PushButton_100.Callback = {@UI_TV_PushButton_100,board,UI};
end
