function path = bfsOnMaskCore(mask, sx, sy, gx, gy)
    [H, W] = size(mask); 
    if sx < 1 || sx > W || sy < 1 || sy > H || gx < 1 || gx > W || gy < 1 || gy > H
        path = []; return; 
    end
    mask(sy, sx) = true; mask(gy, gx) = true;
    
    visited = false(H, W); 
    prev = cell(H, W); 
    queue = [sx, sy]; 
    visited(sy, sx) = true;
    
    dirs = [-1,0; 1,0; 0,-1; 0,1; -1,-1; -1,1; 1,-1; 1,1]; 
    found = false;
    
    while ~isempty(queue)
        curr = queue(1,:); queue(1,:) = []; 
        cx = curr(1); cy = curr(2);
        if cx == gx && cy == gy, found = true; break; end
        for d = 1:8
            nx = cx + dirs(d,1); ny = cy + dirs(d,2);
            if nx>=1 && nx<=W && ny>=1 && ny<=H && ~visited(ny,nx) && mask(ny,nx)
                visited(ny,nx) = true; 
                prev{ny,nx} = [cx,cy]; 
                queue = [queue; nx,ny];
            end
        end
    end
    if ~found, path = []; return; end
    path = [gx, gy]; curr = [gx, gy];
    while ~(curr(1)==sx && curr(2)==sy)
        curr = prev{curr(2), curr(1)}; 
        if isempty(curr), break; end
        path = [curr; path];
    end
end