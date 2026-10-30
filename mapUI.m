function mapUI()
clear global AppState;
clear; clc; close all;
global AppState;


AppState = struct();

AppState.MapImg = imread('MapForUI.jpg');
AppState.DisplayImg = AppState.MapImg;

[H, W, ~] = size(AppState.MapImg);

AppState.CurrentMode = 'NONE';
AppState.TempPoints = [];

AppState.RotAngle = 0;
AppState.IVScale = 1.0;

AppState.LocalViewActive = false;
AppState.LocalViewCenterIV = [];
AppState.LocalViewRadius = 50;
AppState.LocalViewCropRect = [];

AppState.NavPoints = [];
AppState.StartPoint = [];
AppState.EndPoint = [];
AppState.PlannedPath = [];


AppState.skelMask = false(H, W);
AppState.MaskHistory = {};
AppState.LastRoadPt = [];

AppState.IVs = [];
AppState.ViewOnlyRoads = false;  


% 窗口建立
screenSize = get(0, 'ScreenSize');
scrW = screenSize(3); scrH = screenSize(4);
figW = min(1300, scrW - 100); figH = min(850, scrH - 120);
figX = (scrW - figW) / 2; figY = (scrH - figH) / 2;

hFig = uifigure('Name', '地图系统', 'Position', [figX, figY, figW, figH]);

hAx = uiaxes(hFig, 'Position', [30, 30, figW - 350, figH - 60]);
AppState.hAx = hAx;
hPanel = uipanel(hFig, 'Title', '控制台', 'Position', [figW - 300, 30, 270, figH - 60]);

%% 控制台组件
yCursor = figH - 120;
uilabel(hPanel, 'Position', [20, yCursor+15, 230, 22], ...
    'Text', ' 系统正方向：', 'FontWeight', 'bold', 'FontColor', [0.1 0.4 0.7]);
uilabel(hPanel, 'Position', [20, yCursor, 230, 22], ...
    'Text', '0° 为正右方向 (X轴)', 'FontSize', 10, 'FontColor', [0.5 0.5 0.6]);
uilabel(hPanel, 'Position', [20, yCursor-15, 230, 22], ...
    'Text', '90° 为正上方向 (Y轴)', 'FontSize', 10, 'FontColor', [0.5 0.5 0.5]);
yCursor = yCursor - 60;
%道路提取与核心导航
AppState.hBtnNavMain = uibutton(hPanel, 'Text', '提取道路', 'Position', [20, yCursor, 110, 35], ...
    'ButtonPushedFcn', @(btn,~) toggleMode('ROAD_GUIDE_MODE'));

uibutton(hPanel, 'Text', '查看道路', 'Position', [140, yCursor, 110, 35], ...
    'BackgroundColor', [0.95 0.95 0.95], 'ButtonPushedFcn', @(btn,~) toggleViewOnlyRoads());

yCursor = yCursor - 30;
AppState.hPathStatusLabel = uilabel(hPanel, 'Position', [20, yCursor, 230, 22], ...
    'Text', '系统状态：空闲', 'FontColor', [0.4 0.4 0.4], 'FontWeight', 'bold');

yCursor = yCursor - 55;
AppState.hBtnFindPath = uibutton(hPanel, 'Text', '规划路径', 'Position', [20, yCursor, 230, 45], ...
    'ButtonPushedFcn', @(btn,~) toggleMode('NAV_MODE'));

% 测量与轨迹工具
yCursor = yCursor - 55;
AppState.hBtnDist = uibutton(hPanel, 'Text', '两点测距', 'Position', [20, yCursor, 110, 40], ...
    'ButtonPushedFcn', @(btn,~) toggleMode('DISTANCE'));
AppState.hBtnTraj = uibutton(hPanel, 'Text', '轨迹长度', 'Position', [140, yCursor, 110, 40], ...
    'ButtonPushedFcn', @(btn,~) toggleMode('TRAJECTORY'));

% 车辆管理
yCursor = yCursor - 70;
AppState.hBtnAdd = uibutton(hPanel, 'Text', '加载车辆', 'Position', [20, yCursor, 110, 35], ...
    'ButtonPushedFcn', @(btn,~) toggleMode('ADD_IV'));
AppState.hBtnRemove = uibutton(hPanel, 'Text', '删除车辆', 'Position', [140, yCursor, 110, 35], ...
    'ButtonPushedFcn', @(btn,~) toggleMode('REMOVE_IV'));

yCursor = yCursor - 35;
uilabel(hPanel, 'Position', [20, yCursor, 70, 22], 'Text', '选择车辆:');
hIVSelect = uidropdown(hPanel, 'Position', [90, yCursor, 160, 22], ...
    'Items', {'无车辆'}, 'ItemsData', {0}, 'Value', 0);
hIVSelect.ValueChangedFcn = @(src, event) handleIVMenuChange(src);
AppState.hIVSelect = hIVSelect;

