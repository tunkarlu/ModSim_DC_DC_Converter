ActPath = pwd;
addpath([ActPath '/Functions']);
clear ActPath

%Laden der Daten
[File,Path] = uigetfile({'*.mat','measurement files (*.mat)';'*.*',  'All Files (*.*)'}, ...
   'Select a measurement file');
if ~isnumeric(File)
    [Time,U_in,U_out,D,I_out] = V5_func_Daten_Import_DCDC(File,Path);

    %remove range overlows (results in inf-values)
    remove_inf = 1;
    if (remove_inf == 1)
        %% U_in
        Indizes = find(isinf(U_in));
        if (~isempty(Indizes))
            Temp = U_in;
            Temp(Indizes) = [];
            Temp = max(Temp);
            U_in(Indizes) = Temp;
            clear Temp
            disp('data corrections for U_in done')
        end
        %% U_out
        Indizes = find(isinf(U_out));
        if (~isempty(Indizes))
            Temp = U_out;
            Temp(Indizes) = [];
            Temp = max(Temp);
            U_out(Indizes) = Temp;
            clear Temp
            disp('data corrections for U_out done')
        end
        %% D
        Indizes = find(isinf(D));
        if (~isempty(Indizes))
            Temp = D;
            Temp(Indizes) = [];
            Temp = max(Temp);
            D(Indizes) = Temp;
            clear Temp
            disp('data corrections for D done')
        end
        %% I_out
        Indizes = find(isinf(I_out));
        if (~isempty(Indizes))
            Temp = I_out;
            Temp(Indizes) = [];
            Temp = max(Temp);
            I_out(Indizes) = Temp;
            clear Temp
            disp('data corrections for I_out done')
        end
    end
end

clear File Path ActPath