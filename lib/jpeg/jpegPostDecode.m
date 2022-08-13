function matrix2D=jpegPostDecode(dResult,H,W,QT)
    blksz=8;
    matrix2D=cell(ceil(W/blksz),ceil(H/blksz));
    for i=1:size(dResult,2)
        dblk=izigzag8(dResult(:,i));
        dblk=dblk.*QT;
        dblk=idct2(dblk);
        matrix2D{i}=dblk;
    end
    matrix2D=uint8(cell2mat(matrix2D')+128);
    matrix2D=matrix2D(1:H,1:W);
end