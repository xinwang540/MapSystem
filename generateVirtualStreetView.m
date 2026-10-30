function generateVirtualStreetView(clickC, clickR, roadHeading)
    global AppState;
    
    if ~isfield(AppState, 'camYawOffset') || ...
       (~isfield(AppState, 'lastClickC') || AppState.lastClickC ~= clickC || AppState.lastClickR ~= clickR)
        AppState.camYawOffset = 0; 
        AppState.lastClickC = clickC;
        AppState.lastClickR = clickR;
    end
    
    viewW = 640; 
    viewH = 480;
    streetImg = zeros(viewH, viewW, 3, 'uint8');
    
    focalLength = 380;
    u0 = viewW / 2;    
    v0 = viewH / 2;  
    camHeight = 2.0;   
    
    [imgH, imgW, ~] = size(AppState.MapImg);
    X_cam = clickC * 1.7;
    Y_cam = (imgH - clickR) * 1.7;
    
    finalHeading = roadHeading + AppState.camYawOffset;
    theta = deg2rad(finalHeading); 
    
    cosT = cos(theta);
    sinT = sin(theta);
    
    [u_grid, v_grid] = meshgrid(1:viewW, 1:viewH);
    xc = (u_grid - u0) ./ focalLength;
    yc = (v_grid - v0) ./ focalLength; 
    
    validRay = (yc > 1e-4); 
    
    t = camHeight ./ max(yc, 1e-4);
    x_local = xc .* t;
    z_local = t; 
    
    X_ground = X_cam + (cosT .* z_local + sinT .* x_local);
    Y_ground = Y_cam + (sinT .* z_local - cosT .* x_local);
    
    c_map = X_ground ./ 1.7;
    r_map = imgH - (Y_ground ./ 1.7);
    
    for channel = 1:3
        mapChannel = double(AppState.MapImg(:,:,channel));
        
        c_map(~validRay) = 1;
        r_map(~validRay) = 1;
        
        c0 = floor(c_map); c1 = c0 + 1;
        r0 = floor(r_map); r1 = r0 + 1;
        
        c0 = max(1, min(imgW, c0)); c1 = max(1, min(imgW, c1));
        r0 = max(1, min(imgH, r0)); r1 = max(1, min(imgH, r1));
        
        dc = c_map - c0;
        dr = r_map - r0;
        
        pixelVal = (1-dr).*(1-dc).*mapChannel(sub2ind([imgH, imgW], r0, c0)) + ...
                   (1-dr).*(dc).*mapChannel(sub2ind([imgH, imgW], r0, c1)) + ...
                   (dr).*(1-dc).*mapChannel(sub2ind([imgH, imgW], r1, c0)) + ...
                   (dr).*(dc).*mapChannel(sub2ind([imgH, imgW], r1, c1));
               
        if channel == 1
            pixelVal(~validRay) = 135; 
        elseif channel == 2
            pixelVal(~validRay) = 206; 
        elseif channel == 3
            pixelVal(~validRay) = 250; 
        end
        
        streetImg(:,:,channel) = uint8(pixelVal);
    end
    
    if ~isfield(AppState, 'hStreetFig') || ~isvalid(AppState.hStreetFig)
        AppState.hStreetFig = uifigure('Name', '虚拟路口实时街景 ', 'Position', [200, 200, 640, 520]); 
        
        AppState.hStreetTitleLabel = uilabel(AppState.hStreetFig, ...
            'Position', [10, 485, 620, 30], ...
            'FontWeight', 'bold', ...
            'FontSize', 13, ...
            'HorizontalAlignment', 'center');
        
        AppState.hBtnLeft = uibutton(AppState.hStreetFig, 'Text', '左转 15°', 'Position', [150, 8, 140, 30]);
        AppState.hBtnRight = uibutton(AppState.hStreetFig, 'Text', '右转 15°', 'Position', [350, 8, 140, 30]);
    end
    
    AppState.hBtnLeft.ButtonPushedFcn = @(~,~) rotateCamera(clickC, clickR, roadHeading, 15);
    AppState.hBtnRight.ButtonPushedFcn = @(~,~) rotateCamera(clickC, clickR, roadHeading, -15);
    
    ax = findobj(AppState.hStreetFig, 'Type', 'uiaxes');
    if isempty(ax)
        ax = uiaxes(AppState.hStreetFig, 'Position', [0, 45, 640, 440]);
        ax.Toolbar.Visible = 'off';
        xticks(ax, []); yticks(ax, []);
    end
    
    imshow(streetImg, 'Parent', ax);
    
    AppState.hStreetTitleLabel.Text = sprintf('位置: (%d m, %d m) | 绝对朝向: %.1f° (手动微调: %d°)', round(clickC), round(clickR), finalHeading, AppState.camYawOffset);
end

function rotateCamera(clickC, clickR, roadHeading, angle)
    global AppState;
    AppState.camYawOffset = AppState.camYawOffset + angle;
    generateVirtualStreetView(clickC, clickR, roadHeading);
end