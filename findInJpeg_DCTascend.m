function extract=findInJpeg_DCTascend(jpegname)
    addpath(genpath('.\lib'));
    
    [dResult,info]=jpegFileDecode(jpegname);
    [~,Qsortidx]=sort(zigzag8(info.QTable),'ascend');
    extract=logical(bitget(int16(dResult(Qsortidx,:)),1))';
    extract=reshape(extract,1,numel(dResult));
    extract(end-mod(length(extract),7)+1:end)=[];
    extract=reshape(extract,7,[])';
    extract=bin2dec(char(extract+'0'))';
    extract(find(extract==0,1):end)=[];
    extract=char(extract);
    
    rmpath(genpath('.\lib'));
end