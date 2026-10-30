function [X, Y] = pixelToReal(c, r)
    X = c * 1.7;
    Y = (803 - r) * 1.7;
end
