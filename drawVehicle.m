function drawVehicle(iv, scale)
    global AppState;
    if isempty(AppState) || ~isfield(AppState, 'hAx'), return; end
    
    [H_orig, W_orig, ~] = size(AppState.MapImg);
    x0 = W_orig / 2;
    y0 = H_orig / 2;
    
    mapRot = 0;
    if isfield(AppState, 'RotAngle'), mapRot = AppState.RotAngle; end
    theta = deg2rad(mapRot);
    
    x_shifted = iv.pixC - x0;
    y_shifted = iv.pixR - y0;
    
    current_pixC = x_shifted * cos(theta) - y_shifted * sin(theta) + x0;
    current_pixR = x_shifted * sin(theta) + y_shifted * cos(theta) + y0;
    
    L = 8 * scale;
    W = 3 * scale;
    
    totalHeading = iv.Heading; 
    rad = deg2rad(totalHeading); 
    
    x_local = [-L/2, L/2, L/2, -L/2, -L/2];
    y_local = [-W/2, -W/2, W/2, W/2, -W/2];
    

    c_pix = cos(rad)*x_local - sin(rad)*y_local + current_pixC;
    r_pix = -sin(rad)*x_local - cos(rad)*y_local + current_pixR; 
   
    x_front_local = L/2; 
    y_front_local = 0;  
    c_front_pix = cos(rad)*x_front_local - sin(rad)*y_front_local + current_pixC;
    r_front_pix = -sin(rad)*x_front_local - cos(rad)*y_front_local + current_pixR; 
    
    plot(AppState.hAx, c_pix, r_pix, 'r-', 'LineWidth', 2);
    plot(AppState.hAx, c_front_pix, r_front_pix, 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
end