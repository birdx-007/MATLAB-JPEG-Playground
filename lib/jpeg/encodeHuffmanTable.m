function code=encodeHuffmanTable(type,table)
    if type==0 %DC
        bitscol=2;
        vals=table(:,1)';
    else %AC
        bitscol=3;
        vals=table(:,1)'*16+table(:,2)';
    end
    bits=table(:,bitscol)';
    bitscnt=[];
    for i=1:16
        bitscnt=cat(2,bitscnt,sum(bits==i));
    end
    code=[bitscnt,vals];
end