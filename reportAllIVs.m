function reportAllIVs()
    global AppState;
    if isempty(AppState.IVs), logMsg('当前没有加载任何车辆'); return; end
    str = '--- 已加载车辆列表 ---';
    for i = 1:length(AppState.IVs)
        str = sprintf('%s\nIV[%d]: (%.1f,%.1f)米  朝向%0.2f°', str, i, AppState.IVs(i).X, AppState.IVs(i).Y, AppState.IVs(i).Heading);
    end
    logMsg(str);
    updateIVDropdown();
end
