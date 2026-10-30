function handleIVMenuChange(src)
    global AppState;
    if isempty(AppState.IVs), return; end
    
    val = src.Value;
    if strcmp(val, '无车辆')
        AppState.LocalViewCenterIV = [];
        if isfield(AppState, 'LocalViewCenterIVIdx'), AppState.LocalViewCenterIVIdx = []; end
        return;
    end
    
    numStr = regexp(string(val), '\d+', 'match');
    if ~isempty(numStr)
        selectedIndex = str2double(numStr(1));
        if selectedIndex >= 1 && selectedIndex <= length(AppState.IVs)
            % 1. [保留你原本的逻辑] 记录当前选中的车辆和索引
            AppState.LocalViewCenterIVIdx = selectedIndex; 
            AppState.LocalViewCenterIV = AppState.IVs(selectedIndex);
            
            % 2. 🌟 [新融合的功能] 自动提取这辆车的大写 Heading，同步到界面输入框中！
            if isfield(AppState, 'hAngleEdit') && isvalid(AppState.hAngleEdit)
                AppState.hAngleEdit.Value = AppState.IVs(selectedIndex).Heading;
            end
            
            logMsg(sprintf('第 %d 辆车 局部视图 & 已同步车头角度', selectedIndex));
            
            % 3. [保留你原本的逻辑] 如果局部视图开着，刷新显示
            if AppState.LocalViewActive
                updateMapDisplay();
            end
        end
    end
end