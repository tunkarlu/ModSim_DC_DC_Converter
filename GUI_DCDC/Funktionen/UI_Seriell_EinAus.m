function UI_Seriell_EinAus(src,evt,board,UI,timer_data,COM_available)

    %UIs aktivieren
    if (src.Value == 1)
        UI.Freq_PD.Enable = 'on';
        UI.TV_Edit.Enable = 'on';
        UI.TV_PushButton_0.Enable = 'on';
        UI.TV_PushButton_25.Enable = 'on';
        UI.TV_PushButton_50.Enable = 'on';
        UI.TV_PushButton_75.Enable = 'on';
        UI.TV_PushButton_100.Enable = 'on';
    elseif (src.Value == 0)
        UI.Freq_PD.Enable = 'off';
        UI.TV_Edit.Enable = 'off';
        UI.TV_PushButton_0.Enable = 'off';
        UI.TV_PushButton_25.Enable = 'off';
        UI.TV_PushButton_50.Enable = 'off';
        UI.TV_PushButton_75.Enable = 'off';
        UI.TV_PushButton_100.Enable = 'off';
    end
    
    % Senden des Wertes zur seriellen Kommunikation (wenn COM-Port offen)
    if (COM_available == 1)
        if (src.Value == 1)
            % Seriellen-Port öffnen
            fopen(board);
            pause(0.5);
            %Senden des Wertes zur seriellen Kommunikation(wenn COM-Port offen)
            if strcmp(board.Status,'open')
                tx = [3,1]; % ID für serielle Daten ist 3;
                coded_msg = cobs_TS(tx);
                fwrite(board,coded_msg,'uint8');
            end
            %im Puffer befindlichen Daten verwerfen dieser
            flushinput(board);
            %Command-Window aufräumen
            clc
            %Timer starten
            start(timer_data);
            %UIProperties ändern
            src.BackgroundColor = [0.6 1 0.6];
            src.String = 'close serial data connection';
        elseif (src.Value == 0)
            %Timer stoppen
            stop(timer_data);
            %noch im Puffer befindlichen Daten verwerfen
            flushinput(board);
            %Senden des Wertes zur seriellen Kommunikation(wenn COM-Port offen)
            if strcmp(board.Status,'open')
                tx = [3,0]; % ID für serielle Daten ist 3;
                coded_msg = cobs_TS(tx);
                fwrite(board,coded_msg,'uint8');
            end
            % Seriellen-Portschliessen
            fclose(board);
            %UIProperties ändern
            src.BackgroundColor = [0.94 0.94 0.94];
            src.String = 'open serial data connection';
        end
    else
        disp('Senden nicht möglich. COM-Verbindung nicht geöffnet');
    end
    
    
end