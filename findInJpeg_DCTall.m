function extract=findInJpeg_DCTall(jpegname)
    addpath(genpath('.\lib'));
    
    [dResult,~]=jpegFileDecode(jpegname);
    extract=logical(bitget(int16(dResult),1));
    extract=reshape(extract,1,numel(dResult));
    extract(end-mod(length(extract),7)+1:end)=[];
    extract=reshape(extract,7,[])';
    extract=bin2dec(char(extract+'0'))';
    extract(find(extract==0,1):end)=[];
    extract=char(extract);
    
    rmpath(genpath('.\lib'));
end