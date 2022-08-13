function jpegFileEncode(filename,qResult,info)
    bytes=[];
    % SOI
    bytes=cat(2,bytes,hex2dec(["FF","D8"]));
    % APP0
    bytes=cat(2,bytes,hex2dec(["FF","E0"]));
    APP0len=16+3*info.Xthumbnail*info.Ythumbnail;
    bytes=cat(2,bytes,[floor(APP0len/(16^2)),mod(APP0len,16^2)]);
    bytes=cat(2,bytes,[double('JFIF'),0]);
    bytes=cat(2,bytes,[info.JpegVersion(1),info.JpegVersion(3)]-'0');
    if info.Unit=="no unit" % 0
        bytes=cat(2,bytes,0);
    elseif info.Unit=="pixel/inch" % 1
        bytes=cat(2,bytes,1);
    elseif info.Unit=="pixel/cm" % 2
        bytes=cat(2,bytes,2);
    end
    bytes=cat(2,bytes,[floor(info.Xdensity/(16^2)),mod(info.Xdensity,16^2)]);
    bytes=cat(2,bytes,[floor(info.Ydensity/(16^2)),mod(info.Ydensity,16^2)]);
    bytes=cat(2,bytes,[info.Xthumbnail,info.Ythumbnail]);
    bytes=cat(2,bytes,reshape(info.Thumbnail,1,[]));
    % DQT
    bytes=cat(2,bytes,hex2dec(["FF","DB"]));
    DQTlen=3+64*(info.QTprecision/8);
    bytes=cat(2,bytes,[floor(DQTlen/(16^2)),mod(DQTlen,16^2)]);
    bytes=cat(2,bytes,(info.QTprecision/8-1)*16+info.QTid);
    bytes=cat(2,bytes,zigzag8(info.QTable)');
    % SOF0
    bytes=cat(2,bytes,hex2dec(["FF","C0"]));
    SOF0len=8+3*info.ComponentNum;
    bytes=cat(2,bytes,[floor(SOF0len/(16^2)),mod(SOF0len,16^2)]);
    bytes=cat(2,bytes,info.Precision);
    bytes=cat(2,bytes,[floor(info.Height/(16^2)),mod(info.Height,16^2)]);
    bytes=cat(2,bytes,[floor(info.Width/(16^2)),mod(info.Width,16^2)]);
    bytes=cat(2,bytes,info.ComponentNum);
    for i=1:info.ComponentNum
        bytes=cat(2,bytes,info.Componentid(i));
        bytes=cat(2,bytes,hex2dec(info.SubsampleFactor(i,:)));
        bytes=cat(2,bytes,info.QTid(i));
    end
    % DHT-DC
    bytes=cat(2,bytes,hex2dec(["FF","C4"]));
    DCHTcode=encodeHuffmanTable(0,info.DCHTable);
    DHTlen=3+length(DCHTcode);
    bytes=cat(2,bytes,[floor(DHTlen/(16^2)),mod(DHTlen,16^2)]);
    bytes=cat(2,bytes,0*16+info.DCHTid);
    bytes=cat(2,bytes,DCHTcode);
    % DHT-AC
    bytes=cat(2,bytes,hex2dec(["FF","C4"]));
    ACHTcode=encodeHuffmanTable(1,info.ACHTable);
    DHTlen=3+length(ACHTcode);
    bytes=cat(2,bytes,[floor(DHTlen/(16^2)),mod(DHTlen,16^2)]);
    bytes=cat(2,bytes,1*16+info.ACHTid);
    bytes=cat(2,bytes,ACHTcode);
    % SOS
    bytes=cat(2,bytes,hex2dec(["FF","DA"]));
    SOSlen=3+2*info.ComponentNum+3;
    bytes=cat(2,bytes,[floor(SOSlen/(16^2)),mod(SOSlen,16^2)]);
    bytes=cat(2,bytes,info.ComponentNum);
    for i=1:info.ComponentNum
        bytes=cat(2,bytes,info.Componentid(i));
        bytes=cat(2,bytes,info.DCHTid*16+info.ACHTid);
    end
    bytes=cat(2,bytes,hex2dec(["00","3F","00"]));
    % data
    code=jpegEntropyEncode(qResult,info.DCHTable,info.ACHTable);
    code=bin2dec(char(reshape(code,8,[])'+'0'))';
    FFincode=find(code==hex2dec('FF'),1);
    while ~isempty(FFincode) && FFincode<=length(code)
        code=cat(2,code(1:FFincode),0,code(FFincode+1:end));
        FFincode=FFincode+1+find(code(FFincode+2:end)==hex2dec('FF'),1);
    end
    bytes=cat(2,bytes,code);
    % EOI
    bytes=cat(2,bytes,hex2dec(["FF","D9"]));
    fileId=fopen(filename,"w");
    fwrite(fileId,bytes,"uint8");
end