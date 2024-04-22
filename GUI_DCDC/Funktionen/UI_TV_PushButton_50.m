function UI_TV_PushButton_0(src,evt,board,UI)

    if src.Value == 1
        Wert = 50;
        UI.TV_Edit.String = num2str(Wert);
    end
           
    % Senden (wenn COM-Port offen)   
    if strcmp(board.Status,'open')
        Wert = cast(Wert*2.55,'uint8');
        tx = [2,Wert]; % ID f�r Tastverh�ltnis ist 2;
        coded_msg = cobs_TS(tx);
        %disp(['codierte Message: ' num2str(coded_msg)])
        fwrite(board,coded_msg,'uint8');
    else
        disp('Senden nicht m�glich. COM-Verbindung nicht ge�ffnet');
    end
end