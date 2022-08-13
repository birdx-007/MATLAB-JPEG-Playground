function code=jpegEntropyEncode(qResult,DCHT,ACHT)
    EOBrow=find(and(ACHT(:,1)==0,ACHT(:,2)==0));
    EOBlen=ACHT(EOBrow,3);
    EOB=ACHT(EOBrow,4:4+EOBlen-1);
    ZRLrow=find(and(ACHT(:,1)==15,ACHT(:,2)==0));
    ZRLlen=ACHT(ZRLrow,3);
    ZRL=ACHT(ZRLrow,4:4+ZRLlen-1);
    code=[];
    qResult(1,:)=[qResult(1,1),diff(qResult(1,:))];
    for i=1:size(qResult,2)
        blkCoef=qResult(:,i);
        % DC
        Cdc=blkCoef(1);
        Category=ceil(log2(abs(Cdc)+1));
        DCrow=find(DCHT(:,1)==Category);
        codelen=DCHT(DCrow,2);
        code=cat(2,code,DCHT(DCrow,3:3+codelen-1));
        if Cdc<0
            Magnitude=not(logical(dec2bin(-Cdc)-'0'));
        elseif blkCoef(1)>0
            Magnitude=logical(dec2bin(Cdc)-'0');
        else
            Magnitude=[];
        end
        code=cat(2,code,Magnitude);
        % AC
        Cac=blkCoef(2:end)';
        nzidx=find(Cac~=0);
        nz=Cac(nzidx);
        if isempty(nz)
            code=cat(2,code,EOB);
            continue;
        end
        Run=diff([0,nzidx])-1;
        Size=ceil(log2(abs(nz)+1));
        for j=1:length(nz)
            while Run(j)>15
                Run(j)=Run(j)-16;
                code=cat(2,code,ZRL);
            end
            ACrow=find(and(ACHT(:,1)==Run(j),ACHT(:,2)==Size(j)));
            codelen=ACHT(ACrow,3);
            code=cat(2,code,ACHT(ACrow,4:4+codelen-1));
            if nz(j)<0
                Amplitude=not(logical(dec2bin(-nz(j))-'0'));
            else
                Amplitude=logical(dec2bin(nz(j))-'0');
            end
            code=cat(2,code,Amplitude);
        end
        if nzidx(end)<length(Cac)
            code=cat(2,code,EOB);
        end
    end
    if mod(length(code),8)~=0
        code=cat(2,code,ones(1,8-mod(length(code),8)));
    end
end