function refreshIVDropdown()
    global AppState;
    if ~isfield(AppState, 'hIVSelect') || isempty(AppState.hIVSelect), return; end
    
    if isempty(AppState.IVs)
        AppState.hIVSelect.Items = {'无车辆'};
        AppState.hIVSelect.Value = '无车辆';
        AppState.LocalViewCenterIV = [];
    else
        %当前 IVs 数组长度
        itemsCell = cell(1, length(AppState.IVs));
        for i = 1:length(AppState.IVs)
            itemsCell{i} = sprintf('车辆 %d', i);
        end
        
        AppState.hIVSelect.Items = itemsCell;
        
        isCenterValid = false;
        for i = 1:length(AppState.IVs)
            if isequal(AppState.LocalViewCenterIV, AppState.IVs(i))
                AppState.hIVSelect.Value = sprintf('车辆 %d', i);
                isCenterValid = true;
                break;
            end
        end
        
        if ~isCenterValid
            AppState.LocalViewCenterIV = AppState.IVs(end);
            AppState.hIVSelect.Value = sprintf('车辆 %d', length(AppState.IVs));
        end
    end
end