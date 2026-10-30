function handleNavButtonCallback(targetMode)
    global AppState;
    
    currentTime = datetime('now');
    timeDiff = seconds(currentTime - AppState.LastBtnClickTime);
    AppState.LastBtnClickTime = currentTime; 
    
    if timeDiff < 0.4
        AppState.NavPoints = [];
        [H, W, ~] = size(AppState.MapImg);
        AppState.skelMask = false(H, W); 
        AppState.PlannedPath = [];
        AppState.StartPoint = [];
        AppState.EndPoint = [];
        AppState.CurrentMode = 'NONE';
        
        resetAllButtons();
        AppState.hPathStatusLabel.Text = '系统状态：道路提取已完全撤销';
        logMsg('撤销成功！已清空当前提取的全部半透明蓝色道路和导航线，恢复初始彩色状态。');
        updateMapDisplay();
    else
        toggleMode(targetMode);
    end
end