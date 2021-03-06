function write_session_summary(session_summary,fname)
    %takes in a session summary as generated by the make_session_summary
    %script, and writes it to an ascii file
    
    
    %open file:
    fid=fopen(fname,'wt');
    fprintf(fid,'%s \n\r','automatic session summary for bdf.');
    fprintf(fid,'%s \n\r','Original summary data generated by make_session_summary.m');
    fprintf(fid,'%s \n\r','The original session_summary may contain some data notwritten to this file such as structs');
    fprintf(fid,'%s \n\n\r',['This text file written on ',date,' by write_session_summary.m']);
    category=fieldnames(session_summary);
    for i=1:numel(category)
        %get a list of all the elements in the category
        element=fieldnames(session_summary.(category{i}));
        for m=1:numel(element)
            [lines,columns]=size(session_summary.(category{i}).(element{m}));
            for j=1:lines
                %write a line
                fprintf(fid,'%s %s\t',category{i}, element{m});
                for k=1:columns
                    % if the variabel is write a column
                    if ischar(session_summary.(category{i}).(element{m}){j,k})
                        fprintf(fid,'%s\t',session_summary.(category{i}).(element{m}){j,k});
                    elseif isnumeric(session_summary.(category{i}).(element{m}){j,k})
                        fprintf(fid,'%s\t',num2str(session_summary.(category{i}).(element{m}){j,k}));
                    end
                end
                fprintf(fid,'\n\r');
            end
        end
    end
    
    
    fclose(fid);
end