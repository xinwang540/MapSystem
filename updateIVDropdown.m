function updateIVDropdown()
    global AppState;
    if ~isfield(AppState, 'hIVSelect') || isempty(AppState.hIVSelect) || ~isvalid(AppState.hIVSelect), return; end
    if ~isfield(AppState, 'LocalViewCenterIVIdx'), AppState.LocalViewCenterIVIdx = []; end
    
    if isempty(AppState.IVs)
        AppState.hIVSelect.Items = {'无车辆'};
        AppState.hIVSelect.ItemsData = {0}; 
        AppState.hIVSelect.Value = 0;
        AppState.LocalViewCenterIV = [];
        AppState.LocalViewCenterIVIdx = [];
        return;
    end
    
    numVehicles = length(AppState.IVs);
    itemsCell = cell(1, numVehicles);
    itemsDataCell = cell(1, numVehicles);
    
    for i = 1:numVehicles
        itemsCell{i} = sprintf('车辆 %d', i);
        itemsDataCell{i} = i; 
    end
    AppState.hIVSelect.Items = itemsCell;
    AppState.hIVSelect.ItemsData = itemsDataCell;
    

    idx = AppState.LocalViewCenterIVIdx;
    
    if ~isempty(idx) && idx >= 1 && idx <= numVehicles
        AppState.hIVSelect.Value = idx;                 
        AppState.LocalViewCenterIV = AppState.IVs(idx);  
        
    else
        if isfield(AppState, 'LocalViewActive') && AppState.LocalViewActive
            AppState.LocalViewCenterIVIdx = numVehicles;
            AppState.LocalViewCenterIV = AppState.IVs(end);
            AppState.hIVSelect.Value = numVehicles;
        else
 
            AppState.hIVSelect.Value = numVehicles;
            AppState.LocalViewCenterIVIdx = []; 
            AppState.LocalViewCenterIV = [];
        end
    end
end