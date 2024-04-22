function UI_send_Freq(src,evt,board,UI)
    % Auslesen des PullDown Menüs
    Wert = src.Value;
    Wert = cast(Wert+1,'uint8'); % 1 = 2 kHz; 2 = 5 kHz; 3 = 10 kHz; 4 = 20 kHz (hier + 1 um 2 kHz wegzulassen)
    
    % Senden (wenn COM-Port offen)   
    if strcmp(board.Status,'open')
        tx = [1,Wert]; % ID für Frequenz ist 1;
        coded_msg = cobs_TS(tx);
        %disp(['codierte Message: ' num2str(coded_msg)])
        fwrite(board,coded_msg,'uint8');
    else
        disp('Senden nicht möglich. COM-Verbindung nicht geöffnet');
    end
    clear Wert
end