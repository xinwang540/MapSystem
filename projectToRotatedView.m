function [cx, ry] = projectToRotatedView(x, y, degree)
    global AppState;
    [H, W, ~] = size(AppState.MapImg);
    c0 = W/2; r0 = H/2;
    rad = deg2rad(degree);
    
    % 旋转矩阵坐标投影
    cx = cos(rad).*(x - c0) - sin(rad).*(y - r0) + c0;
    ry = sin(rad).*(x - c0) + cos(rad).*(y - r0) + r0;
end