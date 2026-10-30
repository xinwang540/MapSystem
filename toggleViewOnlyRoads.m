function toggleViewOnlyRoads()
global AppState;

% 防炸保护
if ~isfield(AppState,'ViewOnlyRoads')
    AppState.ViewOnlyRoads = false;
end

AppState.ViewOnlyRoads = ~AppState.ViewOnlyRoads;

if AppState.ViewOnlyRoads
    logMsg('已切换至：提取的道路网络');
else
    logMsg('已切换至：完整地图与道路');
end

updateMapDisplay();
end