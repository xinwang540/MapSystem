   function applyScale(scale)
        global AppState;
        if isnan(scale), scale = 1.0; end
        AppState.IVScale = max(0.2, min(5.0, scale));
        logMsg(sprintf('车辆缩放因子已设为 %.2f', AppState.IVScale));
        updateMapDisplay();
    end
    