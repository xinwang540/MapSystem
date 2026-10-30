
function showLocalView(~, ~)
    global AppState;
    
    if ~isfield(AppState, 'IVs') || isempty(AppState.IVs)
        logMsg('地图上没有任何车辆，无法开启局部视图！');
        return;
    end
    
    AppState.LocalViewActive = true;
    

    if isfield(AppState, 'LocalViewCenterIVIdx') && ~isempty(AppState.LocalViewCenterIVIdx)
        idx = AppState.LocalViewCenterIVIdx;
    else
        if isfield(AppState, 'hIVSelect') && ~isempty(AppState.hIVSelect)
            val = AppState.hIVSelect.Value;
            
            if isnumeric(val) && ~isempty(val) && val >= 1
                idx = val;
            end
        else
            idx = length(AppState.IVs);
        end
    end
    
    if idx < 1 || idx > length(AppState.IVs)
        idx = length(AppState.IVs);
    end
    

    AppState.LocalViewCenterIVIdx = idx;
    AppState.LocalViewCenterIV = AppState.IVs(idx);
    
    if isfield(AppState, 'hIVSelect') && ~isempty(AppState.hIVSelect) && isvalid(AppState.hIVSelect)
        AppState.hIVSelect.Value = idx;
    end
    
    logMsg(sprintf('局部视图：第 %d 辆车 (X:%.1f, Y:%.1f)', idx, AppState.LocalViewCenterIV.X, AppState.LocalViewCenterIV.Y));
    
    updateMapDisplay();
end