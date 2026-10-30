function updateMapDisplay()
    global AppState;
    if isempty(AppState) || ~isfield(AppState, 'hAx'), return; end
    cla(AppState.hAx); hold(AppState.hAx, 'on');
    
    [H, W, ~] = size(AppState.MapImg);
    
    if isfield(AppState, 'ViewOnlyRoads') && isequal(AppState.ViewOnlyRoads, true)
        isViewOnly = true;
    else
        isViewOnly = false;
    end
    
    %% 背景
    if AppState.LocalViewActive && ~isempty(AppState.LocalViewCenterIV)
        iv = AppState.LocalViewCenterIV;
        radius_m = AppState.LocalViewRadius;
        
        [c_orig, r_orig] = realToPixel(iv.X, iv.Y);
        [c0, r0] = projectToRotatedView(c_orig, r_orig, AppState.RotAngle);
        
        radius_px = radius_m / 1.7;
        [Xc, Yc] = meshgrid(1:W, 1:H);
        mask = (Xc - c0).^2 + (Yc - r0).^2 <= radius_px^2;
        
        if isViewOnly
            baseImg = ones(H, W, 3, 'uint8') * 255;
        else
            baseImg = AppState.DisplayImg;
        end
        
        for k = 1:3
            ch = baseImg(:,:,k);
            ch(~mask) = 128; 
            baseImg(:,:,k) = ch;
        end
        
        hMainImg = imshow(baseImg, 'Parent', AppState.hAx);
        
        xlim(AppState.hAx, [c0 - radius_px, c0 + radius_px]);
        ylim(AppState.hAx, [r0 - radius_px, r0 + radius_px]);
        
        r_min = max(1, floor(r0 - radius_px));
        c_min = max(1, floor(c0 - radius_px));
        AppState.LocalViewCropRect = [r_min, c_min, radius_px*2, radius_px*2];
        
    else
        if isViewOnly
            whiteBg = ones(H, W, 3, 'uint8') * 255;
            hMainImg = imshow(whiteBg, 'Parent', AppState.hAx);
        else
            hMainImg = imshow(AppState.DisplayImg, 'Parent', AppState.hAx); 
        end
        xlim(AppState.hAx, [1, W]); ylim(AppState.hAx, [1, H]); 
    end
    
    %% 道路网络蒙版
    hOverlay = []; 
    if isfield(AppState, 'skelMask') && ~isempty(AppState.skelMask) && any(AppState.skelMask(:))
        blueAlpha = 0.42;
        if isViewOnly, blueAlpha = 0.85; end 
        if isfield(AppState, 'RotAngle') && AppState.RotAngle ~= 0
            rotatedMask = manualRotateMask(AppState.skelMask, AppState.RotAngle);
        else
            rotatedMask = AppState.skelMask;
        end
        
        blueLayer = zeros(H, W, 3);
        blueLayer(:,:,1) = 0.0; blueLayer(:,:,2) = 0.75; blueLayer(:,:,3) = 1.0; 
        hOverlay = imagesc(AppState.hAx, blueLayer);
        alphaData = zeros(H, W);
        
        [maskH, maskW] = size(rotatedMask);
        useH = min(H, maskH); useW = min(W, maskW);
        alphaData(1:useH, 1:useW) = rotatedMask(1:useH, 1:useW) * blueAlpha;
        set(hOverlay, 'AlphaData', alphaData);
    end
    
 
    if isfield(AppState, 'CurrentMode') && strcmp(AppState.CurrentMode, 'ROAD_GUIDE_MODE')
        if isfield(AppState, 'NavPoints') && ~isempty(AppState.NavPoints)
            [nx, ny] = projectToRotatedView(AppState.NavPoints(:,1), AppState.NavPoints(:,2), AppState.RotAngle);
            plot(AppState.hAx, nx, ny, 'c.', 'MarkerSize', 16); 
            if size(AppState.NavPoints, 1) > 1
                plot(AppState.hAx, nx, ny, 'c:', 'LineWidth', 1.5);
            end
        end
    end
    

    if isfield(AppState, 'CurrentMode') && strcmp(AppState.CurrentMode, 'NAV_MODE')
        if isfield(AppState, 'PlannedPath') && ~isempty(AppState.PlannedPath)
            [px, py] = projectToRotatedView(AppState.PlannedPath(:,1), AppState.PlannedPath(:,2), AppState.RotAngle);
            plot(AppState.hAx, px, py, 'r-', 'LineWidth', 5);
        end
        if isfield(AppState, 'StartPoint') && ~isempty(AppState.StartPoint)
            [sx, sy] = projectToRotatedView(AppState.StartPoint(1), AppState.StartPoint(2), AppState.RotAngle);
            plot(AppState.hAx, sx, sy, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
        end
        if isfield(AppState, 'EndPoint') && ~isempty(AppState.EndPoint)
            [ex, ey] = projectToRotatedView(AppState.EndPoint(1), AppState.EndPoint(2), AppState.RotAngle);
            plot(AppState.hAx, ex, ey, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        end
    end
    
%% 测距离
    if isfield(AppState, 'CurrentMode') && (strcmp(AppState.CurrentMode, 'DISTANCE') || strcmp(AppState.CurrentMode, 'TRAJECTORY'))
        if isfield(AppState, 'TempPoints') && ~isempty(AppState.TempPoints)
            [c_t, r_t] = realToPixel(AppState.TempPoints(:,1), AppState.TempPoints(:,2));
            [tx, ty] = projectToRotatedView(c_t, r_t, AppState.RotAngle);
            
            plot(AppState.hAx, tx, ty, 'yo', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'LineWidth', 2);
            if size(AppState.TempPoints, 1) > 1
                plot(AppState.hAx, tx, ty, 'y--', 'LineWidth', 2.5);
            end
        end
    end
    
    %%  小车
   if isfield(AppState, 'IVs') && ~isempty(AppState.IVs)
        for i = 1:length(AppState.IVs)
            tempIV = AppState.IVs(i);
            
            [c_orig, r_orig] = realToPixel(tempIV.X, tempIV.Y);        
            [c_rot, r_rot] = projectToRotatedView(c_orig, r_orig, AppState.RotAngle);
        
            drawIV = tempIV;
            drawIV.X = c_rot; 
            drawIV.Y = r_rot; 
            
    
            drawIV.Heading = tempIV.Heading - AppState.RotAngle;
            
            drawVehicle(drawIV, AppState.IVScale); 
        end
    end
    hold(AppState.hAx, 'off');

    set(AppState.hAx, 'ButtonDownFcn', @handleImageClick);
    if exist('hMainImg', 'var') && isvalid(hMainImg)
        set(hMainImg, 'ButtonDownFcn', @handleImageClick);
    end
    if ~isempty(hOverlay) && isvalid(hOverlay)
        set(hOverlay, 'ButtonDownFcn', @handleImageClick);
    end
end