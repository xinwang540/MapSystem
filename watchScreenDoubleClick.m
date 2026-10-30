% 检测屏幕双击
function watchScreenDoubleClick(src, ~)
    global AppState;
    if strcmp(AppState.CurrentMode, 'ROAD_GUIDE_MODE') && strcmp(src.SelectionType, 'open')
        if ~isempty(AppState.MaskHistory)
            AppState.skelMask = AppState.MaskHistory{end};
            AppState.MaskHistory(end) = []; 
            
            if size(AppState.NavPoints, 1) > 0
                AppState.NavPoints(end, :) = [];
            end
            if ~isempty(AppState.NavPoints)
                AppState.LastRoadPt = AppState.NavPoints(end, :);
            else
                AppState.LastRoadPt = [];
            end
            
            logMsg(' 已成功撤销上一截连线道路');
            updateMapDisplay();
        else
            logMsg('️ 无法撤销：当前历史路径记录为空');
        end
    end
end