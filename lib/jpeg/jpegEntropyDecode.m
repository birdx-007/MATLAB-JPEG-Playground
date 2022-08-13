function dResult=jpegEntropyDecode(code,DCHT,ACHT)
    blksz=8;
    dCdc=[];
    dCacs=[];
    while code(end)==1
        code(end)=[];
    end
    idx=1;
    len=length(code);
    while idx<len
        blkend=false;
        for i=1:size(DCHT,1)
            codelen=DCHT(i,2);
            if isequal(code(idx:idx-1+codelen),DCHT(i,3:3+codelen-1))
                Category=DCHT(i,1);
                Magnitude=code(idx+codelen:idx-1+codelen+Category);
                idx=idx+codelen+Category;
                if Category==0 % 0
                    dCdc=cat(2,dCdc,0);
                    break;
                end
                if Magnitude(1)==0  % negative
                    Magnitude=-bin2dec(char(not(Magnitude)+'0'));
                else % positive
                    Magnitude=bin2dec(char(Magnitude+'0'));
                end
                dCdc=cat(2,dCdc,Magnitude);
                break;
            end
        end
        dCac=[];
        while ~blkend
            for i=1:size(ACHT,1)
                codelen=ACHT(i,3);
                if isequal(code(idx:idx-1+codelen),ACHT(i,4:4+codelen-1))
                    Run=ACHT(i,1);
                    Size=ACHT(i,2);
                    Amplitude=code(idx+codelen:idx-1+codelen+Size);
                    idx=idx+codelen+Size;
                    if Run==0 && Size==0 % EOB
                        dCac=cat(1,dCac,zeros(blksz*blksz-1-length(dCac),1));
                        blkend=true;
                        break;
                    elseif Run==15 && Size==0 % ZRL
                        dCac=cat(1,dCac,zeros(16,1));
                        break;
                    elseif Amplitude(1)==0  % negative
                        Amplitude=-bin2dec(char(not(Amplitude)+'0'));
                    else % positive
                        Amplitude=bin2dec(char(Amplitude+'0'));
                    end
                    dCac=cat(1,dCac,[zeros(Run,1);Amplitude]);
                    break;
                end
            end
            if length(dCac)==blksz*blksz-1
                blkend=true;
            end
        end
        dCacs=cat(2,dCacs,dCac);
    end
    dCdc=cumsum(dCdc);
    dResult=cat(1,dCdc,dCacs);
end