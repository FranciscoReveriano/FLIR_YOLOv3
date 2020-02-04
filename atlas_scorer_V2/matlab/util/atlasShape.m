classdef atlasShape < matlab.mixin.Heterogeneous
    % atlasShape
    %   A super class for all atlasShape objects. See, e.g., atlasShapeBbox
    %   
    properties (Dependent)
        type
        data
    end
    
    methods
        function t = get.type(self)
            switch class(self)
                case 'atlasShapeBbox'
                    t = 'bbox_xywh';
            end
        end
        function d = get.data(self)
            d = self.getData();
        end
        function d = getData(self) %#ok<STOUT,MANU>
            error('getData() was not implemented for this sub-class of atlasShape');
        end
        function [x, y] = toPoly(self) %#ok<STOUT,MANU>
            error('toPoly() was not implemented for this sub-class of atlasShape');
        end
        
        function [tx, ty] = getTextLocation(self)
            [px, py] = self.toPoly();
            locs = unique([px(:), py(:)],'rows');
            tx = mean(locs(:,1));
            ty = min(locs(:,2));
        end
    end
        
    methods
        function lineHandles = plot(self)
            
            lineHandles = gobjects(numel(self), 1);
            for i = 1:numel(self)
                [x, y] = self(i).toPoly();
                lineHandles(i) = plot(x, y);
            end
        end
        
        function textHandles = text(self, string, varargin)
            
            textHandles = gobjects(numel(self), 1);
            for i = 1:numel(self)
                [tx, ty] = self.getTextLocation();
                textHandles = text(tx, ty, string, ...
                    'HorizontalAlignment', 'Center', ...
                    'VerticalAlignment', 'Bottom');
            end
        end
    end
    
    methods (Static)
        function self = fromStruct(aStruct)
            self = repmat(atlasShape, length(aStruct), 1);
            for i = 1:length(aStruct)
                switch aStruct.type
                    case 'bbox_xywh'
                        self(i) = atlasShapeBbox('bbox', aStruct.data);
                    otherwise
                        error('Unknown shape type: %s', aStruct.type);
                end
            end
        end
        
        function bboxes = structToBbox(shapeStruct)
            
            bboxes = nan(numel(shapeStruct), 4);
            for i = 1:numel(shapeStruct)
                switch shapeStruct(i).type
                    case 'bbox_xywh'
                        bboxes(i,:) = shapeStruct(i).data;
                    case ''
                        bboxes(i,:) = nan(1, 4);
                    otherwise
                        error('Not implemented for non bbox_xywh shapes');
                end
            end
        end
    end
end