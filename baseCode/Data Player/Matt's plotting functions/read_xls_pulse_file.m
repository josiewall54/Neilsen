function xls_info = read_xls_pulse_file(xlsfile,sheetn)

% xlsfile = 'flat_060,090,120_analysis.xls';
% sheetn = 1;

[num,txt,raw] = xlsread(xlsfile,sheetn);

xls_info.datfile = raw{1,2};
xls_info.pulsenumber = raw{2,2};
xls_info.notes{1} = raw{3,2};
xls_info.notes{2} = raw{4,2};
xls_info.notes{3} = raw{5,2};

for ii = 1:3
    if isnan(xls_info.notes{ii})
        xls_info.notes{ii} = '';
    end
end

[nrow,nchan] = size(raw);
nchan = nchan/2;
ntimes = nrow - 6;
for jj = 1:nchan
    xls_info.ided_times{jj} = [];
    for kk = 1:ntimes
        if ~isnan(raw{6+kk,(jj-1)*2+1})
            xls_info.ided_times{jj}(kk,1) = raw{6+kk,(jj-1)*2+1};
            xls_info.ided_times{jj}(kk,2) = raw{6+kk,(jj-1)*2+2};
        end
    end
end