% 车辆朝向 旋转车辆按钮
yCursor = yCursor - 35;
uilabel(hPanel, 'Position', [20, yCursor, 65, 22], 'Text', '车辆朝向:');
hAngleEdit = uieditfield(hPanel, 'numeric', 'Position', [90, yCursor, 70, 22], 'Value', 0, 'Limits', [-360, 360]);
hAngleEdit.ValueDisplayFormat = '%0.2f';
AppState.hAngleEdit = hAngleEdit;
uibutton(hPanel, 'Text', '旋转车辆', 'Position', [170, yCursor, 80, 22], 'ButtonPushedFcn', @(btn,~) applyVehicleRotation());

% 局部地图 
yCursor = yCursor - 35;
uilabel(hPanel, 'Position', [20, yCursor, 75, 22], 'Text', '局部半径(m):');
hRadiusEdit = uieditfield(hPanel, 'numeric', 'Position', [95, yCursor, 45, 22], 'Value', 50, 'Limits', [10, 300]);
AppState.hRadiusEdit = hRadiusEdit;
hRadiusEdit.ValueChangedFcn = @(src, event) updateLocalViewRadius(src.Value);
uibutton(hPanel, 'Text', '局部地图', 'Position', [150, yCursor, 55, 22], 'FontSize', 10, 'ButtonPushedFcn', @(btn,~) showLocalView());
uibutton(hPanel, 'Text', '退出', 'Position', [210, yCursor, 40, 22], 'FontSize', 10, 'ButtonPushedFcn', @(btn,~) exitLocalView());

% 车缩放
yCursor = yCursor - 35;
uilabel(hPanel, 'Position', [20, yCursor, 65, 22], 'Text', '车辆缩放:');
hScaleEdit = uieditfield(hPanel, 'numeric', 'Position', [90, yCursor, 50, 22], 'Value', 1.0, 'Limits', [0.2, 5.0]);
uibutton(hPanel, 'Text', '应用缩放', 'Position', [150, yCursor, 100, 22], 'ButtonPushedFcn', @(btn,~) applyScale(hScaleEdit.Value));

% 地图旋转
yCursor = yCursor - 55;
uilabel(hPanel, 'Position', [20, yCursor, 70, 22], 'Text', '地图旋转:');
hRotSlider = uislider(hPanel, 'Position', [90, yCursor+10, 110, 3], 'Limits', [-180, 180], 'Value', 0);
AppState.hRotSlider = hRotSlider;
hRotEdit = uieditfield(hPanel, 'numeric', 'Position', [210, yCursor, 45, 22], 'Value', 0, 'Limits', [-180, 180]);
AppState.hRotEdit = hRotEdit;

hRotSlider.ValueChangingFcn = @(src, event) setEditValueDirectly(event.Value);
hRotSlider.ValueChangedFcn  = @(src, event) updateRotationFromSlider(src.Value);
hRotEdit.ValueChangedFcn    = @(src, event) updateRotationFromEdit(src.Value);

% 街景与状态区
yCursor = yCursor - 60;
uibutton(hPanel, 'Text', '生成街景', 'Position', [20, yCursor, 110, 30], 'ButtonPushedFcn', @(btn,~) toggleMode('STREET_VIEW_MODE'));
uibutton(hPanel, 'Text', '关闭街景', 'Position', [140, yCursor, 110, 30], ...
    'ButtonPushedFcn', @(btn,~) closeStreetViewWindow());

yCursor = yCursor - 40;
uibutton(hPanel, 'Text', '报告所有IV位置', 'Position', [20, yCursor, 230, 30], 'ButtonPushedFcn', @(btn,~) reportAllIVs());

yCursor = yCursor - 135;
uilabel(hPanel, 'Position', [20, yCursor+115, 100, 22], 'Text', '实时状态:');
hReport = uitextarea(hPanel, 'Position', [20, yCursor, 230, 115], 'Editable', 'off');
AppState.hReport = hReport;

% 建立初始状态
toggleMode('NONE');
updateMapDisplay();
logMsg('系统就绪');
end



function setEditValueDirectly(changingVal)
global AppState;
if isfield(AppState, 'hRotEdit') && isvalid(AppState.hRotEdit)
    AppState.hRotEdit.Value = round(changingVal, 1);
end

end
%滑块旋转
function updateRotationFromSlider(currentVal)
global AppState;
currentVal = round(currentVal, 1);
if isfield(AppState, 'hRotEdit') && isvalid(AppState.hRotEdit)
    AppState.hRotEdit.Value = currentVal;
end
if knotCheck('rotateMapAction')
    rotateMapAction(currentVal);
else
    AppState.RotAngle = currentVal;
    updateMapDisplay();
end
end
%文本框旋转
function updateRotationFromEdit(currentVal)
global AppState;
if isfield(AppState, 'hRotSlider') && isvalid(AppState.hRotSlider)
    AppState.hRotSlider.Value = currentVal;
end
if knotCheck('rotateMapAction')
    rotateMapAction(currentVal);
else
    AppState.RotAngle = currentVal;
    updateMapDisplay();
end
end

function tf = knotCheck(funcName)
tf = ~isempty(which(funcName));
end


