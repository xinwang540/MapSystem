function updateLocalViewRadius(newRadius)
    global AppState;
    % 1. 将界面上输入的新半径（米）实时打入全局变量中
    AppState.LocalViewRadius = newRadius;
    
    % 2. 检查：如果当前“局部地图”模式本身就是开启状态，则立刻触发重绘，实现丝滑的动态放大/缩小
    if isfield(AppState, 'LocalViewActive') && AppState.LocalViewActive
        updateMapDisplay();
    end
end