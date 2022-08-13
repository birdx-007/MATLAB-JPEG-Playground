function table=decodeHuffmanTable(type,bitscnt,vals)
    codeBits=find(bitscnt~=0);
    sameBitsCodesCnt=bitscnt(bitscnt~=0);
    if type==1 %AC
        Run=floor(vals'/16);
        Size=mod(vals',16);
        table=[Run,Size];
    else %DC
        Category=vals';
        table=Category;
    end
    codeLens=[];
    codes=[];
    codeVal=0;
    currentCodeLen=0;
    for i=1:length(codeBits)
        codeLens=cat(1,codeLens,codeBits(i)*ones(sameBitsCodesCnt(i),1));
        if i==1
            codes=cat(1,codes,[zeros(1,codeBits(i)),zeros(1,codeBits(end)-codeBits(i))]);
            currentCodeLen=codeBits(i);
            for j=2:sameBitsCodesCnt(i)
                codeVal=codeVal+1;
                code=dec2bin(codeVal,currentCodeLen);
                code=code-'0';
                codes=cat(1,codes,[code,zeros(1,codeBits(end)-codeBits(i))]);
            end
        else
            for j=1:sameBitsCodesCnt(i)
                codeVal=codeVal+1;
                code=dec2bin(codeVal,currentCodeLen);
                while length(code)<codeBits(i)
                    codeVal=bitshift(codeVal,1);
                    currentCodeLen=currentCodeLen+1;
                    code=dec2bin(codeVal,currentCodeLen);
                end
                code=code-'0';
                codes=cat(1,codes,[code,zeros(1,codeBits(end)-codeBits(i))]);
            end
        end
    end
    table=cat(2,table,[codeLens,codes]);
end