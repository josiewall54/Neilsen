function ided_times = get_ided_times(varargin)

if nargin == 0
    ax = gca;
    flag = 'current';
elseif nargin == 1
    ax = varargin{1};
    flag = 'current';
else
    ax = varargin{1};
    flag = varargin{2};
end    

if strcmp(flag,'current')
    h_ided = findobj(ax,'Tag','idedpatch');  % find all the ided patches

    if ~isempty(h_ided)
        ided_times = [0 0];
        for i = 1:length(h_ided)
            xdat = get(h_ided(i),'Xdata');
            ided_times = [ided_times; xdat(1) xdat(3)];
        end
        ided_times = ided_times(2:end,:);

        [junk,sort_ind] = sort(ided_times(:,1));
        ided_times = ided_times(sort_ind,:);
    else
        ided_times = [];
    end
else
    handles = guidata(get(ax,'Parent'));
    ided_times = handles.all_ided_times;
end