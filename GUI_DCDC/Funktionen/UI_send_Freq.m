function UI_send_Freq(src,evt,board,UI)
    % Auslesen des PullDown Men�s
    Wert = src.Value;
    Wert = cast(Wert+1,'uint8'); % 1 = 2 kHz; 2 = 5 kHz; 3 = 10 kHz; 4 = 20 kHz (hier + 1 um 2 kHz wegzulassen)
    
    % Senden (wenn COM-Port offen)   
    if strcmp(board.Status,'open')
        tx = [1,Wert]; % ID f�r Frequenz ist 1;
        coded_msg = cobs_TS(tx);
        %disp(['codierte Message: ' num2str(coded_msg)])
        fwrite(board,coded_msg,'uint8');
    else
        disp('Senden nicht m�glich. COM-Verbindung nicht ge�ffnet');
    end
    clear Wert
end