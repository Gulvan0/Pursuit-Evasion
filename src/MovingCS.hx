package;

import hxmath.math.Matrix2x2;
import hxmath.math.Vector2;

class MovingCS 
{
    public static var phi:Float;
    private static var sinphi:Float;
    private static var cosphi:Float;
    
    public static function set(ePos:Vector2, pPos:Vector2) 
    {
        phi = (ePos - pPos).angle;
        sinphi = Math.sin(phi);
        cosphi = Math.cos(phi);
    }

    public static function toRelative(v:Vector2):Vector2
    {
        var rotationMatrix:Matrix2x2 = Matrix2x2.fromArray([cosphi, -sinphi, sinphi, cosphi]);
        return rotationMatrix * v;
    }

    public static function toAbsolute(v:Vector2):Vector2
    {
        var rotationMatrix:Matrix2x2 = Matrix2x2.fromArray([cosphi, sinphi, -sinphi, cosphi]);
        return rotationMatrix * v;
    }
}