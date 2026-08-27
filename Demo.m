clc;clear;close all
%% This is a demo of a multi-phase winding analysis tool.
fprintf('===  This is a demo of a multi-phase winding analysis tool.  ===\n');
fprintf('===  1. 4-poles, 24-slots, double-layer, three-phase full-pitch winding. ===\n');
fprintf('===  2. 4-poles, 24-slots, double-layer, three-phase short-pitch winding. ===\n');
fprintf('===  3. 4-poles, 24-slots, single-layer, three-phase full-pitch winding. ===\n');
fprintf('===  4. 4-poles, 24-slots, double-layer, double-three-phase full-pitch winding. ===\n');
fprintf('===  5. 4-poles, 27-slots, double-layer, three-phase short-pitch winding. ===\n');
fprintf('===  6. 10-poles, 12-slots, double-layer, three-phase winding. ===\n');
fprintf('===  7. 4-poles, 20-slots, double-layer, five-phase short-pitch winding. ===\n');
Choice = input('Please input: \n');
switch Choice
    case 1
        Choice1 = MPhWindAna;
        Choice1.KdpwPlot
        Choice1.MMFPlot
        Choice1.MMFHarPlot
        Choice1.WindingPlot
        Choice1.SlotVectorPlot
        Choice1.exportWindingData
    case 2
        Choice2 = MPhWindAna;
        Choice2.WinP = 5;
        Choice2.KdpwPlot
        Choice2.MMFPlot
        Choice2.MMFHarPlot
        Choice2.WindingPlot
        Choice2.SlotVectorPlot
        Choice2.exportWindingData
   case 3
        Choice3 = MPhWindAna;
        Choice3.NoWL = 1;
        Choice3.KdpwPlot
        Choice3.MMFPlot
        Choice3.MMFHarPlot
        Choice3.WindingPlot
        Choice3.SlotVectorPlot
        Choice3.exportWindingData
    case 4
        Choice4 = MPhWindAna;
        Choice4.NoWS = 2;
        Choice4.KdpwPlot
        Choice4.MMFPlot
        Choice4.MMFHarPlot
        Choice4.WindingPlot
        Choice4.SlotVectorPlot
        Choice4.exportWindingData
   case 5
        Choice5 = MPhWindAna;
        Choice5.NoS = 27;
        Choice5.WinP = 6;
        Choice5.KdpwPlot
        Choice5.MMFPlot
        Choice5.MMFHarPlot
        Choice5.WindingPlot
        Choice5.SlotVectorPlot
        Choice5.exportWindingData
   case 6
        Choice6 = MPhWindAna;
        Choice6.NoS = 12;
        Choice6.NoPs = 10;
        Choice6.KdpwPlot
        Choice6.MMFPlot
        Choice6.MMFHarPlot
        Choice6.WindingPlot
        Choice6.SlotVectorPlot
        Choice6.exportWindingData
    case 7
        Choice7 = MPhWindAna;
        Choice7.NoS = 20;
        Choice7.NoPhPWS = 5;
        Choice7.WinP = 4;
        Choice7.KdpwPlot
        Choice7.MMFPlot
        Choice7.MMFHarPlot
        Choice7.WindingPlot
        Choice7.SlotVectorPlot
        Choice7.exportWindingData
    otherwise
    warning('Unknown case %d.',Choice);
end