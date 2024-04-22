ActPath = pwd;
%Pfad für Funktionen
addpath([ActPath '/Functions'])

%Auswertung der Ankerparameter
cd('../Data')
[File,Path] = uigetfile({'*.mat'},'Select measurement data files to evaluate the load resistance','MultiSelect','on');
cd(ActPath)
if ~isnumeric(File)
    if iscell(File)
        for i = 1:length(File)
            Infos.fileName = File{i};
            [Time,U_in,U_out,D,I_out] = V5_func_Daten_Import_DCDC(File{i},Path);
            V5_GUI_Lastwiderstand(Time,U_in,U_out,D,I_out,Infos)
        end
    else
        Infos.fileName = File;
        [Time,U_in,U_out,D,I_out] = V5_func_Daten_Import_DCDC(File,Path);
        V5_GUI_Lastwiderstand(Time,U_in,U_out,D,I_out,Infos)
    end
end

clear ActPath File Path Time U_in U_out D I_out i Infos