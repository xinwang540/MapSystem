function heading = casedRoadHeading(c, r)
    global AppState;
    heading = 0; 
    if ~isfield(AppState, 'skelMask') || ~any(AppState.skelMask(:)), return; end
    
    [H, W] = size(AppState.skelMask);
    searchRadius = 30; 
    c_min = max(1, c - searchRadius); c_max = min(W, c + searchRadius);
    r_min = max(1, r - searchRadius); r_max = min(H, r + searchRadius);
    
    localMask = AppState.skelMask(r_min:r_max, c_min:c_max);
    [row_idx, col_idx] = find(localMask);
    
    pts_c = col_idx + c_min - 1;
    pts_r = row_idx + r_min - 1;
    
    pts = [pts_c - mean(pts_c), pts_r - mean(pts_r)];
    
    covarianceMatrix = (pts' * pts) / size(pts, 1);
    [V, D] = eig(covarianceMatrix);
    [~, maxDiagIdx] = max(diag(D));
    mainVector = V(:, maxDiagIdx); 
    
    fixed_dX = -mainVector(1); 
    fixed_dY = mainVector(2);  
    
    raw_rad = atan2(fixed_dY, fixed_dX);
    
    raw_deg = rad2deg(raw_rad); 
    heading = mod(raw_deg, 360);
    
end