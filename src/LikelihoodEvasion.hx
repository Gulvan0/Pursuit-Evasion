package;

import hxmath.math.Vector2;

enum Phase
{
    Line;
    Approaching;
    Free;
}

class LikelihoodEvasion 
{
    public static var turnRadius:Float;
    public static var turnRadiusSq:Float;
    public static var b:Int;
    public static var c:Float;

    public static var phase:Phase;

    public static var minimumSteps:Int;
    public static var totalSteps:Int;
    public static var actualTurningRadius:Float;
    public static var rotationDir:Int;

    public static var currentStep:Int;


    public static function calcDistToBorder(ePos:Vector2, pPos:Vector2):Float
    {
        var E = ePos.length;
        var dr = ePos - pPos;
        var cosphi = -(ePos * dr / (E * dr.length));
        return E * cosphi + Math.sqrt(E * E * (cosphi * cosphi - 1) + Main.R * Main.R);
    }

    public static function setParams(ePos:Vector2, pPos:Vector2, a:Float, b:Int, c:Float) 
    {
        turnRadius = a * Main.R + (1 - a) * ePos.length;
        turnRadiusSq = turnRadius * turnRadius;
        LikelihoodEvasion.b = b;
        LikelihoodEvasion.c = c;
    }

    public static function init() 
    {
        phase = Line;    
    }

    public static function move(ePos:Vector2, pPos:Vector2):Vector2
    {
        switch phase 
        {
            case Line:
                if (ePos.lengthSq < turnRadiusSq)
                    return new Vector2(Main.B, 0);
                else 
                {
                    var dist = calcDistToBorder(ePos, pPos);
                    minimumSteps = Math.ceil(dist / Main.B);
                    totalSteps = minimumSteps + b * Math.floor(minimumSteps / 2);
                    actualTurningRadius = ePos.length;
                    rotationDir = ePos.signedAngleWith(pPos) > 0? -1 : 1;
                    currentStep = 0;

                    phase = Approaching;
                    return move(ePos, pPos);
                }
            case Approaching:
                var oldRadius = ePos.length;
                if (currentStep == totalSteps)
                {
                    phase = Free;
                    if (oldRadius < Main.R - Main.B)
                        return ePos.normalizeTo(Main.B);
                    else 
                        return move(ePos, pPos);
                }
                currentStep++;

                var newRadius = actualTurningRadius + (Main.R - actualTurningRadius) * Math.pow(currentStep / totalSteps, c);
                var newPos = ePos.clone();
                newPos.normalizeTo(newRadius);
                var cosBetween = (newRadius * newRadius + oldRadius * oldRadius - Main.B * Main.B)/(2 * newRadius * oldRadius);
                var angleBetween = cosBetween > 1? 0 : cosBetween < -1? Math.PI : Math.acos(cosBetween);
                newPos.rotate(rotationDir * angleBetween, Vector2.zero);

                return (newPos - ePos).normalizeTo(Main.B);
            case Free:
                return EvaderStrats.onBorder(ePos, pPos);
        }
    }
}