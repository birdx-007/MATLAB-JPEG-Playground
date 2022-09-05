function [dResult,info]=jpegFileDecode(filename)
    disp('File decoding begins!');
    fileId=fopen(filename,"r");
    bytes=fread(fileId,inf,"uint8",0)';
    mkrStart=find(bytes==hex2dec('FF')); % FF position
    FFinCode=[];
    for i=1:length(mkrStart)
        mkr=bytes(mkrStart(i)+1);
        start=mkrStart(i)+2;
        if mkr==hex2dec('D8') % SOI 图像开始
            disp('SOI Marker Detected!');
        elseif mkr==hex2dec('E0') % APP0 应用程序保留标记0
            APP0len=bytes(start)*16^2+bytes(start+1);
            disp(['APP0 Marker Detected! Length=',num2str(APP0len)]);
            info.JpegIdentifier=char(bytes(start+2:start+6)); % 5b,identifier'JFIF '
            info.JpegVersion=num2str(bytes(start+7)+0.1*bytes(start+8)); % 2b,version
            Unit=bytes(start+9);
            if Unit==0 % 0
                info.Unit="no unit";
            elseif Unit==1 % 1
                info.Unit="pixel/inch";
            else % 2
                info.Unit="pixel/cm";
            end
            info.Xdensity=bytes(start+10)*16^2+bytes(start+11); % 2b,Xdensity
            info.Ydensity=bytes(start+12)*16^2+bytes(start+13); % 2b,Ydensity
            info.Xthumbnail=bytes(start+14); % 1b,Xthumbnail
            info.Ythumbnail=bytes(start+15); % 1b,Ythumbnail
            info.Thumbnail=reshape(bytes(start+16:start+APP0len-1),info.Xthumbnail,info.Ythumbnail,3); % (3*Xthumbnail*Ythumbnail)b,rgb thumbnail
        elseif mkr==hex2dec('DB') % DQT
            %暂时只能处理只有一个DQT块，每个DQT块只有一张精度为8的量化表(8*8)的情况
            DQTlen=bytes(start)*16^2+bytes(start+1);
            disp(['DQT Marker Detected! Length=',num2str(DQTlen)]);
            QTprecision=bin2dec(char(bitget(bytes(start+2),8:-1:5)+'0'));
            if QTprecision==0
                info.QTprecision=8;
            else
                info.QTprecision=16;
            end
            info.QTid=bin2dec(char(bitget(bytes(start+2),4:-1:1)+'0'));
            if QTprecision==0
                info.QTable=izigzag8(bytes(start+3:start+DQTlen-1)');
            end
        elseif mkr==hex2dec('C0') % SOF0
            SOF0len=bytes(start)*16^2+bytes(start+1);
            disp(['SOF0 Marker Detected! Length=',num2str(SOF0len)]);
            info.Precision=bytes(start+2);
            info.Height=bytes(start+3)*16^2+bytes(start+4);
            info.Width=bytes(start+5)*16^2+bytes(start+6);
            info.ComponentNum=bytes(start+7); % color component num
            info.Componentid=[];
            info.SubsampleFactor=char([]);
            info.QTid=[];
            %可读取多个颜色分量的信息
            for j=1:info.ComponentNum
                info.Componentid=cat(1,info.Componentid,bytes(start+6+2*j));
                info.SubsampleFactor=cat(1,info.SubsampleFactor,dec2hex(bytes(start+7+2*j)));
                info.QTid=cat(1,info.QTid,bytes(start+8+2*j));
            end
        elseif mkr==hex2dec('C4') % DHT
            %暂时只能处理DC、AC各只有一个Huffman表的情况
            DHTlen=bytes(start)*16^2+bytes(start+1);
            disp(['DHT Marker Detected! Length=',num2str(DHTlen)]);
            HTtype=bitget(bytes(start+2),5);
            HTid=bin2dec(char(bitget(bytes(start+2),4:-1:1)+'0'));
            if HTtype==0 %DC
                info.DCHTid=HTid;
                DCcodebitscnt=bytes(start+3:start+18);
                DCcodevals=bytes(start+19:start+18+sum(DCcodebitscnt));
                info.DCHTable=decodeHuffmanTable(0,DCcodebitscnt,DCcodevals);
            else %AC
                info.ACHTid=HTid;
                ACcodebitscnt=bytes(start+3:start+18);
                ACcodevals=bytes(start+19:start+18+sum(ACcodebitscnt));
                info.ACHTable=decodeHuffmanTable(1,ACcodebitscnt,ACcodevals);
            end
        elseif mkr==hex2dec('DA') % SOS
            SOSlen=bytes(start)*16^2+bytes(start+1);
            disp(['SOS Marker Detected! Length=',num2str(SOSlen)]);
            ComponentNum=bytes(start+2);
            Componentid=[];
            DCHTid=[];
            ACHTid=[];
            %可读取多个颜色分量的信息
            for j=1:ComponentNum
                Componentid=cat(1,Componentid,bytes(start+1+2*j));
                DCHTid=cat(1,DCHTid,bin2dec(char(bitget(bytes(start+2+2*j),8:-1:5)+'0')));
                ACHTid=cat(1,ACHTid,bin2dec(char(bitget(bytes(start+2+2*j),4:-1:1)+'0')));
            end
            % 00 3F 00
            imageStart=start+SOSlen;
        elseif mkr==hex2dec('D9') % EOI
            disp('EOI Marker Detected!');
            imageEnd=mkrStart(i)-1;
        else
            FFinCode=cat(2,FFinCode,mkrStart(i)-imageStart+1);
        end
    end
    code=bytes(imageStart:imageEnd);
    deleteinCode=[];
    for i=FFinCode
        FFnextbyte=code(i+1);
        if FFnextbyte==hex2dec('00')
            deleteinCode=cat(2,deleteinCode,i+1);
        elseif FFnextbyte==hex2dec('FF')
            deleteinCode=cat(2,deleteinCode,i);
        else
            deleteinCode=cat(2,deleteinCode,i);
        end
    end
    code(deleteinCode)=[];
    code=reshape(dec2bin(code)'-'0',1,[]);
    dResult=jpegEntropyDecode(code,info.DCHTable,info.ACHTable);
end