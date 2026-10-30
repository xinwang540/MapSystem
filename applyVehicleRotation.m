function applyVehicleRotation()
    global AppState;
    val = AppState.hIVSelect.Value;
    
    if strcmp(val, '无车辆') || isempty(AppState.IVs)
        logMsg('错误：当前系统内没有车辆！');
        return;
    end
    
    numStr = regexp(string(val), '\d+', 'match');
    if ~isempty(numStr)
        selectedIndex = str2double(numStr(1));
        if selectedIndex >= 1 && selectedIndex <= length(AppState.IVs)
            
            newAngle = AppState.hAngleEdit.Value;
            AppState.IVs(selectedIndex).Heading = newAngle;
            
            if isfield(AppState, 'LocalViewCenterIVIdx') &&   ~isempty(AppState.LocalViewCenterIVIdx) && ...
               AppState.LocalViewCenterIVIdx == selectedIndex
           
                AppState.LocalViewCenterIV = AppState.IVs(selectedIndex);
            end
            
            logMsg(sprintf('成功将 IV %d 的方向修改为: %.1f°', selectedIndex, newAngle));
            updateMapDisplay(); 
        else
            logMsg('错误：选择的车辆索引超出当前数组范围！');
        end
    else
        logMsg('错误：无法从选择项中解析出车辆编号！');
    end
end