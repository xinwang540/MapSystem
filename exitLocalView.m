  function exitLocalView()
        global AppState;
        if ~AppState.LocalViewActive, logMsg('当前不在局部视图模式'); return; end
        AppState.LocalViewActive = false;
        AppState.LocalViewCenterIV = [];
        AppState.LocalViewCropRect = [];
        if exist('rotateMapAction', 'file')
            rotateMapAction(AppState.RotAngle);
        else
            updateMapDisplay();
        end
        logMsg('已退出局部视图模式');
    end