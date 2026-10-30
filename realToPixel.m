function [c, r] = realToPixel(X, Y)
    c = round(X / 1.7);
    r = round(803 - Y / 1.7);
end
