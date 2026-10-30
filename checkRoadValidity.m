function out = checkRoadValidity(c, r)
    global AppState;
    [H, W, ~] = size(AppState.MapImg);
    
    if c < 1 || c > W || r < 1 || r > H, out = false; return; end
    
  
    radius = 1; 
    
    validVotes = 0; 
    totalVotes = 0; 
    
    for dr = -radius : radius
        for dc = -radius : radius
            neighborC = c + dc;
            neighborR = r + dr;
            
            if neighborC >= 1 && neighborC <= W && neighborR >= 1 && neighborR <= H
                totalVotes = totalVotes + 1;
                
                R_val = double(AppState.MapImg(neighborR, neighborC, 1));
                G_val = double(AppState.MapImg(neighborR, neighborC, 2));
                B_val = double(AppState.MapImg(neighborR, neighborC, 3));
                
                brightness = (R_val + G_val + B_val) / 3;
                
                if (brightness > 190 && brightness < 230 && abs(R_val - G_val) < 32 && abs(G_val - B_val) < 32)
                    validVotes = validVotes + 1; 
                end
            end
        end
    end
   
    out = (validVotes / totalVotes) >= 0.22;
    
end