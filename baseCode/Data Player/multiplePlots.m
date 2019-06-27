function varargout = multiplePlots(vid, emg) %reads data from file 
    subplot(2,1,1);
    image(vid); 
    subplot(2,1,2);
    plot(emg);
    
    
end