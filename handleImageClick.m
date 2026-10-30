function handleImageClick(~, hitEvent)
global AppState;
hFig = AppState.hAx.Parent;


if ~isfield(AppState, 'NavClickCount') || isempty(AppState.NavClickCount), AppState.NavClickCount = 0; end
if ~isfield(AppState, 'StartPoint'), AppState.StartPoint = []; end
if ~isfield(AppState, 'EndPoint'), AppState.EndPoint = []; end
if ~isfield(AppState, 'LocalViewActive'), AppState.LocalViewActive = false; end
if ~isfield(AppState, 'ViewOnlyRoads'), AppState.ViewOnlyRoads = false; end
if ~isfield(AppState, 'skelMask')
    [H_tmp, W_tmp, ~] = size(AppState.MapImg); AppState.skelMask = false(H_tmp, W_tmp);
end


if strcmp(hFig.SelectionType, 'open')
    if isfield(AppState, 'MaskHistory') && ~isempty(AppState.MaskHistory)
        AppState.skelMask = AppState.MaskHistory{end};
        AppState.MaskHistory(end) = [];
        if size(AppState.NavPoints, 1) > 1
            AppState.NavPoints(end, :) = [];
            AppState.LastRoadPt = AppState.NavPoints(end, :);
        else
            AppState.NavPoints = []; AppState.LastRoadPt = [];
        end
        logMsg('已成功撤销上一段线段提取');
        updateMapDisplay();
    else
        logMsg('️历史记录为空，无法撤销！');
    end
    return;
end
%%
clickPt = hitEvent.IntersectionPoint;
c_view = clickPt(1); r_view = clickPt(2);

if AppState.LocalViewActive
    rect = AppState.LocalViewCropRect;
    if ~isempty(rect)
        c_view = rect(2) + c_view - 1;
        r_view = rect(1) + r_view - 1;
    end
end

currentAngle = 0;
if isfield(AppState, 'RotAngle'), currentAngle = AppState.RotAngle; end
if currentAngle ~= 0
    [c, r] = projectToRotatedView(c_view, r_view, -currentAngle);
else
    c = c_view; r = r_view;
end

[H, W, ~] = size(AppState.MapImg);
c = max(1, min(W, round(c)));
r = max(1, min(H, round(r)));
[X_real, Y_real] = pixelToReal(c, r);


