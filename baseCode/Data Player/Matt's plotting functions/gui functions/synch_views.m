function synch_views(fig1,fig2)

figure(fig1)
[master_ind,master_t] = get_view;
figure(fig2)
set_view(master_t,gca,'times')

end

