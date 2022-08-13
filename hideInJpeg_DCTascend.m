function hideInJpeg_DCTascend(secret,injpegname,outjpegname)
    addpath(genpath('.\lib'));
    
    secret=double(char(secret));
    secret=reshape(dec2bin(secret,7)',1,[])-'0'; % ascii 0-127
    secret=cat(2,logical(secret),false(1,7)); % EOB
    [dResult,info]=jpegFileDecode(injpegname);
    if numel(secret)>numel(dResult)
        error('Error. \nSecret(%d) is too long to hide in image(%d).',numel(secret),numel(dResult));
    end
    [~,Qsortidx]=sort(zigzag8(info.QTable),'ascend');
    Qnum=size(Qsortidx,1);
    blknum=size(dResult,2);
    for i=1:Qnum
        if length(secret)>=blknum
            dResult(Qsortidx(i),:)=double(bitset(int16(dResult(Qsortidx(i),:)),1,secret(1:blknum)));
            secret=secret(blknum+1:end);
        else
            dResult(Qsortidx(i),1:length(secret))=double(bitset(int16(dResult(Qsortidx(i),1:length(secret))),1,secret));
            break;
        end
    end
    jpegFileEncode(outjpegname,dResult,info)
    
    rmpath(genpath('.\lib'));
end