classdef atlasShapeBbox < atlasShape
    
    properties (Hidden)
        bbox
    end
    methods
        
        function d = getData(self)
            d = self.bbox;
        end
        
        function self = atlasShapeBbox(varargin)
            self = cvrAssignStringValuePairs(self, varargin{:});
        end
        
        function [x, y] = toPoly(self)
            
            b = self.bbox;
            x = b(1) + b(3)*[0 0 1 1 0];
            y = b(2) + b(4)*[0 1 1 0 0 ];
        end
    end
end