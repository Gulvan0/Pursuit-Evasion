package;

import hxmath.math.Vector2;

class FinishConditions 
{
    public static var check:Vector2->Vector2->Int;
    
    public static function simple(epos:Vector2, ppos:Vector2):Int
    {
        return epos.distanceTo(ppos) > Main.A - Main.B? 0 : -1;
    }

    public static function lifeline(safeZoneCondition:Vector2->Bool, epos:Vector2, ppos:Vector2):Int
    {
        return safeZoneCondition(epos)? 1 : (epos.distanceTo(ppos) > Main.A - Main.B? 0 : -1);
    }
}