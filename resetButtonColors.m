function resetButtonColors()
    global AppState;
    set(AppState.hBtnAdd, 'BackgroundColor', AppState.btnColors.default);
    set(AppState.hBtnRemove, 'BackgroundColor', AppState.btnColors.default);
    set(AppState.hBtnDist, 'BackgroundColor', AppState.btnColors.default);
    set(AppState.hBtnTraj, 'BackgroundColor', AppState.btnColors.default);
    if isfield(AppState, 'hBtnNavMain')
        set(AppState.hBtnNavMain, 'BackgroundColor', [0.9 1.0 0.9]); 
    end
end