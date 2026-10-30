%下拉框回调函数 选择车辆
function hIVSelectValueChanged(chosenIdx)
    global AppState;
    if isempty(AppState) || ~isfield(AppState, 'IVs') || isempty(AppState.IVs), return; end
    
    if chosenIdx == 0 || chosenIdx > length(AppState.IVs)
        AppState.LocalViewCenterIVIdx = [];
        AppState.LocalViewCenterIV = [];
        return;
    end
        AppState.LocalViewCenterIVIdx = chosenIdx;
    AppState.LocalViewCenterIV = AppState.IVs(chosenIdx);
  
    
    if isfield(AppState, 'LocalViewActive') && AppState.LocalViewActive
        updateMapDisplay();
    end
end