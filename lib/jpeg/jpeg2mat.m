function matrix2D=jpeg2mat(filename)
    [dResult,info]=jpegFileDecode(filename);
    matrix2D=jpegPostDecode(dResult,info.Height,info.Width,info.QTable);
end