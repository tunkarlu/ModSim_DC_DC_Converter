function V5_GUI_Ankerparameter_V3(Zeit,U_Eingang,U_Ausgang,PWM,I_Ausgang,Infos)

    U_CE = 0;

    %Lastwiderstand berechnen
    R_Last = U_Ausgang./I_Ausgang;
    %NaNs entfernen
    Indizes = find(isnan(R_Last) == 1);
    
    Zeit(Indizes) = [];
    U_Eingang(Indizes) = [];
    U_Ausgang(Indizes) = [];
    PWM(Indizes) = [];
    I_Ausgang(Indizes) = [];
    R_Last(Indizes) = [];
    
    %Zeit in ms umrechnen
    Zeit = Zeit*1e3;

    %Figure erzeugen
    %---------------
    Fig = figure;
    c_Fig = 0.95;
    set(Fig,'Color',[c_Fig c_Fig c_Fig],'Units','normalized','Position',[0.3 0.1 0.45 0.8]);
    set(Fig,'Name',Infos.fileName)
    clear c_Fig

    %Achsen und Linien erzeugen
    %--------------------------
    Achsen_links = 0.15;
    Achse_unten = 0.1;
    Achsen_Hoehe = 0.24;
    Achsen_Breite = 0.75;
    Achsen_Abstand = 0.04;

    Achse_1 = axes;
    set(Achse_1,'Units','normalized',...
        'Position',[Achsen_links Achse_unten Achsen_Breite Achsen_Hoehe],...
        'Box','on','XGrid','on','YGrid','on','XLim',[min(Zeit) max(Zeit)]);
    set(get(Achse_1,'XLabel'),'String','Time [ms]');
    set(get(Achse_1,'YLabel'),'String','measured voltages U_in and U_out [V]');
    
    set(zoom(Achse_1),'ActionPostCallback',@renew_Plots_zoom);

    Linie_Ua = line(Zeit,U_Ausgang,'Parent',Achse_1,'Color','b');
    Linie_Ue = line(Zeit,U_Eingang,'Parent',Achse_1,'Color','r');
    
    Achse_2 = axes;
    set(Achse_2,'Units','normalized',...
        'Position',[Achsen_links Achse_unten+Achsen_Hoehe+Achsen_Abstand Achsen_Breite Achsen_Hoehe],...
        'Box','on','XGrid','on','YGrid','on','XLim',[min(Zeit) max(Zeit)]);
    set(get(Achse_2,'YLabel'),'String','output current I_out [A]');
    
    set(zoom(Achse_2),'ActionPostCallback',@renew_Plots_zoom);

    Linie_Ia = line(Zeit,I_Ausgang,'Parent',Achse_2,'Color',[0 0.5 0]);
    
    
    Achse_3 = axes;
    set(Achse_3,'Units','normalized',...
        'Position',[Achsen_links Achse_unten+2*Achsen_Hoehe+2*Achsen_Abstand Achsen_Breite Achsen_Hoehe],...
        'Box','on','XGrid','on','YGrid','on','XLim',[min(Zeit) max(Zeit)]);
    set(get(Achse_3,'YLabel'),'String','load resistance R_load [Ohm]');

    Linie_RLast = line(Zeit,R_Last,'Parent',Achse_3,'Color','r');
    
    linkaxes([Achse_1,Achse_2,Achse_3], 'x');
    
    %Zoom-Einstellungen
    Zoom_Handle = zoom(Fig);
    set(Zoom_Handle,'Enable','on');

    %UI-Objekt erzeugen
    %------------------
    edit_Hoehe = 0.03;
    edit_Breite = 0.08;
    push_x_Hoehe = 0.03;
    push_x_Breite = 0.14;
    push_y_Hoehe = 0.07;
    push_y_Breite = 0.08;
    
    UI_Zeit_min = uicontrol('style','edit','Units','normalized',...
        'Position',[0.1 0.04 0.1 0.03],...
        'String',num2str(min(Zeit)),'callback',@set_x_Achse);
    UI_Zeit_max = uicontrol('style','edit','Units','normalized',...
        'Position',[0.85 0.04 0.1 0.03],...
        'String',num2str(max(Zeit)),'callback',@set_x_Achse);
    UI_Zeit_Reset = uicontrol('style','pushbutton',...
        'Units','normalized','Position',[0.83 0.01 0.14 0.03],...
        'String','Reset x-axis','callback',@reset_x_Achse);
    
    akt_Achse = Achse_1;
    YLimits_Ua = get(akt_Achse,'YLim');
    Pos_unten = get(akt_Achse,'Position');
    Pos_unten = Pos_unten(2);
    UI_Ua_max = uicontrol('style','edit','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten+(Achsen_Hoehe-edit_Hoehe) edit_Breite edit_Hoehe],...
        'String',num2str(YLimits_Ua(2)),'callback',@set_y_Achse_Ua);
    UI_Ua_min = uicontrol('style','edit','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten edit_Breite edit_Hoehe],...
        'String',num2str(YLimits_Ua(1)),'callback',@set_y_Achse_Ua);
    UI_Ua_Reset = uicontrol('style','pushbutton','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten+(Achsen_Hoehe/2-push_y_Hoehe/2) push_y_Breite push_y_Hoehe],...
        'String','Reset','callback',@reset_y_Achse_Ua);
    
    akt_Achse = Achse_2;
    YLimits_Ia = get(akt_Achse,'YLim');
    Pos_unten = get(akt_Achse,'Position');
    Pos_unten = Pos_unten(2);
    UI_Ia_max = uicontrol('style','edit','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten+(Achsen_Hoehe-edit_Hoehe) edit_Breite edit_Hoehe],...
        'String',num2str(YLimits_Ia(2)),'callback',@set_y_Achse_Ia);
    UI_Ia_min = uicontrol('style','edit','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten edit_Breite edit_Hoehe],...
        'String',num2str(YLimits_Ia(1)),'callback',@set_y_Achse_Ia);
    UI_Ia_Reset = uicontrol('style','pushbutton','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten+(Achsen_Hoehe/2-push_y_Hoehe/2) push_y_Breite push_y_Hoehe],...
        'String','Reset','callback',@reset_y_Achse_Ia);
    
    akt_Achse = Achse_3;
    YLimits_RLast = get(akt_Achse,'YLim');
    Pos_unten = get(akt_Achse,'Position');
    Pos_unten = Pos_unten(2);
    UI_RLast_max = uicontrol('style','edit','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten+(Achsen_Hoehe-edit_Hoehe) edit_Breite edit_Hoehe],...
        'String',num2str(YLimits_RLast(2)),'callback',@set_y_Achse_RLast);
    UI_RLast_min = uicontrol('style','edit','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten edit_Breite edit_Hoehe],...
        'String',num2str(YLimits_RLast(1)),'callback',@set_y_Achse_RLast);
    UI_RLast_Reset = uicontrol('style','pushbutton','Units','normalized',...
        'Position',[Achsen_links+Achsen_Breite+0.01 Pos_unten+(Achsen_Hoehe/2-push_y_Hoehe/2) push_y_Breite push_y_Hoehe],...
        'String','Reset','callback',@reset_y_Achse_RLast);
    
    akt_Achse = Achse_3;
    Pos_unten = get(akt_Achse,'Position');
    Achsen_Abstand = 0.01;
    Pos_unten = Pos_unten(2)+Pos_unten(4)+Achsen_Abstand;
    UI_MW_ber = uicontrol('style','pushbutton','Units','normalized',...
        'Position',[0.1 Pos_unten 0.2 0.05],...
        'String','calculate averaged values','callback',@calc_MW);  
    
    Pos_unten = Pos_unten - Achsen_Abstand;
    UI_Ue_MW_text = uicontrol('style','text','Units','normalized',...
        'Position',[0.6 Pos_unten 0.25 (1-Pos_unten)/4*0.9],...
        'HorizontalAlignment','left','String','averaged value U_in [V]','Visible','off');
    UI_Ua_MW_text = uicontrol('style','text','Units','normalized',...
        'Position',[0.6 Pos_unten+(1-Pos_unten)*1/5 0.25 (1-Pos_unten)/4*0.9],...
        'HorizontalAlignment','left','String','averaged value U_out [V]','Visible','off','FontWeight','bold');
    UI_Ia_MW_text = uicontrol('style','text','Units','normalized',...
        'Position',[0.6 Pos_unten+(1-Pos_unten)*2/5 0.25 (1-Pos_unten)/4*0.9],...
        'HorizontalAlignment','left','String','averaged value I_out [A]','Visible','off');
    UI_RLast_MW_text = uicontrol('style','text','Units','normalized',...
        'Position',[0.6 Pos_unten+(1-Pos_unten)*3/5 0.25 (1-Pos_unten)/4*0.9],...
        'HorizontalAlignment','left','String','load resistance R_load [Ohm]','Visible','off','FontWeight','bold');
    UI_RL_MW_text = uicontrol('style','text','Units','normalized',...
        'Position',[0.6 Pos_unten+(1-Pos_unten)*4/5 0.25 (1-Pos_unten)/4*0.9],...
        'HorizontalAlignment','left','String','resistance R = R_L + R_lo,C [Ohm]','Visible','off','FontWeight','bold');
    UI_Ue_MW_wert = uicontrol('style','text','Units','normalized',...
        'Position',[0.85 Pos_unten 0.1 (1-Pos_unten)/4*0.9],...
        'String','0','FontWeight','normal','Visible','off');
    UI_Ua_MW_wert = uicontrol('style','text','Units','normalized',...
        'Position',[0.85 Pos_unten+(1-Pos_unten)*1/5 0.1 (1-Pos_unten)/4*0.9],...
        'String','0','FontWeight','bold','Visible','off');
    UI_Ia_MW_wert = uicontrol('style','text','Units','normalized',...
        'Position',[0.85 Pos_unten+(1-Pos_unten)*2/5 0.1 (1-Pos_unten)/4*0.9],...
        'String','0','FontWeight','normal','Visible','off');
    UI_RLast_MW_wert = uicontrol('style','text','Units','normalized',...
        'Position',[0.85 Pos_unten+(1-Pos_unten)*3/5 0.1 (1-Pos_unten)/4*0.9],...
        'String','0','FontWeight','bold','Visible','off');
    UI_RL_MW_wert = uicontrol('style','text','Units','normalized',...
        'Position',[0.85 Pos_unten+(1-Pos_unten)*4/5 0.1 (1-Pos_unten)/4*0.9],...
        'String','0','FontWeight','bold','Visible','off');
    
    %UI callback-Functions
    %---------------------
    function set_x_Achse(source,callbackdata)
        x_min = str2num(get(UI_Zeit_min,'String'));
        x_max = str2num(get(UI_Zeit_max,'String'));
        
        if x_min > x_max
            temp = x_min;
            x_min = x_max;
            x_max = temp;
            set(UI_Zeit_min,'String',num2str(x_min));
            set(UI_Zeit_max,'String',num2str(x_max));
        elseif x_max == x_min
            x_max = x_min+Zeit(2)-Zeit(1);
            set(UI_Zeit_min,'String',num2str(x_min));
            set(UI_Zeit_max,'String',num2str(x_max));
        end
        set(Achse_1,'XLim',[x_min x_max]);
        set(Achse_2,'XLim',[x_min x_max]);
        set(Achse_3,'XLim',[x_min x_max]);
        
        %neue Y-Limits der Plots auslesen und setzen
        YLimits_Ua_temp = get(Achse_1,'YLim');
        set(UI_Ua_min,'String',num2str(YLimits_Ua_temp(1)));
        set(UI_Ua_max,'String',num2str(YLimits_Ua_temp(2)));
        
        YLimits_Ia_temp = get(Achse_2,'YLim');
        set(UI_Ia_min,'String',num2str(YLimits_Ia_temp(1)));
        set(UI_Ia_max,'String',num2str(YLimits_Ia_temp(2)));
        
        YLimits_RLast_temp = get(Achse_3,'YLim');
        set(UI_Ia_min,'String',num2str(YLimits_RLast_temp(1)));
        set(UI_Ia_max,'String',num2str(YLimits_RLast_temp(2)));
        
    end

    function reset_x_Achse(source,callbackdata)
        x_min = Zeit(1);
        x_max = Zeit(end);
        
        set(UI_Zeit_min,'String',num2str(x_min));
        set(UI_Zeit_max,'String',num2str(x_max));
        
        set(Achse_1,'XLim',[x_min x_max]);
        set(Achse_2,'XLim',[x_min x_max]);
        set(Achse_3,'XLim',[x_min x_max]);
    end

    function set_y_Achse_Ua(source,callbackdata)
        y_min = str2num(get(UI_Ua_min,'String'));
        y_max = str2num(get(UI_Ua_max,'String'));
        
        if y_min > y_max
            temp = y_min;
            y_min = y_max;
            y_max = temp;
            set(UI_Ua_min,'String',num2str(y_min));
            set(UI_Ua_max,'String',num2str(y_max));
        elseif y_max == y_min
            y_max = y_min+0.1;
            set(UI_Ua_min,'String',num2str(y_min));
            set(UI_Ua_max,'String',num2str(y_max));
        end
        set(Achse_1,'YLim',[y_min y_max]);
    end

    function reset_y_Achse_Ua(source,callbackdata)
        %y-Achse
        y_min = YLimits_Ua(1);
        y_max = YLimits_Ua(2);
        
        set(UI_Ua_min,'String',num2str(y_min));
        set(UI_Ua_max,'String',num2str(y_max));
        
        set(Achse_1,'YLim',[y_min y_max]);
        
        %x-Achse
        x_min = Zeit(1);
        x_max = Zeit(end);
        
        set(UI_Zeit_min,'String',num2str(x_min));
        set(UI_Zeit_max,'String',num2str(x_max));
        
        set(Achse_1,'XLim',[x_min x_max]);
        set(Achse_2,'XLim',[x_min x_max]);
        set(Achse_3,'XLim',[x_min x_max]);
    end

    function set_y_Achse_Ia(source,callbackdata)
        y_min = str2num(get(UI_Ia_min,'String'));
        y_max = str2num(get(UI_Ia_max,'String'));
        
        if y_min > y_max
            temp = y_min;
            y_min = y_max;
            y_max = temp;
            set(UI_Ia_min,'String',num2str(y_min));
            set(UI_Ia_max,'String',num2str(y_max));
        elseif y_max == y_min
            y_max = y_min+0.1;
            set(UI_Ia_min,'String',num2str(y_min));
            set(UI_Ia_max,'String',num2str(y_max));
        end
        set(Achse_2,'YLim',[y_min y_max]);
    end

    function reset_y_Achse_Ia(source,callbackdata)
        %y-Achse
        y_min = YLimits_Ia(1);
        y_max = YLimits_Ia(2);
        
        set(UI_Ia_min,'String',num2str(y_min));
        set(UI_Ia_max,'String',num2str(y_max));
        
        set(Achse_2,'YLim',[y_min y_max]);
        
        %x-Achse
        x_min = Zeit(1);
        x_max = Zeit(end);
        
        set(UI_Zeit_min,'String',num2str(x_min));
        set(UI_Zeit_max,'String',num2str(x_max));
        
        set(Achse_1,'XLim',[x_min x_max]);
        set(Achse_2,'XLim',[x_min x_max]);
        set(Achse_3,'XLim',[x_min x_max]);
    end

    function set_y_Achse_RLast(source,callbackdata)
        y_min = str2num(get(UI_RLast_min,'String'));
        y_max = str2num(get(UI_RLast_max,'String'));
        
        if y_min > y_max
            temp = y_min;
            y_min = y_max;
            y_max = temp;
            set(UI_RLast_min,'String',num2str(y_min));
            set(UI_RLast_max,'String',num2str(y_max));
        elseif y_max == y_min
            y_max = y_min+0.1;
            set(UI_RLast_min,'String',num2str(y_min));
            set(UI_RLast_max,'String',num2str(y_max));
        end
        set(Achse_3,'YLim',[y_min y_max]);
    end

    function reset_y_Achse_RLast(source,callbackdata)
        %y-Achse
        y_min = YLimits_RLast(1);
        y_max = YLimits_RLast(2);
        
        set(UI_RLast_min,'String',num2str(y_min));
        set(UI_RLast_max,'String',num2str(y_max));
        
        set(Achse_3,'YLim',[y_min y_max]);
        
        %x-Achse
        x_min = Zeit(1);
        x_max = Zeit(end);
        
        set(UI_Zeit_min,'String',num2str(x_min));
        set(UI_Zeit_max,'String',num2str(x_max));
        
        set(Achse_1,'XLim',[x_min x_max]);
        set(Achse_2,'XLim',[x_min x_max]);
        set(Achse_3,'XLim',[x_min x_max]);
    end

    function calc_MW(source,callbackdata)
        Zeitbereich = get(Achse_1,'XLim');
        Zeit_min_MW = Zeitbereich(1);
        Zeit_max_MW = Zeitbereich(2);
        
        Index_min_MW = find(Zeit>=Zeit_min_MW,1);
        if isempty(Index_min_MW)
            Index_min_MW = 1;
        end
        
        Index_max_MW = find(Zeit>=Zeit_max_MW,1);
        if isempty(Index_max_MW)
            Index_max_MW = length(Zeit);
        end
        
        MW_Ue = mean(U_Eingang(Index_min_MW:Index_max_MW));
        MW_Ua = mean(U_Ausgang(Index_min_MW:Index_max_MW));
        MW_Ia = mean(I_Ausgang(Index_min_MW:Index_max_MW));
        %Berechnung Lastwiderstand
        MW_RLast = mean(R_Last(Index_min_MW:Index_max_MW));
        R_Last_MW = MW_Ua/MW_Ia;
        if isinf(MW_RLast)
            MW_RLast = R_Last_MW;
        end
        %Berechnung Widerstand der Spule
        R_L = (MW_Ue-U_CE-MW_Ua)/MW_Ia;
        
        clear Zeitbereich Zeit_min_MW Zeit_max_MW Index_min_MW Index_max_MW
        
        set(UI_Ue_MW_text,'Visible','on')
        set(UI_Ua_MW_text,'Visible','on')
        set(UI_Ia_MW_text,'Visible','on')
        set(UI_RLast_MW_text,'Visible','on')
        set(UI_RL_MW_text,'Visible','on')
        set(UI_Ue_MW_wert,'String',num2str(MW_Ue,'%6.3f'),'Visible','on')
        set(UI_Ua_MW_wert,'String',num2str(MW_Ua,'%6.3f'),'Visible','on')
        set(UI_Ia_MW_wert,'String',num2str(MW_Ia,'%6.3f'),'Visible','on')
        set(UI_RLast_MW_wert,'String',num2str(MW_RLast,'%6.3f'),'Visible','on')
        set(UI_RL_MW_wert,'String',num2str(R_L,'%6.3f'),'Visible','on')
    end

  

    function renew_Plots_zoom(source,callbackdata)
        %x-Werte in UIs übernehmen
        X_Limits_zoom = get(Achse_1,'XLim');
        set(UI_Zeit_min,'String',num2str(X_Limits_zoom(1),'%6.3f'));
        set(UI_Zeit_max,'String',num2str(X_Limits_zoom(2),'%6.3f'));
        clear X_Limits_zoom
        
        %y-Werte in UIs Achse_1 übernehmen
        Y_Limits_zoom = get(Achse_1,'YLim');
        set(UI_Ua_min,'String',num2str(Y_Limits_zoom(1),'%6.3f'));
        set(UI_Ua_max,'String',num2str(Y_Limits_zoom(2),'%6.3f'));
        clear Y_Limits_zoom
        
        %y-Werte in UIs Achse_2 übernehmen
        Y_Limits_zoom = get(Achse_2,'YLim');
        set(UI_Ia_min,'String',num2str(Y_Limits_zoom(1),'%6.3f'));
        set(UI_Ia_max,'String',num2str(Y_Limits_zoom(2),'%6.3f'));
        clear Y_Limits_zoom
        
        %y-Werte in UIs Achse_2 übernehmen
        Y_Limits_zoom = get(Achse_3,'YLim');
        set(UI_RLast_min,'String',num2str(Y_Limits_zoom(1),'%6.3f'));
        set(UI_RLast_max,'String',num2str(Y_Limits_zoom(2),'%6.3f'));
        clear Y_Limits_zoom
    end

    uiwait(Fig)
        
end