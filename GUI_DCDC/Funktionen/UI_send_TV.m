function UI_send_TV(src,evt,board,UI)
    % Auslesen des Eingabewertes im Edit-Fenster (inkl. Plausibilitätsprüfung)
    String = src.String;
    String = strrep(String,',','.');
    Wert = str2double(String);
    if isnan(Wert)
        String = '100'; % Ersatzwert setzen 100%
        src.String = '100';
        Wert = 100;
    else
        if Wert > 100 
            String = '100';
            src.String = '100';
            Wert = 100;
        elseif Wert < 0
            String = '0';
            src.String = '0';
            Wert = 0;
        else
            src.String = num2str(Wert);
        end
    end
    

    % Senden (wenn COM-Port offen)   
    if strcmp(board.Status,'open')
        Wert = cast(Wert*2.55,'uint8');
        tx = [2,Wert]; % ID für Tastverhältnis ist 2;
        coded_msg = cobs_TS(tx);
        %disp(['codierte Message: ' num2str(coded_msg)])
        fwrite(board,coded_msg,'uint8');
    else
        disp('Senden nicht möglich. COM-Verbindung nicht geöffnet');
    end
end