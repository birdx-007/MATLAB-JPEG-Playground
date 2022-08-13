function [qResult,H,W]=jpegPreEncode(matrix2D,QT)
    blksz=8;
    [H,W]=size(matrix2D);
    matrix2D=double(matrix2D)-128;
    
    span=mod(blksz-mod(size(matrix2D),blksz),blksz);
    matrix2D=cat(2,matrix2D,repmat(matrix2D(:,end),[1,span(2)]));
    matrix2D=cat(1,matrix2D,repmat(matrix2D(end,:),[span(1),1]));
    blkscell=mat2cell(matrix2D,blksz*ones(1,size(matrix2D,1)/blksz),blksz*ones(1,size(matrix2D,2)/blksz))';
    dctblks=zeros(blksz,blksz,numel(blkscell));
    for i=1:numel(blkscell)
        dctblks(:,:,i)=dct2(blkscell{i});
    end
    dctblks=round(dctblks./QT);
    qResult=zeros(blksz*blksz,size(dctblks,3));
    for i=1:numel(blkscell)
        qResult(:,i)=zigzag8(dctblks(:,:,i));
    end
end