function rotatedImg = manualRotateImage(img, degree)
    rad = deg2rad(degree);
    [H, W, C] = size(img);
    c0 = W/2; r0 = H/2;
    rotatedImg = uint8(ones(H, W, C) * 255);
    [C_grid, R_grid] = meshgrid(1:W, 1:H);
    c_orig = round(cos(rad).*(C_grid-c0) + sin(rad).*(R_grid-r0) + c0);
    r_orig = round(-sin(rad).*(C_grid-c0) + cos(rad).*(R_grid-r0) + r0);
    valid = (c_orig>=1 & c_orig<=W & r_orig>=1 & r_orig<=H);
    for k = 1:C
        ch = img(:,:,k);
        tmp = rotatedImg(:,:,k);
        idx = sub2ind([H,W], r_orig(valid), c_orig(valid));
        tmp(valid) = ch(idx);
        rotatedImg(:,:,k) = tmp;
    end
end
