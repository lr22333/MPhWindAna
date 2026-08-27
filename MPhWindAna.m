classdef MPhWindAna < handle
%% Multi-Phase Winding Analysis Tool.
%  The variables used in this paper follow an abbreviated naming style.
properties
    Fre           % Fundamental frequency (Hz).
    NoPhPWS       % Number of phases per winding set.
    NoPP          % Number of pole pairs (P).
    NoS           % Number of slots (Zs).
    NoWL          % Number of winding layers.
    NoWS          % Number of winding sets.
    Ns            % Conductors per slot per layer.
    Version       % Current version of the tool.
end
properties(Dependent)
    CoilTable     % Winding connection diagram.
    ConTable      % Distribution of winding conductors.
    HO            % Harmonic orders.
    HOmax         % Maximum harmonic order.
    Kd            % Winding distribution factor.
    Kp            % Winding pitch factor.
    Kw            % Winding factor.
    LRorUD        % Arrangement of double-layer winding in slots.  
    NoPs          % Number of poles (2P).
    PhaseMat      % Phase spectrum matrix of the winding.
    PhaseName     % Winging name.
    PhaseShift    % Phase shift angle of multiple winding sets.
    PhaseShiftCur % Phase-shift angle of currents in multiple winding sets.
    PhaseTable    % Phase distribution table of windings.
    PoPi          % Pole pitch, expressed in number of slots (Z/2P).
    q             % Number of slots per pole per phase (q=Z/(2Pm)).
    SEleAng       % Slot electrical angle.
    SlotAng       % The electrical angle corresponding to the position of the slot center.
    SlotAngMech   % The mechanical angle of single slot.
    SlotMMF       % Combined magnetomotive force of the windings.
    SlotMMFHar    % Harmonics of the magnetomotive force.
    t             % Number of unit motors.
    TNoPh         % Total number of phases.
    WinP          % Winding pitch in slots.
    WPhBA         % Winding phase belt angle (Elec. deg).
end
properties (Access = private)
    Fre_User = false;           % User input flag for frequency.
    Fre_Value = 50;             % Default value of frequency is 50 Hz.

    NoPhPWS_User = false;       % User input flag for number of phases per winding set.
    NoPhPWS_Value = 3;          % Default value of phases per winding set is 3.
    
    NoPP_User = false;          % User input flag for number of pole pairs.
    NoPP_Value = 2;             % Default value of pole pairs is 2.
    NoPs_User = false;          % User input flag for number of poles.
    NoPs_Value = 4;             % Default value of poles is 4.
    NoPs_Source = false;        % Data source flag for number of pole pairs and number of poles.
    
    NoS_User = false;           % User input flag for number of slots.
    NoS_Value = 24;             % Default value of stator slots is 24.

    NoWL_User  = false;         % User input flag for number of winding layers.
    NoWL_Value = 2;             % Default value of winding layers is 2.

    NoWS_User = false;          % User input flag for number of winding sets.
    NoWS_Value = 1;             % Default value of winding sets is 1.
  
    WinP_User = false;          % User input flag for number of winding sets.
    WinP_Value = 6;             % Default value of winding pitch is 6.

    PhaseShift_User = false;    % User input flag for phase shift angle.
    PhaseShift_Value = 0;       % Default value of phase shift is 0.

    PhaseShiftCur_User = false; % User input flag for phase shift angle of current.
    PhaseShiftCur_Value = 0;    % Default value of current phase shift is 0.

    WPhBA_User = false;         % User input flag for winding phase belt angle.
    WPhBA_Value = 60;           % Default value of winding phase belt angle is 60.

    LRorUD_User = false;        % User input flag for type of the winding's upper and lower layer sides.
    LRorUD_Value = 'UD';        % Default value type of the winding's upper and lower layer sides is 'UD'.

    HOmax_User = false;         % User input flag for maximum harmonic order.
    HOmax_Value = 30;           % Default value of maximum harmonic order is 30.

    NsValue = 1;                % Default value of conductors per slot per layer is 1.
end
methods
    %% Constructor function.
    %  By default, it is a single-layer, single-three phase, 4-pole, 24-slot motor.
    function obj = MPhWindAna()
        obj.Version = '1.0'; % The current software version is 1.0.
    end
