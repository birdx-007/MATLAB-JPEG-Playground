function mat2jpeg(matrix2D,filename)
    info=load("info_template.mat","info").info;
    [info.Height,info.Width]=size(matrix2D);
    [qResult,~,~]=jpegPreEncode(matrix2D,info.QTable);
    jpegFileEncode(filename,qResult,info);
end