function analogdata = align_plexon_analog(analogdata,syncinfo)
%  function plexondata = align_plexon_emgs(plexondata,syncinfo)
%     Uses information in syncinfo to change the time definitions for the
%     emgdata.
%

analogdata.timeframe = analogdata.timeframe - syncinfo.OnsetTime;