end
methods
    %% Set the fundamental frequency, defaulting to 50 Hz.
    function value = get.Fre(obj)
        if ~obj.Fre_User
            value = 50;
            return
        end
        value = obj.Fre_Value;
    end
    function set.Fre(obj,value)
        if ~isnumeric(value) || ~isscalar(value) || ~isfinite(value) || value <= 0
            warning('Invalid input for frequencey %g. The default value is 50 Hz.',value);
            obj.Fre_User = false;
            obj.Fre_Value = 50;
            return
        end
        obj.Fre_User = true;
        obj.Fre_Value = value;
    end
    %% Get or Set number of phases per winding set.
    function set.NoPhPWS(obj,val)
        obj.NoPhPWS_User = true;
        if ~isscalar(val) || ~isnumeric(val) || ~isfinite(val) || val < 3 || mod(val,1) ~= 0 || val == 4
            warning('The number of phases per winding set is invalid (%g). It has been set to the default value of 3.',val);
            obj.NoPhPWS_Value = 3;
        else
            obj.NoPhPWS_Value = val;
        end
    end
    function NoPhPWS = get.NoPhPWS(obj)
        NoPhPWS0 = 3;
        if obj.NoPhPWS_User
            NoPhPWS = obj.NoPhPWS_Value;
        else
            NoPhPWS = NoPhPWS0;
        end
    end
    %% Get or Set number of poles or number of pole pairs.
    %  Automatically calculate the number of poles or pole pairs based on which one is input.
    function NoPs = get.NoPs(obj)
        if ~obj.NoPs_User && ~obj.NoPP_User
            NoPs = 4;
            return;
        end
        if obj.NoPs_Source
            NoPs = obj.NoPs_Value;
            return;
        end
        NoPs = 2 * obj.NoPP_Value;
    end
    function set.NoPs(obj,val)
        NoPs0 = 4;
        obj.NoPs_User = true;
        obj.NoPP_User = false;
        obj.NoPs_Source = true;
        if ~isscalar(val) || ~isnumeric(val) || ~isfinite(val) || mod(val,1) ~= 0 || val < 2 || mod(val,2) ~= 0
            warning('The input number of poles is invalid (%g). It must be an even integer greater than or equal to 2. It has been set to the default value of 4.',val);
            obj.NoPs_Value = NoPs0;
        else
            obj.NoPs_Value = val;
        end
    end
    function NoPP = get.NoPP(obj)
        if ~obj.NoPs_User && ~obj.NoPP_User
            NoPP = 2;
            return;
        end
        if obj.NoPs_Source
            NoPP = obj.NoPs_Value / 2;
            return;
        end
        NoPP = obj.NoPP_Value;
    end
    function set.NoPP(obj,val)
        NoPP0 = 2;
        obj.NoPP_User = true;
        obj.NoPs_User = false;
        obj.NoPs_Source = false;
        if ~isscalar(val) || ~isnumeric(val) || ~isfinite(val) || mod(val,1) ~= 0 || val < 1
            warning('The input number of pole pairs is invalid (%g). It must be a positive integer. It has been set to the default value of 2.',val);
            obj.NoPP_Value = NoPP0;
        else
            obj.NoPP_Value = val;
        end
    end
    %% Get or Set and Check the number of stator slots.
    function set.NoS(obj,val)
        obj.NoS_User = true;
        if ~isscalar(val) || ~isnumeric(val) || ~isfinite(val) || val < 6 || mod(val,1) ~= 0
            warning('The input number of slots is invalid (%g). It has been set to the default value of 24.',val);
            obj.NoS_Value = 24;
        else
            obj.NoS_Value = val;
        end
    end
    function NoS = get.NoS(obj)
        NoS0 = 24;
        if obj.NoS_User
            NoS = obj.NoS_Value;
        else
            NoS = NoS0;
        end
    end
    function checkNoSNoPhPWS(obj)
        NoPhPWS0 = 3;
        NoWS0 = 1;
        NoS0 = 24;
        if obj.NoS_User
            NoS = obj.NoS_Value;
        else
            NoS = NoS0;
        end
        if obj.NoPhPWS_User
            NoPhPWS = obj.NoPhPWS_Value;
        else
            NoPhPWS = NoPhPWS0;
        end
        if obj.NoWS_User
            NoWS = obj.NoWS_Value;
        else
            NoWS = NoWS0;
        end
        NoPP = obj.NoPP;
        if NoPhPWS >= 5
            q = NoS/(2*NoPP*NoPhPWS);
            if abs(q-round(q)) > 1e-10
                warning(['For five or more phases per winding set, the number of slots per pole per phase must be an integer. ' ...
                'The current number of slots is %g, the number of pole pairs is %g, ' ...
                'the number of phases per winding set is %g, and the calculated number of slots per pole per phase is %.6g. ' ...
                'The number of phases per winding set has been set to the default value of 3.'], ...
                NoS,NoPP,NoPhPWS,q);
                obj.NoPhPWS_Value = NoPhPWS0;
            end
        end 
        if NoWS ~= NoWS0
            if mod(NoS,NoPP) ~= 0
                warning('The number of slots (%g) must be divisible by the number of pole pairs (%g) when the number of winding sets is greater than 1. The number of winding sets has been set to the default value of 1.',NoS,NoPP);
                obj.NoWS_Value = NoWS0;
            else
                NoSPerPolePair = NoS/NoPP;
                if mod(NoSPerPolePair,NoWS) ~= 0
                    warning('The number of slots per pole pair (%g) must be divisible by the number of winding sets (%g). The number of winding sets has been set to the default value of 1.',NoSPerPolePair,NoWS);
                    obj.NoWS_Value = NoWS0;
                end
            end
        end
    end
    %% Get or Set number of winding layers.
    function NoWL = get.NoWL(obj)
        NoWL0 = 2;
        if obj.NoWL_User
            NoWL = obj.NoWL_Value;
        else
            NoWL = NoWL0;
        end
    end
    function set.NoWL(obj,value)
        NoWL0 = 2;
        if isnumeric(value) && isscalar(value) && isfinite(value) && (value == 1 || value == 2)
            obj.NoWL_User = true;
            obj.NoWL_Value = value;
        else
            warning('Invalid input for number of winding layers (%g). The default number of winding layers is 2.',value);
            obj.NoWL_User = false;
            obj.NoWL_Value = NoWL0;
        end
    end
    %% Set the number of winding turns.
    function set.Ns(obj,Ns)
        if nargin < 2 || isempty(Ns)
            obj.NsValue = 1;
        elseif isnumeric(Ns) && isscalar(Ns) && isfinite(Ns) && Ns > 1 && mod(Ns,1) == 0
            obj.NsValue = Ns;
        else
            warning('Input is invalid. Number of winding turns is set to 1.');
            obj.NsValue = 1;
        end
    end
    function Ns = get.Ns(obj)
        Ns = obj.NsValue;
    end
    %% Get unit motor.
    function t = get.t(obj)
        t = gcd(obj.NoPP,obj.NoS);
    end
    %% Set the type of the winding's upper and lower layer sides.
    function set.LRorUD(obj,value)
        if ~(ischar(value) || isstring(value)) || ~ismember(char(value),{'LR','UD'})
            error('Arrangement of double-layer windings in slots must be ''LR'' or ''UD''.')
        end
        value = char(value);
        obj.LRorUD_Value = value;
        obj.LRorUD_User = true;
    end
    function mval = get.LRorUD(obj)
        if obj.LRorUD_User
            mval = obj.LRorUD_Value;
        else
            mval = 'UD';
        end
    end
    %% Winding parameter check function.
    function checkQNoWS(obj)
        q = obj.q;
        NoWS = obj.NoWS;
        if q < 1 && NoWS ~= 1
            warning('When the number of slots per pole per phase is greater than 1 and less than 2, the number of winding sets must be 1.');
            obj.NoWS = 1;
        end
    end
    function checkWindingInput(obj)
        obj.checkNoSNoPhPWS();
        obj.checkQNoWS();
        obj.checkWinP;
    end
    %% Get or Set number of winding sets.
    function set.NoWS(obj,val)
        obj.NoWS_User = true;
        obj.NoWS_Value = val;
    end
    function NoWS = get.NoWS(obj)
        if ~obj.NoWS_User
            NoWS = 1;
            return;
        end
        if ~isscalar(obj.NoWS_Value) || ~isnumeric(obj.NoWS_Value) || ~isfinite(obj.NoWS_Value)  || mod(obj.NoWS_Value,1) ~= 0
            warning('The input number of winding sets is invalid (%g). It has been set to the default value of 1.',obj.NoWS_Value);
            NoWS = 1;
            return;
        end
        if obj.NoWS_Value < 1
            warning('The input number of winding sets is invalid (%g). It has been set to the default value of 1.',obj.NoWS_Value);
            NoWS = 1;
            return;
        end
        NoWS = obj.NoWS_Value;
    end
    %% Get slot mechanical angle.
    function SlotAngMech = get.SlotAngMech(obj)
        SlotAngMech = 360 / obj.NoS;
    end
    %% Get slot electrical angle.
    function SEleAng = get.SEleAng(obj)
        NoS = obj.NoS;
        NoPP = obj.NoPP;
        SEleAng = 360 * NoPP / NoS;
    end
    %% Get pole pitch (in slots, tau = Z / 2P).
    %  The slot number and pole-pair number are independent design inputs,
    %  and the pole pitch is calculated as a derived parameter.
    function PoPi = get.PoPi(obj)
        NoS0 = 24;
        NoPs0 = 4;
        PoPi0 = NoS0 / NoPs0;
        if obj.NoS == 0 || obj.NoPs == 0
            warning('The pole pitch is invalid. Pole pitch has been set to the default value of 6.');
            PoPi = PoPi0;
            return;
        end
        PoPi = obj.NoS / obj.NoPs;
    end
    %% Get or Set winding pole pitch.
    function set.WinP(obj,value)
        if obj.NoWL == 1
            obj.WinP_User = false;
            obj.WinP_Value = floor(obj.PoPi);
            return;
        end
        if isnumeric(value) && isscalar(value) && isfinite(value) && value > 0 && mod(value,1) == 0
            obj.WinP_Value = value;
            obj.WinP_User = true;
        else
            warning('The default winding pitch %\d will be used.',floor(obj.PoPi));
            obj.WinP_Value = floor(obj.PoPi);
            obj.WinP_User = false;
            return;
        end
        obj.checkWinP();
    end
    function value = get.WinP(obj)
        if obj.NoWL == 1
            value = floor(obj.PoPi);
            return;
        end
        if obj.WinP_User
            value = obj.WinP_Value;
        else
            value = floor(obj.PoPi);
        end
    end
    function checkWinP(obj)
        WinPmax = floor(obj.PoPi);
        WinP = obj.WinP_Value;
        if obj.NoWL == 1
            obj.WinP_Value = WinPmax;
            return;
        end
        if obj.q < 1 && WinP ~= 1
            warning('When the number of slots per pole per phase is less than 1, the winding pitch must be 1.');
            obj.WinP_Value = 1;
            return;
        end
        if WinP < 1 || WinP > WinPmax
            warning('The input winding pitch %g is invalid for the current winding parameters and has been set to %d.',WinP,WinPmax);
            obj.WinP_Value = WinPmax;
        end
    end
    %% Get total number of phases.
    %  Total number of stator winding phases = winding sets * phases per set.
    function TNoPh = get.TNoPh(obj)
        TNoPh = obj.NoPhPWS * obj.NoWS;
    end
    %% Get slots per pole per phase.
    % The slots per pole per phase of the winding = stator slots / (poles * total winding phases).
    function qval = get.q(obj)
        obj.checkNoSNoPhPWS()
        if obj.NoS<=0 || obj.NoPP<=0 || obj.TNoPh<=0
            qval = 0;
            return;
        end
        qval = obj.NoS/(2*obj.NoPP*obj.TNoPh);
    end
    %% Get or Set phase belt angle (Elec. Deg).
    function set.WPhBA(obj,val)
        obj.WPhBA_User = true;
        obj.WPhBA_Value = val;
    end
    function WPhBA = get.WPhBA(obj)
        WPhBA0 = 180/obj.NoPhPWS;
        if ~obj.WPhBA_User
            WPhBA = WPhBA0;
            return;
        end
        if ~isscalar(obj.WPhBA_Value) || ~isnumeric(obj.WPhBA_Value) || ~isfinite(obj.WPhBA_Value) || obj.WPhBA_Value <= 0
            warning('The input phase belt angle is invalid (%g). It has been set to the default value of %d.',obj.WPhBA_Value,WPhBA0);
            WPhBA = WPhBA0;
            return;
        end
        if obj.WPhBA_Value > WPhBA0
            warning('The input phase belt angle (%g) is greater than the default value (%d). It has been set to the default value.',obj.WPhBA_Value,WPhBA0);
            WPhBA = WPhBA0;
            return;
        end
        if obj.WPhBA_Value == WPhBA0
            WPhBA = WPhBA0;
            return;
        end
        if obj.WPhBA_Value < WPhBA0
            if obj.q >= 1 && mod(obj.WPhBA_Value,obj.SEleAng) == 0
                WPhBA = obj.WPhBA_Value;
                return;
            elseif obj.q < 1 && mod(obj.WPhBA_Value,obj.SlotAngMech) == 0
                WPhBA = obj.WPhBA_Value;
                return;
            end
        end
        WPhBA = WPhBA0;
    end
    %% Get slot electrical angle (Elec. Deg)
    function SlotAngle = get.SlotAng(obj)
        SlotAngle = obj.SEleAng * (0:obj.NoS - 1);
    end
    %% Generating winding names.
    function PhaseName = get.PhaseName(obj)
        NoPhPWS = obj.NoPhPWS;
        NoWS = obj.NoWS;
        PhaseName = {};
        for m = 1:NoWS
            for k = 1:NoPhPWS
                if NoWS == 1
                    if  NoPhPWS > 5
                        PhaseName = [PhaseName, {['P' num2str(k)]}];
                    else
                        PhaseName = [PhaseName, {char(64 + k)}];
                    end
                else
                    if NoPhPWS > 5
                        PhaseName = [PhaseName, {['P' num2str(k) '_' num2str(m)]}];
                    else
                        PhaseName = [PhaseName, {[char(64 + k) num2str(m)]}];
                    end
                end
            end
        end
    end
    %% Generate the phase spectrum matrix of the winding.
    function PhaseMat = get.PhaseMat(obj)
        obj.checkWindingInput();
        SlotAngle = obj.SlotAng;
        SEleAng = obj.SEleAng;
        NoPP = obj.NoPP;
        NoS = obj.NoS;
        NoWL = obj.NoWL;
        NoCol = round(360 / SEleAng);
        if NoWL == 1
            PhaseMat = zeros(NoPP, NoCol);
            for k = 1:NoS
                Ang = mod(SlotAngle(k), 360);
                rownum = floor(SlotAngle(k) / 360) + 1;
                colnum = mod(round(Ang / SEleAng), NoCol) + 1;
                PhaseMat(rownum, colnum) = k;
            end
            return;
        end
        PhaseMat = zeros(2 * NoPP, NoCol);
        for k = 1:NoS
            Ang = mod(SlotAngle(k), 360);
            rownum = floor(SlotAngle(k) / 360) + 1;
            colnum = mod(round(Ang / SEleAng), NoCol) + 1;
            PhaseMat(rownum, colnum) = k;
        end
        for k = 1:NoS
            Ang = mod(SlotAngle(k) + 180, 360);
            rownum = mod(floor((SlotAngle(k) + 180) / 360), NoPP) + NoPP + 1;
            colnum = mod(round(Ang / SEleAng), NoCol) + 1;
            PhaseMat(rownum, colnum) = -k;
        end
    end
    %% Get or Set phase shift angles for the multi-phase winding.
    function set.PhaseShift(obj,value)
        if isempty(value) || value <= 0
            obj.PhaseShift_User = false;
            obj.PhaseShift_Value = 0;
        else
            obj.PhaseShift_User = true;
            obj.PhaseShift_Value = value;
        end
    end
    function PhaseShift = get.PhaseShift(obj)
        if obj.NoWS == 1
            PhaseShift_Default = 0;
        else
            PhaseShift_Default = obj.WPhBA / obj.NoWS;
        end
        if ~obj.PhaseShift_User
            PhaseShift = PhaseShift_Default;
            return;
        end
        if obj.NoWS == 2
            if obj.PhaseShift_Value == 0 || obj.PhaseShift_Value == PhaseShift_Default
                PhaseShift = obj.PhaseShift_Value;
            else
                warning('The input phase shift angle %d is invalid. It has been set to the default value %d.', obj.PhaseShift_Value,PhaseShift_Default);
                PhaseShift = PhaseShift_Default;
            end
        elseif obj.NoWS > 2
            if obj.PhaseShift_Value ~= PhaseShift_Default
                warning('The input phase shift angle %d is invalid. It has been set to the default value %d.', obj.PhaseShift_Value,PhaseShift_Default);
            end
            PhaseShift = PhaseShift_Default;
        else
            warning('The input phase shift angle %d is invalid. It has been set to the default value %d.', obj.PhaseShift_Value,PhaseShift_Default);
            PhaseShift = PhaseShift_Default;
        end
    end
    %% Get or Set Phase-shift angle of currents in multiple winding sets.
    function PhaseShiftCur = get.PhaseShiftCur(obj)
        if obj.PhaseShiftCur_User
            PhaseShiftCur = obj.PhaseShiftCur_Value;
        else
            PhaseShiftCur = obj.PhaseShift;
        end
    end
    function set.PhaseShiftCur(obj,value)
        if nargin < 2 || isempty(value)
            obj.PhaseShiftCur_User = false;
            obj.PhaseShiftCur_Value = 0;
            return
        end
        if isnumeric(value) && isscalar(value) && isfinite(value) && value >= 0 && value <= obj.PhaseShift
            obj.PhaseShiftCur_Value = value;
            obj.PhaseShiftCur_User = true;
        else
            warning('Input is invalid. Phase shift of current is set to default %d.',0);
            obj.PhaseShiftCur_User = false;
            obj.PhaseShiftCur_Value = 0;
        end
    end
    %% Generate the phase table of the winding
    function PhaseTable = get.PhaseTable(obj)
        NoPhPWS = obj.NoPhPWS;
        NoWS = obj.NoWS;
        NoS = obj.NoS;
        SlotAng = double(obj.SlotAng);
        PhaseName = cellstr(string(obj.PhaseName));
        PhaseShift = double(obj.PhaseShift);
        PhaseTable = cell(2,NoS+1);
        PhaseTable{1,1} = 'Slot Number';
        PhaseTable{2,1} = 'Phase Name';
        Tol = 1e-9;
        BeltAng = 180/NoPhPWS;
        CenterOffset = BeltAng/2;
        PhaseStep = 360/NoPhPWS;
        PosAng0 = mod((0:NoPhPWS-1)*PhaseStep+CenterOffset,360);
        NegAng0 = mod(PosAng0+180,360);
        AxisOverlap = false;
        for k = 1:NoPhPWS
            Delta = abs(mod(NegAng0(k)-PosAng0+180,360)-180);
            if any(Delta <= Tol)
                AxisOverlap = true;
                break;
            end
        end
        if AxisOverlap
            PhaseStep = 180/NoPhPWS;
            PosAng0 = mod((0:NoPhPWS-1)*PhaseStep+CenterOffset,360);
            NegAng0 = mod(PosAng0+180,360);
        end
        for s = 1:NoS
            Ang = mod(SlotAng(s),360);
            if abs(Ang) <= Tol || abs(Ang-360) <= Tol
                Ang = 0;
            end
            BasePhase = 0;
            BaseSign = '';
            BeltStart = 0;
            for ph = 1:NoPhPWS
                PosStart = mod(PosAng0(ph)-BeltAng/2,360);
                PosEnd = mod(PosAng0(ph)+BeltAng/2,360);
                if PosStart < PosEnd
                    InPosBelt = Ang >= PosStart-Tol && Ang < PosEnd-Tol;
                else
                    InPosBelt = Ang >= PosStart-Tol || Ang < PosEnd-Tol;
                end
                if InPosBelt
                    BasePhase = ph;
                    BaseSign = '+';
                    BeltStart = PosStart;
                    break;
                end
                NegStart = mod(NegAng0(ph)-BeltAng/2,360);
                NegEnd = mod(NegAng0(ph)+BeltAng/2,360);
                if NegStart < NegEnd
                    InNegBelt = Ang >= NegStart-Tol && Ang < NegEnd-Tol;
                else
                    InNegBelt = Ang >= NegStart-Tol || Ang < NegEnd-Tol;
                end
                if InNegBelt
                    BasePhase = ph;
                    BaseSign = '-';
                    BeltStart = NegStart;
                    break;
                end
            end
            if BasePhase == 0
                PhaseTable{1,s+1} = s;
                PhaseTable{2,s+1} = '';
                continue;
            end
            if NoWS == 1
                WSIndex = 1;
            else
                RelativeAng = mod(Ang-BeltStart,360);
                RelativeAng = min(RelativeAng,BeltAng);
                WSIndex = round(RelativeAng/PhaseShift)+1;
                WSIndex = max(1,min(NoWS,WSIndex));
            end
            PhaseIndex = (WSIndex-1)*NoPhPWS+BasePhase;
            PhaseTable{1,s+1} = s;
            PhaseTable{2,s+1} = [PhaseName{PhaseIndex},BaseSign];
        end
    end
    %% Generate winding phase distribution table.
    function ConTable = get.ConTable(obj)
        NoWL = obj.NoWL;
        NoWS = obj.NoWS;
        NoPhPWS = obj.NoPhPWS;
        WinP = obj.WinP;
        NoS = obj.NoS;
        LRorUD = obj.LRorUD;
        PhaseTable = obj.PhaseTable;
        ConTable = {};
        if NoWL == 1
            ConTable = PhaseTable;
            return
        end
        ConTable{1,1} = 'Slot Number';
        switch LRorUD
            case 'LR'
                ConTable{2,1} = 'Left';
                ConTable{3,1} = 'Right';
            case 'UD'
                ConTable{2,1} = 'Up';
                ConTable{3,1} = 'Down';
        end
        for slot = 1:NoS
            phaseData = PhaseTable{2,slot+1};
            if isempty(phaseData)
                continue
            end
            ConTable{1,slot+1} = slot;
            lowerSlot = mod(slot+WinP-1,NoS)+1;
            ConTable{1,lowerSlot+1} = lowerSlot;
            if phaseData(end) == '+'
                PhaseName = phaseData(1:end-1);
                ConTable{2,slot+1} = [PhaseName '+'];
                ConTable{3,lowerSlot+1} = [PhaseName '-'];
            elseif phaseData(end) == '-'
                PhaseName = phaseData(1:end-1);
                ConTable{2,slot+1} = [PhaseName '-'];
                ConTable{3,lowerSlot+1} = [PhaseName '+'];
            end
        end
    end
    %% Plot the spatial distribution diagram of the winding.
    function WindingPlot(obj)
        ConTable = obj.ConTable;
        NoS = size(ConTable,2)-1;
        NoWL = size(ConTable,1)-1;
        NoPhPWS = obj.NoPhPWS;
        NoWS = obj.NoWS;
        theta = (0:NoS-1)*2*pi/NoS;
        SlotPitch = 2*pi/NoS;
        Rin = 0.7;
        Rout = 1.25;
        if NoWL == 2
            Rup = Rin + 0.65*(Rout-Rin);
            Rdown = Rin + 0.35*(Rout-Rin);
            RtextUp = Rin + 0.85*(Rout-Rin);
            RtextDown = Rin + 0.15*(Rout-Rin);
        else
            Rsingle = Rin + 0.46*(Rout-Rin);
            RtextSingle = Rin + 0.82*(Rout-Rin);
        end
        Rslot = Rout + 0.10;
        fig = figure('Name','Winding',...
            'NumberTitle','off',...
            'Color','w',...
            'Units','centimeters',...
            'Position',[0 0 10 10],...
            'Resize','off');
        movegui(fig,'center');
        ax = axes('Parent',fig,...
            'Units','normalized',...
            'Position',[0.01 0.01 0.98 0.98]);
        hold(ax,'on');
        axis(ax,'equal');
        axis(ax,'off');
        t = linspace(0,2*pi,600);
        plot(Rin*cos(t),Rin*sin(t),'k','LineWidth',1.2);
        plot(Rout*cos(t),Rout*sin(t),'k','LineWidth',1.2);
        for k = 1:NoS
            thL = theta(k)-SlotPitch/2;
            thR = theta(k)+SlotPitch/2;
            plot([Rin*cos(thL) Rout*cos(thL)],[Rin*sin(thL) Rout*sin(thL)],'k','LineWidth',0.8);
            plot([Rin*cos(thR) Rout*cos(thR)],[Rin*sin(thR) Rout*sin(thR)],'k','LineWidth',0.8);
        end
        for k = 1:NoS
            text(Rslot*cos(theta(k)),Rslot*sin(theta(k)),num2str(k),'HorizontalAlignment','center','VerticalAlignment','middle','FontName','Times New Roman','FontSize',10,'FontWeight','bold');
        end
        PhaseNames = {};
        for row = 2:NoWL+1
            for k = 1:NoS
                tag = ConTable{row,k+1};
                if isempty(tag)
                    continue
                end
                tag = char(string(tag));
                if tag(end)=='+' || tag(end)=='-'
                    name = tag(1:end-1);
                else
                    name = tag;
                end
                if ~any(strcmp(PhaseNames,name))
                    PhaseNames{end+1} = name;
                end
            end
        end
        if isempty(PhaseNames)
            return
        end
        if NoWS == 1
            BasePhaseNames = PhaseNames;
        else
            BasePhaseNames = {};
            for k = 1:numel(PhaseNames)
                name = PhaseNames{k};
                base = regexprep(name,'\d+$','');
                if isempty(base)
                    base = name;
                end
                if ~any(strcmp(BasePhaseNames,base))
                    BasePhaseNames{end+1} = base;
                end
            end
            if numel(BasePhaseNames) > NoPhPWS
                BasePhaseNames = BasePhaseNames(1:NoPhPWS);
            end
        end
        NoBasePh = numel(BasePhaseNames);
        if NoBasePh <= 3
            BaseColorTable = [1.00 0.00 0.00;0.00 0.55 0.00;0.00 0.20 1.00];
        else
            BaseColorTable = lines(NoBasePh);
        end
        for row = 2:NoWL+1
            for k = 1:NoS
                tag = ConTable{row,k+1};
                if isempty(tag)
                    continue
                end
                tag = char(string(tag));
                if tag(end)=='+' || tag(end)=='-'
                    PhaseName = tag(1:end-1);
                    Polarity = tag(end);
                else
                    PhaseName = tag;
                    Polarity = '+';
                end
                if NoWS == 1
                    PhaseIdx = find(strcmp(PhaseNames,PhaseName),1);
                    if isempty(PhaseIdx)
                        PhaseIdx = 1;
                    end
                    c = BaseColorTable(mod(PhaseIdx-1,size(BaseColorTable,1))+1,:);
                else
                    BaseName = regexprep(PhaseName,'\d+$','');
                    if isempty(BaseName)
                        BaseName = PhaseName;
                    end
                    BaseIdx = find(strcmp(BasePhaseNames,BaseName),1);
                    if isempty(BaseIdx)
                        BaseIdx = 1;
                    end
                    BaseColor = BaseColorTable(mod(BaseIdx-1,size(BaseColorTable,1))+1,:);
                    SamePhaseNames = {};
                    for m = 1:numel(PhaseNames)
                        TestName = PhaseNames{m};
                        TestBase = regexprep(TestName,'\d+$','');
                        if isempty(TestBase)
                            TestBase = TestName;
                        end
                        if strcmp(TestBase,BaseName)
                            SamePhaseNames{end+1} = TestName;
                        end
                    end
                    SetIdx = find(strcmp(SamePhaseNames,PhaseName),1);
                    if isempty(SetIdx)
                        SetIdx = 1;
                    end
                    ShadeTable = [1.00 0.55 0.25 0.10];
                    if SetIdx <= numel(ShadeTable)
                        Scale = ShadeTable(SetIdx);
                    else
                        Scale = max(0.10,1.00-0.25*(SetIdx-1));
                    end
                    c = 1-Scale*(1-BaseColor);
                end
                if NoWL == 2
                    if row == 2
                        R = Rup;
                        Rtext = RtextUp;
                    else
                        R = Rdown;
                        Rtext = RtextDown;
                    end
                else
                    R = Rsingle;
                    Rtext = RtextSingle;
                end
                x = R*cos(theta(k));
                y = R*sin(theta(k));
                plot(x,y,'o','MarkerSize',9,'MarkerFaceColor','w','MarkerEdgeColor',c,'LineWidth',1.5);
                if Polarity == '+'
                    plot(x,y,'.','MarkerSize',12,'Color',c);
                else
                    plot(x,y,'x','MarkerSize',6,'Color',c,'LineWidth',1.5);
                end
                xt = Rtext*cos(theta(k));
                yt = Rtext*sin(theta(k));
                text(xt,yt,tag,'HorizontalAlignment','center','VerticalAlignment','middle','FontName','Times New Roman','FontSize',7,'Color',c);
            end
        end
        margin = 0.25;
        xlim([-(Rslot+margin) (Rslot+margin)]);
        ylim([-(Rslot+margin) (Rslot+margin)]);
    end
    %% Obtain or calculate the harmonic order.
    function set.HOmax(obj,value)
        obj.HOmax_User = true;
        if value >= 1 && mod(value,1) == 0
            obj.HOmax_Value = value;
        else
            warning('The maximum harmonic order must be a positive integer, with a default value of 30.')
            obj.HOmax_Value = 30;
        end
    end
    function HOmax = get.HOmax(obj)
        if ~obj.HOmax_User
            HOmax = 30;
            return;
        end
        HOmax = obj.HOmax_Value;
    end
    function HO = get.HO(obj)
        HOmax = obj.HOmax;
        HO = (1:2:HOmax).';
    end
    %% Get the coil connection relationship.
    function CoilTable = get.CoilTable(obj)
        NoWL = obj.NoWL;
        NoS = obj.NoS;
        WinP = obj.WinP;
        PhaseTable = obj.PhaseTable;
        if NoWL == 1
            CoilTable = cell(1,4);
            CoilTable(1,:) = {'Coil Number','Phase Name','Slot Number','Sign'};
            CoilNumber = 0;
            for s = 1:NoS
                PhaseName = string(PhaseTable{2,s + 1});
                if endsWith(PhaseName,"+")
                    PhaseBase = extractBefore(PhaseName,strlength(PhaseName));
                    Sign = 1;
                elseif endsWith(PhaseName,"-")
                    PhaseBase = extractBefore(PhaseName,strlength(PhaseName));
                    Sign = -1;
                else
                    PhaseBase = PhaseName;
                    Sign = 1;
                end
                CoilNumber = CoilNumber + 1;
                CoilTable(CoilNumber + 1,:) = {CoilNumber,char(PhaseBase),s,Sign};
            end
            return;
        end
        CoilTable = cell(1,6);
        CoilTable(1,:) = {'Coil Number','Phase Name','Upper Slot','Lower Slot','Upper Sign','Lower Sign'};
        CoilNumber = 0;
        for s = 1:NoS
            PhaseName = string(PhaseTable{2,s + 1});
            if endsWith(PhaseName,"+")
                PhaseBase = extractBefore(PhaseName,strlength(PhaseName));
                UpperSign = 1;
            elseif endsWith(PhaseName,"-")
                PhaseBase = extractBefore(PhaseName,strlength(PhaseName));
                UpperSign = -1;
            else
                PhaseBase = PhaseName;
                UpperSign = 1;
            end
            LowerSlot = mod(s - 1 + WinP,NoS) + 1;
            CoilNumber = CoilNumber + 1;
            CoilTable(CoilNumber + 1,:) = {CoilNumber,char(PhaseBase),s,LowerSlot,UpperSign,-UpperSign};
        end
    end
    %% Calculate the distribution factor of the winding.
    function Kd = get.Kd(obj)
        HO = obj.HO;
        CoilTable = obj.CoilTable;
        SlotAng = obj.SlotAng;
        Kd = ones(size(HO));
        if isempty(CoilTable) || isempty(SlotAng)
            return;
        end
        if obj.NoWL == 1
            SlotNumber = cell2mat(CoilTable(2:end,3));
            Sign = cell2mat(CoilTable(2:end,4));
            PhaseName = string(CoilTable(2:end,2));
            Valid = SlotNumber > 0 & PhaseName ~= "";
            SlotNumber = SlotNumber(Valid);
            Sign = Sign(Valid);
            PhaseName = PhaseName(Valid);
            if isempty(SlotNumber)
                return;
            end
            PhaseTag = PhaseName(1);
            DirectionTag = 1;
            Index = PhaseName == PhaseTag & Sign == DirectionTag;
            SlotIndex = SlotNumber(Index);
        else
            PhaseName = string(CoilTable(2:end,2));
            UpperSlot = cell2mat(CoilTable(2:end,3));
            UpperSign = cell2mat(CoilTable(2:end,5));
            Valid = UpperSlot > 0 & PhaseName ~= "";
            PhaseName = PhaseName(Valid);
            UpperSlot = UpperSlot(Valid);
            UpperSign = UpperSign(Valid);
            if isempty(UpperSlot)
                return;
            end
            PhaseTag = PhaseName(1);
            DirectionTag = 1;
            Index = PhaseName == PhaseTag & UpperSign == DirectionTag;
            SlotIndex = UpperSlot(Index);
        end
        if isempty(SlotIndex)
            return;
        end
        SlotIndex = SlotIndex(SlotIndex >= 1 & SlotIndex <= numel(SlotAng));
        if isempty(SlotIndex)
            return;
        end
        Ang = SlotAng(SlotIndex);
        Nq = numel(Ang);
        if Nq == 1
            Kd(:) = 1;
            return;
        end
        for k = 1:numel(HO)
            W = sum(exp(1j * HO(k) * deg2rad(Ang)));
            Kd(k) = abs(W) / Nq;
        end
    end
    %% Calculate the short-pitch factor of the winding.
    function Kp = get.Kp(obj)
        NoWL = obj.NoWL;
        NoPhPWS = obj.NoPhPWS;
        CoilTable = obj.CoilTable;
        HO = obj.HO(:);
        SEleAng = obj.SEleAng;
        Kp = ones(size(HO));
        if NoWL == 1
            return;
        end
        if isempty(CoilTable) || size(CoilTable,1) < 2
            return;
        end
        PhaseName = string(CoilTable(2:end,2));
        UpperSlot = cell2mat(CoilTable(2:end,3));
        LowerSlot = cell2mat(CoilTable(2:end,4));
        if NoPhPWS < 6
            if any(PhaseName == "A1")
                PhaseTag = "A1";
            else
                PhaseTag = "A";
            end
        else
            PhaseTag = "P1_1";
        end
        Index = PhaseName == PhaseTag;
        UpperSlot = UpperSlot(Index);
        LowerSlot = LowerSlot(Index);
        if isempty(UpperSlot)
            return;
        end
        NoS = obj.NoS;
        DeltaSlot = LowerSlot - UpperSlot;
        DeltaSlot = mod(DeltaSlot + NoS/2,NoS) - NoS/2;
        Beta = DeltaSlot * SEleAng;
        for k = 1:length(HO)
            h = HO(k);
            Kp(k) = mean(abs(sind(h * Beta / 2)));
        end
    end
    %% Calculate the winding factor.
    function Kw = get.Kw(obj)
        Kw = obj.Kd.*obj.Kp;
    end
    %% Plot the winding factor diagram.
    function KdpwPlot(obj,FactorType)
        if nargin < 2
            FactorType = 3;
        end
        HarmonicOrder = obj.HO;
        Kd = obj.Kd;
        Kp = obj.Kp;
        switch FactorType
            case 1
                Coef = Kd;
                fname = 'Kd';
                yname = '$K_{\rm{d}}$';
            case 2
                Coef = Kp;
                fname = 'Kp';
                yname = '$K_{\rm{p}}$';
            case 3
                Coef = Kd .* Kp;
                fname = 'Kw';
                yname = '$K_{\rm{w}}$';
            otherwise
                error('FactorType must be 1, 2 or 3.');
        end
        figure('Name',fname,'NumberTitle','off','Color','w');
        set(gcf,'Units','centimeters');
        set(gcf,'Position',[0 0 12 8]);
        movegui(gcf,'center');
        stem(HarmonicOrder,Coef,'filled','LineWidth',1.2,'MarkerSize',5);
        grid on;
        box on;
        ax = gca;
        ax.FontName = 'Times New Roman';
        ax.FontSize = 12;
        ax.LineWidth = 1;
        ax.XLim = [min(HarmonicOrder) - 1,max(HarmonicOrder) + 1];
        ax.YLim = [0,1.05];
        ax.XTick = HarmonicOrder;
        xlabel('Harmonic Order','FontName','Times New Roman','FontSize',12);
        ylabel(yname,'Interpreter','latex','FontSize',12);
        set(gca,'LooseInset',get(gca,'TightInset'));
    end
    %% Calculate winding MMF.
    function SlotMMF = get.SlotMMF(obj) 
        ConTable = obj.ConTable; 
        PhaseName = string(obj.PhaseName(:).'); 
        NoS = double(obj.NoS); 
        NoPhPWS = double(obj.NoPhPWS); 
        NoWS = double(obj.NoWS); 
        Ns = double(obj.Ns); 
        IA = 1; 
        Fre = double(obj.Fre); 
        PhaseShiftCur = double(obj.PhaseShiftCur); 
        if isempty(ConTable) || isempty(PhaseName) || NoS <= 0 
            SlotMMF = []; 
            return; 
        end 
        PhaseName = strtrim(upper(PhaseName)); 
        if numel(PhaseName) ~= NoWS*NoPhPWS 
            error('The number of winding names should be equal to the total number of phases.'); 
        end 
        if Fre == 0 
            time = 0; 
        else 
            nTime = 60; 
            time = (0:nTime)/(nTime*Fre); 
        end 
        time = reshape(time,1,[]); 
        nTime = numel(time); 
        theta = 2*pi*Fre*time; 
        PhaseAngle = zeros(1,numel(PhaseName)); 
        BaseAngle = 360*(0:NoPhPWS-1)/NoPhPWS; 
        for ws = 1:NoWS 
            Index = (ws-1)*NoPhPWS+(1:NoPhPWS); 
            PhaseAngle(Index) = BaseAngle + (ws-1)*PhaseShiftCur; 
        end 
        PhaseCurrent = zeros(numel(PhaseName),nTime); 
        for k = 1:numel(PhaseName) 
            PhaseCurrent(k,:) = Ns*IA*cos(theta-deg2rad(PhaseAngle(k))); 
        end 
        if istable(ConTable) 
            ConArray = table2cell(ConTable); 
        else 
            ConArray = ConTable; 
        end 
        if isstring(ConArray) 
            ConArray = cellstr(ConArray); 
        elseif ischar(ConArray) 
            ConArray = cellstr(ConArray); 
        elseif ~iscell(ConArray) 
            ConArray = num2cell(ConArray); 
        end 
        RowName = string(ConArray(:,1)); 
        RowName = strtrim(upper(RowName)); 
        LayerData = {}; 
        if any(RowName=="UP") || any(RowName=="DOWN") 
            for k = 1:numel(RowName) 
                if RowName(k)=="UP" || RowName(k)=="DOWN" 
                    LayerData{end+1} = ConArray(k,2:end); 
                end 
            end 
        elseif any(RowName=="PHASE NAME") || any(RowName=="PHASE") 
            for k = 1:numel(RowName) 
                if RowName(k)=="PHASE NAME" || RowName(k)=="PHASE" 
                    LayerData{end+1} = ConArray(k,2:end); 
                end 
            end 
        else 
            if size(ConArray,1) == NoS && size(ConArray,2) ~= NoS 
                ConArray = ConArray.'; 
            end 
            if size(ConArray,2) == NoS 
                LayerData{1} = ConArray(1,:); 
            else 
                error('Unable to identify conductor information in Conductor Table.'); 
            end 
        end 
        if isempty(LayerData) 
            error('Unable to find conductor information in Conductor Table.'); 
        end 
        ConArray = vertcat(LayerData{:}); 
        if size(ConArray,2) ~= NoS 
            error('Slot number in Conductor Table does not match.'); 
        end 
        SlotAT = zeros(NoS,nTime); 
        for k = 1:NoS 
            AT = zeros(1,nTime); 
            for layer = 1:size(ConArray,1) 
                Label = ConArray{layer,k}; 
                if isempty(Label) 
                    continue; 
                end 
                Label = upper(strtrim(string(Label))); 
                Sign = 1; 
                if endsWith(Label,"+") 
                    Name = extractBefore(Label,strlength(Label)); 
                elseif endsWith(Label,"-") 
                    Name = extractBefore(Label,strlength(Label)); 
                    Sign = -1; 
                else 
                    Name = Label; 
                end 
                Name = strtrim(Name); 
                Index = find(PhaseName==Name,1); 
                if ~isempty(Index) 
                    AT = AT + Sign*PhaseCurrent(Index,:); 
                end 
            end 
            SlotAT(k,:) = AT; 
        end 
        SlotMMF = cumsum(SlotAT,1); 
        SlotMMF = SlotMMF - mean(SlotMMF,1); 
        SlotMMF(abs(SlotMMF)<1e-10)=0; 
    end
    %% Plot winding MMF.
    function MMFPlot(obj)
        SlotMMF = obj.SlotMMF;
        SlotMMF = SlotMMF(:, 1);
        NoS = obj.NoS;
        SlotNumber = (1:NoS).';
        figure('Name', 'MMF', 'NumberTitle', 'off', 'Color', 'w');
        set(gcf, 'Units', 'centimeters');
        set(gcf, 'Position', [0 0 12 8]);
        movegui(gcf, 'center');
        stairs(SlotNumber, SlotMMF, 'LineWidth', 1.2);
        grid on;
        box on;
        ax = gca;
        ax.FontName = 'Times New Roman';
        ax.FontSize = 12;
        ax.LineWidth = 1;
        ax.XLim = [.5 NoS/obj.t+0.5];
        ax.YLim = [1.1 * min(SlotMMF), 1.1 * max(SlotMMF)];
        ax.XTick = SlotNumber;
        xlabel('Slot Number', 'FontName', 'Times New Roman', 'FontSize', 12);
        ylabel('MMF', 'FontName', 'Times New Roman', 'FontSize', 12);
    end
    %% Calculate winding MMF harmonics.
    function SlotMMFHar = get.SlotMMFHar(obj)
        NoS = double(obj.NoS);
        NoPP = double(obj.NoPP);
        SlotMMF = double(obj.SlotMMF(:).');
        t = double(obj.t);
        HOmax = double(obj.HOmax);
        if isempty(SlotMMF)
            SlotMMFHar = zeros(0,3);
            return
        end
        NslotUnit = NoS/t;
        SlotMMF = SlotMMF(1:NoS);
        MMFUnit = SlotMMF(1:NslotUnit);
        Nsample = max(4096,NslotUnit*256);
        Nsample = ceil(Nsample/NslotUnit)*NslotUnit;
        SamplePerSlot = Nsample/NslotUnit;
        SampleMMF = repelem(MMFUnit,SamplePerSlot);
        Y = fft(SampleMMF);
        Amp = 2*abs(Y)/Nsample;
        Amp(1) = abs(Y(1))/Nsample;
        MaxUnitOrder = floor(HOmax/t);
        UnitHarmonicOrder = 1:MaxUnitOrder;
        HarmonicOrder = t*UnitHarmonicOrder;
        HarmonicAmp = zeros(size(HarmonicOrder));
        for k = 1:numel(UnitHarmonicOrder)
            h = UnitHarmonicOrder(k);
            if h <= Nsample/2
                HarmonicAmp(k) = Amp(h+1);
            end
        end
        FundamentalIndex = find(HarmonicOrder == NoPP,1);
        if isempty(FundamentalIndex)
            error('The fundamental harmonic order is not included in the selected harmonic orders.');
        end
        FundamentalAmp = HarmonicAmp(FundamentalIndex);
        if FundamentalAmp > eps
            HarmonicPercent = HarmonicAmp/FundamentalAmp*100;
        else
            HarmonicPercent = zeros(size(HarmonicAmp));
        end
        SlotMMFHar = [HarmonicOrder(:),HarmonicAmp(:),HarmonicPercent(:)];
    end
    %% Plot winding MMF harmonics.
    function MMFHarPlot(obj,Data,PlotType)
        if nargin < 2 || isempty(Data)
            Data = obj.SlotMMFHar;
        end
        if nargin < 3 || isempty(PlotType)
            PlotType = 1;
        end
        if ~isnumeric(Data) || size(Data,2) < 3
            error('Data must be an N-by-3 numeric matrix.');
        end
        HarmonicOrder = Data(:,1);
        HarmonicAmp = Data(:,2);
        HarmonicPercent = Data(:,3);
        switch PlotType
            case 1
                YData = HarmonicAmp;
            case 2
                YData = HarmonicPercent;
            otherwise
                error('PlotType must be 1 or 2.');
        end
        if isempty(HarmonicOrder)
            error('Harmonic data is empty.');
        end
        figure('Name','MMFHarmonic','NumberTitle','off','Color','w');
        set(gcf,'Units','centimeters');
        set(gcf,'Position',[0 0 12 8]);
        movegui(gcf,'center');
        stem(HarmonicOrder,YData,'filled','LineWidth',1.2,'MarkerSize',5);
        grid on;
        box on;
        ax = gca;
        ax.FontName = 'Times New Roman';
        ax.FontSize = 12;
        ax.LineWidth = 1;
        ax.XLim = [max(0,min(HarmonicOrder)-0.5),max(HarmonicOrder)+0.5];
        ax.XTick = HarmonicOrder;
        xlabel('Harmonic Order (Mech.)','FontName','Times New Roman','FontSize',12);
        switch PlotType
            case 1
                MaxY = max(YData);
                if MaxY > 0
                    ax.YLim = [0,1.05*MaxY];
                else
                    ax.YLim = [0,1];
                end
                ylabel('Amplitude','FontName','Times New Roman','FontSize',12);
            case 2
                ax.YLim = [0,105];
                ylabel('Content (%)','FontName','Times New Roman','FontSize',12);
        end
    end
    %% Draw the slot EMF star diagram of the winding.
    function SlotVectorPlot(obj)
        NoS = double(obj.NoS);
        NoPhPWS = double(obj.NoPhPWS);
        SlotAng = double(obj.SlotAng);
        ConTable = obj.ConTable;  
        NoPP = double(obj.NoPP);
        NoWS = double(obj.NoWS);
        SlotAng = reshape(SlotAng,1,[]);
        SlotAng = SlotAng-SlotAng(1);
        SlotAngMod = mod(SlotAng,360);
        SlotNumberRow = ConTable(1,2:NoS+1);
        PhaseNameRow = ConTable(2,2:NoS+1);
        if isprop(obj,'PhaseName')
            PhaseNameProperty = string(obj.PhaseName);
            PhaseNameProperty = PhaseNameProperty(:).';
            PhaseNameProperty = PhaseNameProperty(~ismissing(PhaseNameProperty) & PhaseNameProperty ~= "");
        else
            PhaseNameProperty = strings(1,0);
        end
        UpPhase = strings(1,NoS);
        UpSign = strings(1,NoS);
        SlotUsed = false(1,NoS);
        for k = 1:NoS
            SlotValue = SlotNumberRow{k};
            if isnumeric(SlotValue) && isscalar(SlotValue) && isfinite(SlotValue)
                Slot = round(SlotValue);
            else
                Slot = k;
            end
            if Slot < 1 || Slot > NoS
                continue;
            end
            PhaseValue = strtrim(string(PhaseNameRow{k}));
            if PhaseValue == "" || ismissing(PhaseValue)
                continue;
            end
            if endsWith(PhaseValue,"+") || endsWith(PhaseValue,"-")
                PhaseBase = extractBefore(PhaseValue,strlength(PhaseValue));
                SignValue = extractAfter(PhaseValue,strlength(PhaseValue)-1);
            else
                PhaseBase = PhaseValue;
                SignValue = "+";
            end
            UpPhase(Slot) = PhaseBase;
            UpSign(Slot) = SignValue;
            SlotUsed(Slot) = true;
        end
        FirstWindingNames = strings(1,0);
        IsPNumberPhase = false;
        if ~isempty(PhaseNameProperty)
            ValidPNames = strings(1,0);
            for k = 1:numel(PhaseNameProperty)
                CurrentName = strtrim(PhaseNameProperty(k));
                if ~isempty(regexp(char(CurrentName),'^P\d+$','once'))
                    ValidPNames(end+1) = CurrentName;
                end
            end
            ValidPNames = unique(ValidPNames,'stable');
            if numel(ValidPNames) >= NoPhPWS
                IsPNumberPhase = true;
                FirstWindingNames = ValidPNames(1:NoPhPWS);
            end
        end
        if NoWS == 1 && ~IsPNumberPhase && ~isempty(PhaseNameProperty)
            FirstPhaseNumber = regexp(char(PhaseNameProperty(1)),'\d+$','match','once');
            if isempty(FirstPhaseNumber)
                FirstPhaseNumber = "";
            end
            for k = 1:numel(PhaseNameProperty)
                CurrentName = strtrim(PhaseNameProperty(k));
                CurrentNumber = regexp(char(CurrentName),'\d+$','match','once');
                if isempty(CurrentNumber)
                    CurrentNumber = "";
                end
                if strcmp(CurrentNumber,FirstPhaseNumber)
                    FirstWindingNames(end+1) = CurrentName;
                end
            end
            FirstWindingNames = unique(FirstWindingNames,'stable');
            if numel(FirstWindingNames) > NoPhPWS
                FirstWindingNames = FirstWindingNames(1:NoPhPWS);
            end
            if ~isempty(FirstWindingNames)
                KeepSlot = false(1,NoS);
                for k = 1:NoS
                    if SlotUsed(k) && any(FirstWindingNames == UpPhase(k))
                        KeepSlot(k) = true;
                    end
                end
                SlotUsed = KeepSlot;
                UpPhase(~SlotUsed) = "";
                UpSign(~SlotUsed) = "";
            end
        end
        if NoWS == 1
            DisplayPhaseNames = FirstWindingNames;
        else
            DisplayPhaseNames = unique(UpPhase(SlotUsed),'stable');
        end
        if isempty(DisplayPhaseNames)
            error('No valid winding phase names were found in Conductor Table.');
        end
        if IsPNumberPhase
            BasePhaseNames = DisplayPhaseNames;
        else
            BasePhaseNames = strings(1,numel(DisplayPhaseNames));
            for k = 1:numel(DisplayPhaseNames)
                BasePhaseNames(k) = regexprep(DisplayPhaseNames(k),'\d+$','');
            end
            BasePhaseNames = unique(BasePhaseNames,'stable');
        end
        if numel(BasePhaseNames) < NoPhPWS
            if NoPhPWS == 3
                DefaultBaseNames = ["A","B","C"];
            else
                DefaultBaseNames = strings(1,NoPhPWS);
                for k = 1:NoPhPWS
                    if k <= 26
                        DefaultBaseNames(k) = string(char('A'+k-1));
                    else
                        DefaultBaseNames(k) = "P"+string(k);
                    end
                end
            end
            for k = 1:NoPhPWS
                if ~any(BasePhaseNames == DefaultBaseNames(k))
                    BasePhaseNames(end+1) = DefaultBaseNames(k);
                end
            end
        end
        if numel(BasePhaseNames) > NoPhPWS
            BasePhaseNames = BasePhaseNames(1:NoPhPWS);
        end
        PhaseColor = lines(NoPhPWS);
        BeltCount = 2*NoPhPWS;
        BeltWidth = 180/NoPhPWS;
        if NoPhPWS == 3
            BeltPhaseIndex = [1 3 2 1 3 2];
            BeltSign = ["+" "-" "+" "-" "+" "-"];
        else
            BeltPhaseIndex = [1:NoPhPWS 1:NoPhPWS];
            BeltSign = [repmat("+",1,NoPhPWS) repmat("-",1,NoPhPWS)];
        end
        BeltName = strings(1,BeltCount);
        
        if NoWS == 1
            for k = 1:BeltCount
                PhaseIndex = BeltPhaseIndex(k);
                if PhaseIndex <= numel(DisplayPhaseNames)
                    BeltName(k) = DisplayPhaseNames(PhaseIndex)+BeltSign(k);
                else
                    BeltName(k) = BasePhaseNames(PhaseIndex)+BeltSign(k);
                end
            end
        else
            for k = 1:BeltCount
                BeltName(k) = BasePhaseNames(BeltPhaseIndex(k))+BeltSign(k);
            end
        end
        ReferenceAngle = BeltWidth/2;
        BeltBoundaryAngle = mod(ReferenceAngle-BeltWidth/2+(0:BeltCount)*BeltWidth,360);
        SlotBeltIndex = zeros(1,NoS);
        for k = 1:NoS
            if ~SlotUsed(k)
                continue;
            end
            RelativeAngle = mod(SlotAngMod(k)-ReferenceAngle+BeltWidth/2,360);
            BeltIndex = floor(RelativeAngle/BeltWidth)+1;
            BeltIndex = min(max(BeltIndex,1),BeltCount);
            SlotBeltIndex(k) = BeltIndex;
        end
        TextCenterAngle = nan(1,BeltCount);
        TextPhaseName = strings(1,BeltCount);
        for k = 1:BeltCount
            PhaseIndex = BeltPhaseIndex(k);
            SignValue = BeltSign(k);
            BaseTarget = BasePhaseNames(PhaseIndex);
            if NoWS == 1
                if PhaseIndex > numel(FirstWindingNames)
                    continue;
                end
                TargetNames = FirstWindingNames(PhaseIndex);
                TextPhaseName(k) = TargetNames+SignValue;
                Index = find(UpPhase == TargetNames & UpSign == SignValue);
            else
                TargetNames = DisplayPhaseNames(contains(DisplayPhaseNames,BaseTarget));
                if isempty(TargetNames)
                    continue;
                end
                Index = find(ismember(UpPhase,TargetNames) & UpSign == SignValue);
                TextPhaseName(k) = BaseTarget+SignValue;
            end
            if isempty(Index)
                continue;
            end
            Ang = SlotAngMod(Index);
            VectorSum = sum(exp(1j*deg2rad(Ang)));
            if abs(VectorSum) > 1e-12
                TextCenterAngle(k) = mod(rad2deg(angle(VectorSum)),360);
            else
                AngDiff = abs(mod(Ang-Ang(1)+180,360)-180);
                [~,RefIndex] = min(AngDiff);
                TextCenterAngle(k) = Ang(RefIndex);
            end
        end
        fig = figure('Name','Star of Slots',...
            'NumberTitle','off',...
            'Units','centimeters',...
            'Position',[0 0 12 12],...
            'Color','w',...
            'Resize','off');
        movegui(fig,'center');
        ax = axes('Parent',fig,...
            'Units','normalized',...
            'Position',[0.01 0.01 0.98 0.98]);
        hold(ax,'on');
        axis(ax,'equal');
        axis(ax,'off');
        RSlotCircle = 1.00;
        RVector = 0.82;
        RBeltText = 0.40;
        RSlotTextBase = 1.08;
        RSlotTextStep = 0.12;
        ROuter = 1.18;
        th = linspace(0,2*pi,720);
        plot(ax,...
            RSlotCircle*cos(th),...
            RSlotCircle*sin(th),...
            'k-',...
            'LineWidth',0.8);
        for k = 1:BeltCount
            theta = deg2rad(BeltBoundaryAngle(k));
            plot(ax,...
                [0 RSlotCircle*cos(theta)],...
                [0 RSlotCircle*sin(theta)],...
                '-',...
                'Color',[0.68 0.68 0.68],...
                'LineWidth',0.65);
        end
        for k = 1:BeltCount
            if isnan(TextCenterAngle(k))
                continue;
            end
            theta = deg2rad(TextCenterAngle(k));
            PhaseIndex = BeltPhaseIndex(k);
            BaseColor = PhaseColor(PhaseIndex,:);
            if BeltSign(k) == "-"
                TextColor = 0.65*BaseColor+0.35;
            else
                TextColor = BaseColor;
            end
            text(ax,...
                RBeltText*cos(theta),...
                RBeltText*sin(theta),...
                char(TextPhaseName(k)),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'FontName','Times New Roman',...
                'FontSize',9,...
                'FontWeight','bold',...
                'Color',TextColor);
        end
        for k = 1:NoS
            if ~SlotUsed(k)
                continue;
            end
            if IsPNumberPhase
                BaseName = UpPhase(k);
            else
                BaseName = regexprep(UpPhase(k),'\d+$','');
            end
            PhaseIndex = find(BasePhaseNames == BaseName,1);
            if isempty(PhaseIndex)
                continue;
            end
            theta = deg2rad(SlotAngMod(k));
            if UpSign(k) == "-"
                quiver(ax,...
                    0,0,...
                    RVector*cos(theta),...
                    RVector*sin(theta),...
                    0,...
                    'Color',PhaseColor(PhaseIndex,:),...
                    'LineWidth',1.15,...
                    'MaxHeadSize',0.15,...
                    'LineStyle','--');
            else
                quiver(ax,...
                    0,0,...
                    RVector*cos(theta),...
                    RVector*sin(theta),...
                    0,...
                    'Color',PhaseColor(PhaseIndex,:),...
                    'LineWidth',1.30,...
                    'MaxHeadSize',0.16,...
                    'LineStyle','-');
            end
        end
        LayerIndex = zeros(1,NoS);
        LayerAngle = zeros(1,NoS);
        AngleTol = max(1e-8,1e-7*max(1,max(abs(SlotAngMod))));
        UniqueAngles = [];
        NLayer = 0;
        for k = 1:NoS
            if ~SlotUsed(k)
                continue;
            end
            CurrentAngle = SlotAngMod(k);
            if isempty(UniqueAngles)
                Delta = [];
            else
                Delta = abs(mod(CurrentAngle-UniqueAngles+180,360)-180);
            end
            Index = find(Delta < AngleTol,1);
            if isempty(Index)
                NLayer = NLayer+1;
                UniqueAngles(NLayer) = CurrentAngle;
                LayerIndex(k) = 1;
                LayerAngle(k) = CurrentAngle;
            else
                SameAngleSlots = find(abs(mod(SlotAngMod-CurrentAngle+180,360)-180) < AngleTol & SlotUsed);
                LayerIndex(k) = numel(SameAngleSlots)+1;
                LayerAngle(k) = CurrentAngle;
            end
        end
        MaxLayer = max(LayerIndex);
        ExpectedLayer = gcd(NoS,round(2*NoPP));
        if MaxLayer > ExpectedLayer
            warning('The number of repeated slot-vector layers (%d) is larger than the expected value (%d).',MaxLayer,ExpectedLayer);
        end
        for k = 1:NoS
            if LayerIndex(k) <= 0 || ~SlotUsed(k)
                continue;
            end
            theta = deg2rad(LayerAngle(k));
            RText = RSlotTextBase+(LayerIndex(k)-1)*RSlotTextStep;
            text(ax,...
                RText*cos(theta),...
                RText*sin(theta),...
                sprintf('%d',k),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle',...
                'FontName','Times New Roman',...
                'FontSize',12,...
                'Color',[0.15 0.15 0.15]);
        end
        xlim(ax,[-ROuter ROuter]);
        ylim(ax,[-ROuter ROuter]);
        set(ax,...
            'FontName','Times New Roman',...
            'FontSize',12);
        hold(ax,'off');
    end
    %% Output part of winding parameters and results.
    function exportWindingData(obj)
        NoPs = obj.NoPs;
        NoS = obj.NoS;
        NoWL = obj.NoWL;
        NoWS = obj.NoWS;
        NoPhPWS = obj.NoPhPWS;
        CoilTable = obj.CoilTable;
        Kd = obj.Kd(:).';
        Kp = obj.Kp(:).';
        Kw = obj.Kw(:).';
        SlotMMF = obj.SlotMMF(:,1).';
        SlotMMFHar = obj.SlotMMFHar;
        filename = sprintf('%dPoles%dSlots%dLayer%dSet%dPhase.txt',NoPs,NoS,NoWL,NoWS,NoPhPWS);
        filepath = fullfile(pwd,filename);
        fid = fopen(filepath,'w','n','UTF-8');
        if fid == -1
            error('Failed to create file: %s',filepath);
        end
        cleanupObj = onCleanup(@() fclose(fid));
        DataMeaning = {'Number of pole pairs','Number of stator slots','Number of winding layers','Number of winding sets','Number of phases per winding set','Coil table','Distribution factor','Pitch factor','Winding factor','Slot MMF','Slot MMF harmonics'};
        DataValue = {NoPs,NoS,NoWL,NoWS,NoPhPWS,CoilTable,Kd,Kp,Kw,SlotMMF,SlotMMFHar};
        for k = 1:numel(DataMeaning)
            Meaning = DataMeaning{k};
            Value = DataValue{k};
            if isempty(Value)
                fprintf(fid,'%s\n',Meaning);
                continue
            end
            if k == 6
                if istable(Value)
                    Value = table2cell(Value);
                elseif isnumeric(Value)
                    Value = num2cell(Value);
                elseif isstring(Value)
                    Value = cellstr(Value);
                end
                nRow = size(Value,1);
                nCol = size(Value,2);
                for i = 1:nRow
                    if i == 1
                        fprintf(fid,'%s',Meaning);
                    else
                        fprintf(fid,'');
                    end
                    for j = 1:nCol
                        fprintf(fid,'\t');
                        Item = Value{i,j};
                        if isnumeric(Item)
                            if isempty(Item)
                                fprintf(fid,'');
                            elseif isfinite(Item) && Item == fix(Item)
                                fprintf(fid,'%s',sprintf('%d',round(Item)));
                            else
                                fprintf(fid,'%s',sprintf('%.3f',Item));
                            end
                        elseif islogical(Item)
                            fprintf(fid,'%s',sprintf('%d',Item));
                        elseif ischar(Item) || isstring(Item)
                            fprintf(fid,'%s',string(Item));
                        else
                            fprintf(fid,'%s',string(Item));
                        end
                    end
                    fprintf(fid,'\n');
                end
            elseif iscell(Value)
                nRow = size(Value,1);
                nCol = size(Value,2);
                for i = 1:nRow
                    if i == 1
                        fprintf(fid,'%s',Meaning);
                    else
                        fprintf(fid,'');
                    end
                    for j = 1:nCol
                        fprintf(fid,'\t');
                        Item = Value{i,j};
                        if isnumeric(Item)
                            if isempty(Item)
                                fprintf(fid,'');
                            elseif isfinite(Item) && Item == fix(Item)
                                fprintf(fid,'%s',sprintf('%d',round(Item)));
                            else
                                fprintf(fid,'%s',sprintf('%.3f',Item));
                            end
                        elseif islogical(Item)
                            fprintf(fid,'%s',sprintf('%d',Item));
                        elseif ischar(Item) || isstring(Item)
                            fprintf(fid,'%s',string(Item));
                        else
                            fprintf(fid,'%s',string(Item));
                        end
                    end
                    fprintf(fid,'\n');
                end
            elseif isnumeric(Value) || islogical(Value)
                nRow = size(Value,1);
                nCol = size(Value,2);
                for i = 1:nRow
                    if i == 1
                        fprintf(fid,'%s',Meaning);
                    else
                        fprintf(fid,'');
                    end
                    for j = 1:nCol
                        fprintf(fid,'\t');
                        Item = Value(i,j);
                        if islogical(Item)
                            fprintf(fid,'%s',sprintf('%d',Item));
                        elseif isinteger(Item)
                            fprintf(fid,'%s',sprintf('%d',Item));
                        elseif isfloat(Item)
                            if isfinite(Item) && Item == fix(Item)
                                fprintf(fid,'%s',sprintf('%d',round(Item)));
                            else
                                fprintf(fid,'%s',sprintf('%.3f',Item));
                            end
                        else
                            fprintf(fid,'%s',sprintf('%g',Item));
                        end
                    end
                    fprintf(fid,'\n');
                end
            elseif ischar(Value) || isstring(Value)
                nRow = size(Value,1);
                nCol = size(Value,2);
                for i = 1:nRow
                    if i == 1
                        fprintf(fid,'%s',Meaning);
                    else
                        fprintf(fid,'');
                    end
                    for j = 1:nCol
                        fprintf(fid,'\t%s',string(Value(i,j)));
                    end
                    fprintf(fid,'\n');
                end
            else
                fprintf(fid,'%s\t%s\n',Meaning,string(Value));
            end
        end
    end
end
end