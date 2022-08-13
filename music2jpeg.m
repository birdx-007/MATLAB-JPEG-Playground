function [matrix2D,fs]=music2jpeg(musicname,jpegname)
    addpath(genpath('.\lib'));
    
    [music,fs]=audioread(musicname);
    music=(music-min(music))*255/(max(music)-min(music));
    music=uint8(round(music));
    music=cat(1,music,round(mean(music))*ones(ceil(sqrt(length(music)))^2-length(music),1));
    matrix2D=reshape(music,sqrt(length(music)),[]);
    mat2jpeg(matrix2D,jpegname);
    
    rmpath(genpath('.\lib'));
end