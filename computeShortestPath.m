function computeShortestPath(hFig)
    global AppState;
    AppState.PathPixels = [];
    AppState.ShortestPath = [];
    if isempty(AppState.StartPoint) || isempty(AppState.EndPoint)
        return;
    end
    if AppState.StartPoint(1) == AppState.EndPoint(1) && AppState.StartPoint(2) == AppState.EndPoint(2)
        uialert(hFig, '起点和终点重合！请重新开启并选择不同的位置。', '导航提示');
        AppState.hPathStatusLabel.Text = '路径状态：起终点重合';
        return;
    end
    
    AppState.hPathStatusLabel.Text = '正在使用 BFS 算法寻找最短路径...';
    drawnow;
    
    [H_mask, W_mask, ~] = size(AppState.MapImg);
    
    if isfield(AppState, 'skelMask') && ~isempty(AppState.skelMask) && any(AppState.skelMask(:))
        localRoadMatrix = AppState.skelMask; 
        logMsg(' BFS导航优化：已直接锁定在亮蓝色手动提取区域内进行纯净寻路。');
    else
        localRoadMatrix = true(H_mask, W_mask);
        logMsg('警告：未发现亮蓝色道路域，已切换至全图保底寻路。');
    end
    
    localRoadMatrix = imclose(localRoadMatrix, uint8(ones(3,3)));
    
    path = bfsOnMaskCore(localRoadMatrix, ...
                         AppState.StartPoint(1), AppState.StartPoint(2), ...
                         AppState.EndPoint(1), AppState.EndPoint(2));
                     
    if isempty(path)
        uialert(hFig, '未能找到连通路径！起终点可能超出了提取道路的范围或处于断开区域。', '规划失败', 'Icon', 'warning');
        AppState.PlannedPath = [];
        AppState.hPathStatusLabel.Text = '路径状态：无法连通！';
        updateMapDisplay();
        return;
    end
    
    % 存储寻路结果供 updateMapDisplay 渲染红线
    AppState.PlannedPath = path;
    
    % 换算真实物
    totalDist = 0;
    for i = 1:size(path,1)-1
        X1 = path(i,1) * 1.7;    Y1 = (H_mask - path(i,2)) * 1.7;
        X2 = path(i+1,1) * 1.7;  Y2 = (H_mask - path(i+1,2)) * 1.7;
        totalDist = totalDist + sqrt((X2-X1)^2 + (Y2-Y1)^2);
    end
    
    AppState.hPathStatusLabel.Text = sprintf('完成！全长：%.1f 米', totalDist);
    logMsg(sprintf('BFS 最短路径自动规划成功！实际物理距离：%.2f 米', totalDist));
    
    % 刷新地图层展现结果
    updateMapDisplay();
end