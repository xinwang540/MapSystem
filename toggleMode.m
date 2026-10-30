function toggleMode(targetMode)
global AppState;
if isempty(AppState), return; end

activeColor = [0.46, 0.93, 0.78];
defaultColor = [0.96, 0.96, 0.96];

if strcmp(AppState.CurrentMode, targetMode)
    if strcmp(targetMode, 'ROAD_GUIDE_MODE')
        AppState.NavPoints = [];
        AppState.LastRoadPt = [];
        AppState.MaskHistory = {};
    end

    AppState.CurrentMode = 'NONE';
    AppState.TempPoints = [];
    if isfield(AppState, 'NavClickCount'), AppState.NavClickCount = 0; end

    setAllButtonsColor(defaultColor);

    logMsg('空闲状态');
    if isfield(AppState, 'hPathStatusLabel') && isvalid(AppState.hPathStatusLabel)
        AppState.hPathStatusLabel.Text = '空闲';
    end
    updateMapDisplay();
    return;
end

if strcmp(targetMode, 'ROAD_GUIDE_MODE')
    AppState.NavPoints = [];
    AppState.OrigNavPoints = [];
    AppState.LastRoadPt = [];
    AppState.MaskHistory = {};
else
    AppState.NavPoints = [];
    AppState.LastRoadPt = [];
    AppState.MaskHistory = {};
end

AppState.CurrentMode = targetMode;
AppState.TempPoints = [];
if isfield(AppState, 'NavClickCount'), AppState.NavClickCount = 0; end

% 初始化
switch targetMode
    case 'ROAD_GUIDE_MODE'
        if ~isfield(AppState, 'skelMask') || isempty(AppState.skelMask)
            [H, W, ~] = size(AppState.MapImg);
            AppState.skelMask = false(H, W);
        end
        if isfield(AppState, 'hPathStatusLabel') && isvalid(AppState.hPathStatusLabel)
            AppState.hPathStatusLabel.Text = '系统状态：正在提取连线道路...';
        end
        logMsg(['【道路骨架提取】点第1个点，再点第2个点进行连线拓宽。' '错点时直接在屏幕非道路区域上进行鼠标双击撤销！']);

    case 'NAV_MODE'
        if isfield(AppState, 'hPathStatusLabel') && isvalid(AppState.hPathStatusLabel)
            AppState.hPathStatusLabel.Text = '系统状态：准备路径规划...';
        end
        logMsg('【最短路径规划】请依次点击提取出来的亮蓝色连线车道内的 [起点] 和 [终点]');

    case 'STREET_VIEW_MODE'
        if isfield(AppState, 'hPathStatusLabel') && isvalid(AppState.hPathStatusLabel)
            AppState.hPathStatusLabel.Text = '系统状态：点击地图生成虚拟街景...';
        end
        logMsg('【虚拟街景模式】请点击地图上的有效道路生成该位置的街景视角');

    otherwise
        logMsg(['已切换进入模式: ', targetMode]);
end

setAllButtonsColor(defaultColor);

switch targetMode
    case 'ROAD_GUIDE_MODE'
        if abusesCheck('hBtnNavMain'), AppState.hBtnNavMain.BackgroundColor = activeColor; end
    case 'NAV_MODE'
        if abusesCheck('hBtnFindPath'), AppState.hBtnFindPath.BackgroundColor = activeColor; end
    case 'ADD_IV'
        if abusesCheck('hBtnAdd'), AppState.hBtnAdd.BackgroundColor = activeColor; end
    case 'REMOVE_IV'
        if abusesCheck('hBtnRemove'), AppState.hBtnRemove.BackgroundColor = activeColor; end
    case 'DISTANCE'
        if abusesCheck('hBtnDist'), AppState.hBtnDist.BackgroundColor = activeColor; end
    case 'TRAJECTORY'
        if abusesCheck('hBtnTraj'), AppState.hBtnTraj.BackgroundColor = activeColor; end
    case 'STREET_VIEW_MODE'
        if abusesCheck('hBtnStreet'), AppState.hBtnStreet.BackgroundColor = activeColor; end
end


updateMapDisplay();
end

function setAllButtonsColor(colorRGB)
global AppState;
if abusesCheck('hBtnNavMain'),  AppState.hBtnNavMain.BackgroundColor = colorRGB; end
if abusesCheck('hBtnFindPath'), AppState.hBtnFindPath.BackgroundColor = colorRGB; end
if abusesCheck('hBtnAdd'),      AppState.hBtnAdd.BackgroundColor = colorRGB; end
if abusesCheck('hBtnRemove'),   AppState.hBtnRemove.BackgroundColor = colorRGB; end
if abusesCheck('hBtnDist'),     AppState.hBtnDist.BackgroundColor = colorRGB; end
if abusesCheck('hBtnTraj'),     AppState.hBtnTraj.BackgroundColor = colorRGB; end
if abusesCheck('hBtnStreet'),   AppState.hBtnStreet.BackgroundColor = colorRGB; end
end


function tf = abusesCheck(fieldName)
global AppState;
tf = isfield(AppState, fieldName) && ~isempty(AppState.(fieldName)) && isvalid(AppState.(fieldName));
end