switch AppState.CurrentMode
    case 'ROAD_GUIDE_MODE'
        if ~checkRoadValidity(c,r)
            logMsg('点击位置非有效道路区域！');
            return;
        end

        if isempty(AppState.LastRoadPt)
            AppState.LastRoadPt = [c,r];
            AppState.NavPoints = [c,r];
            AppState.skelMask(r,c) = true;
            logMsg(' 提取道路中...');
            updateMapDisplay();
            return;
        end

        if ~isfield(AppState,'MaskHistory')
            AppState.MaskHistory = {}; 
        end
        oldMask = AppState.skelMask;
        stPt = AppState.LastRoadPt;
        edPt = [c,r];

        dx = edPt(1)-stPt(1); dy = edPt(2)-stPt(2);
        distPx = max(abs(dx),abs(dy));
        if distPx < 2, return; end

        numSteps = max(20,round(distPx*2));
        lineC = round(linspace(stPt(1),edPt(1),numSteps));
        lineR = round(linspace(stPt(2),edPt(2),numSteps));
        seedMask = false(H,W);

        %检查路径上的点
        for i = 1:numSteps
            cx = lineC(i); cy = lineR(i);
            if cx<1 || cx>W || cy<1 || cy>H, continue; end
            if checkRoadValidity(cx,cy)
                AppState.skelMask(cy,cx) = true;
                seedMask(cy,cx) = true;
            end
        end

        %BFS遍历合规像素点
        maxGrowRadius = 25;
        Qx = zeros(H*W,1); Qy = zeros(H*W,1);
        head = 1; tail = 0;
        visited = false(H,W);
        [sr,sc] = find(seedMask);
        for k = 1:length(sr)
            tail = tail + 1; Qx(tail) = sc(k); Qy(tail) = sr(k);
            visited(sr(k),sc(k)) = true;
        end

        while head <= tail
            cx = Qx(head); cy = Qy(head); head = head + 1;
            AppState.skelMask(cy,cx) = true;
            for dr = -1:1
                for dc = -1:1
                    if dr==0 && dc==0, continue; end
                    nx = cx + dc; ny = cy + dr;
                    if nx<1 || nx>W || ny<1 || ny>H, continue; end
                    if visited(ny,nx), continue; end
                    minDist = inf;
                    for t = 1:numSteps
                        d = (nx-lineC(t))^2 + (ny-lineR(t))^2;
                        if d < minDist, minDist = d; end
                    end
                    if sqrt(minDist) > maxGrowRadius, continue; end
                    if ~checkRoadValidity(nx,ny), continue; end
                    visited(ny,nx) = true;
                    tail = tail + 1; Qx(tail) = nx; Qy(tail) = ny;
                end
            end
        end

        AppState.MaskHistory{end+1} = oldMask;
        AppState.NavPoints = [AppState.NavPoints; c,r];
        AppState.LastRoadPt = edPt;
        logMsg('提取道路中...');
        updateMapDisplay();

        %路径规划
    case 'NAV_MODE'
        if ~isfield(AppState, 'skelMask') || isempty(AppState.skelMask) || ~any(AppState.skelMask(:))
            uialert(hFig, '导航失败：请先完成至少一段道路提取！', '导航无效');
            return;
        end
        if ~AppState.skelMask(r,c)
            uialert(hFig, '导航点必须位于已提取的道路网络内！', '落点非法');
            return;
        end
        
        if AppState.NavClickCount == 0
            AppState.StartPoint = [c, r];
            AppState.EndPoint = [];       
            AppState.PlannedPath = [];    
            AppState.NavClickCount = 1;   
            logMsg(sprintf(' 新起点已重置定点 (%d,%d)，请选择终点...', c, r));
        else
            AppState.EndPoint = [c, r];
            AppState.NavClickCount = 0;   
            
            logMsg(sprintf(' 终点已选定 (%d,%d)，正在计算路径...', c, r));
            computeShortestPath(hFig);
        end
        
        updateMapDisplay();
        %% 投放与删除车辆
    case 'ADD_IV'
        if ~isfield(AppState,'skelMask') || isempty(AppState.skelMask) || ~any(AppState.skelMask(:))
            uialert(hFig, '请先完成道路提取后再投放车辆！', '道路不存在');
            return; 
        end
        if ~AppState.skelMask(r,c)
            uialert(hFig, '车辆必须放置在已提取的道路网络中！', '落点错误');
            return;
        end
        
        autoHeading = casedRoadHeading(c, r);
        if isfield(AppState, 'hAngleEdit') && isvalid(AppState.hAngleEdit)
            AppState.hAngleEdit.Value = round(autoHeading, 1);
        end
        
        newIV = struct('X', X_real, 'Y', Y_real, 'pixC', c, 'pixR', r, 'Heading', autoHeading);
        AppState.IVs = [AppState.IVs; newIV];
        
        AppState.OrigIVPositions = [[AppState.IVs.X]', [AppState.IVs.Y]'];
        logMsg('车辆投放成功.');
        updateIVDropdown();
        reportAllIVs();
        updateMapDisplay();
        updateMapDisplay();

    case 'REMOVE_IV'
        if ~isempty(AppState.IVs)

            posMat = [[AppState.IVs.X]', [AppState.IVs.Y]'];
            distsSq = sum((posMat - [X_real, Y_real]).^2, 2);
            dists = sqrt(distsSq);
            [minD, minIdx] = min(dists);

            if minD < 50
                AppState.IVs(minIdx) = [];
                if ~isempty(AppState.IVs)
                    AppState.OrigIVPositions = [[AppState.IVs.X]', [AppState.IVs.Y]'];
                else
                    AppState.OrigIVPositions = [];
                end
                logMsg(' 已删除目标车辆 ');
                updateIVDropdown(); 
                reportAllIVs(); 
                updateMapDisplay();
            else
                logMsg('未在点击位置附近找到车辆。');
            end
        end





        %% 两点测距
    case 'DISTANCE'

        AppState.TempPoints = [AppState.TempPoints; X_real, Y_real];
        updateMapDisplay();

        if size(AppState.TempPoints, 1) == 2
            p1 = AppState.TempPoints(1,:);
            p2 = AppState.TempPoints(2,:);
            D = sqrt(sum((p2 - p1).^2));

            logMsg(sprintf('\n起点: (%.1f米, %.1f米)\n终点: (%.1f米, %.1f米)\n两点距离 %.2f 米', p1(1), p1(2), p2(1), p2(2), D));

            AppState.TempPoints = [];
            AppState.CurrentMode = 'NONE';
        end

        % 连续轨迹长度
    case 'TRAJECTORY'
        AppState.TempPoints = [AppState.TempPoints; X_real, Y_real];
        updateMapDisplay();
        if size(AppState.TempPoints, 1) > 1
            L = 0;
            for i = 1:size(AppState.TempPoints, 1) - 1
                L = L + sqrt(sum((AppState.TempPoints(i+1,:) - AppState.TempPoints(i,:)).^2));
            end
            logMsg(sprintf('当前轨迹点数: %d 个\n累计总长度: %.2f 米\n', size(AppState.TempPoints, 1), L));
        else
            logMsg('已记录轨迹起点，请继续点击地图添加下一个漫游点...');
        end
    case 'STREET_VIEW_MODE'
        if ~checkRoadValidity(c, r)
            logMsg('点击位置非有效道路，无法生成街景！');
            return;
        end
        camHeading = casedRoadHeading(c, r);
        logMsg(sprintf('正在生成坐标 (%d, %d) 方向 %.1f° 的虚拟街景...', c, r, camHeading));
        
        generateVirtualStreetView(c, r, camHeading);

    otherwise
        logMsg(sprintf('坐标: [X=%.1f m, Y=%.1f m]', c, r, X_real, Y_real));
end


end

function tf = knotCheck(funcName)
tf = ~isempty(which(funcName));
end