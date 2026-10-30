function rotateMapAction(targetDegree)
    global AppState;
    if isempty(AppState), return; end 
    AppState.RotAngle = targetDegree;
    AppState.DisplayImg = manualRotateImage(AppState.MapImg, targetDegree);
        updateMapDisplay();
end