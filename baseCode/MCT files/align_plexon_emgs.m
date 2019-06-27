function emgdata = align_plexon_emgs(emgdata,syncinfo)
%  function plexondata = align_plexon_emgs(plexondata,syncinfo)
%     Uses information in syncinfo to change the time definitions for the
%     emgdata.
%

emgdata.timeframe = emgdata.timeframe - syncinfo.OnsetTime;
