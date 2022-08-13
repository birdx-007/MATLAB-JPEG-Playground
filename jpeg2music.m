function music_J=jpeg2music(jpegname,musicname,fs)
    addpath(genpath('.\lib'));
    
    matrix2D_J=jpeg2mat(jpegname);
    music_J=reshape(double(matrix2D_J),1,[]);
    music_J=(music_J-mean(music_J))/255*2;
    audiowrite(musicname,music_J,fs);
    
    rmpath(genpath('.\lib'));
end