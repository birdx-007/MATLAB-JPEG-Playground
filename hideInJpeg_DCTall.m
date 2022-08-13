function hideInJpeg_DCTall(secret,injpegname,outjpegname)
    addpath(genpath('.\lib'));
    
    secret=double(char(secret));
    secret=reshape(dec2bin(secret,7)',1,[])-'0'; % ascii 0-127
    [dResult,info]=jpegFileDecode(injpegname);
    if numel(secret)>numel(dResult)
        error('Error. \nSecret(%d) is too long to hide in image(%d).',numel(secret),numel(dResult));
    end
    secret=cat(2,logical(secret),false(1,numel(dResult)-numel(secret)));
    sz=size(dResult);
    dResult=reshape(dResult,numel(dResult),1);
    dResult=double(bitset(int16(dResult),1,secret'));
    dResult=reshape(dResult,sz);
    jpegFileEncode(outjpegname,dResult,info)
    
    rmpath(genpath('.\lib'));
end