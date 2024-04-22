function [Zeit,U_Eingang,U_Ausgang,PWM,I_Ausgang] = V5_func_Daten_Import_DCDC(File,Path)

    [pathstr,name,ext] = fileparts(fullfile(Path,File));
    clear pathstr name
        switch ext
            case '.mat'
                load(fullfile(Path,File))
                disp(['geladener Datensatz: ' File]);
                Zeit = ([0:Length-1]*Tinterval)';
                tstop = Zeit(end);
                U_Eingang = A;
                U_Ausgang = B;
                PWM = C;
                %Berechnung des Stroms aus Shunt-Spannung
                Gain_Shunt = 200;  %INA260A4 --> Verstärkung 200V/V
                R_Shunt = 5e-3;    %5 mOhm
                I_Ausgang = D/(Gain_Shunt*R_Shunt);
                clear Tinterval Tstart Length A B C D
        end
end

