ActPath = pwd;
addpath([ActPath '/Functions']);
clear ActPath

%Laden der Daten
[File,Path] = uigetfile({'*.mat','measurement files (*.mat)';'*.*',  'All Files (*.*)'}, ...
   'Select a measurement file');
if ~isnumeric(File)
    [Time,U_in,U_out,D,I_out] = V5_func_Daten_Import_DCDC(File,Path);
end

clear File Path ActPath