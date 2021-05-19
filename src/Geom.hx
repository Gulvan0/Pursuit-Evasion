package;

import hxmath.math.Matrix2x2;
import hxmath.math.Vector2;

class Geom 
{
    public static function circleIntersections(center1:Vector2, center2:Vector2, r1:Float, r2:Float):Array<Vector2>
    {
        var oo1 = center2 - center1;
        var d = oo1.length;
        var cosphi = (r1 * r1 + d * d - r2 * r2) / (2 * r1 * d);
        var sinphi = Math.sqrt(1 - cosphi * cosphi);
        var tildaA = new Vector2(r1 * cosphi, r1 * sinphi);
        var tildaB = new Vector2(r1 * cosphi, -r1 * sinphi);
        var psi = Math.atan2(oo1.y, oo1.x);
        var cospsi = Math.cos(psi);
        var sinpsi = Math.sin(psi);
        var rotationMatrix:Matrix2x2 = new Matrix2x2(cospsi, sinpsi, -sinpsi, cospsi);
        var hatA = rotationMatrix * tildaA;
        var hatB = rotationMatrix * tildaB;
        var A = hatA + center1;
        var B = hatB + center1;
        return [A, B];
    }

    public static function rayCircleIntersection(dir:Vector2, start:Vector2, radius:Float) 
    {
        var phi = Math.abs(start.signedAngleWith(dir));
        var psi = Math.PI - phi;
        var addend1 = start.length * Math.cos(psi);
        var addend2 = Math.sqrt(addend1 * addend1 - (start.lengthSq - radius * radius));
        var x1 = addend1 + addend2;
        var x2 = addend1 - addend2;
        var dirOrth = dir.normalize();
        if (x2 < 0)
            return start + dirOrth * x1;
        else if (x1 < 0)
            return start + dirOrth * x2;
        else if (x2 == 0)
            return start + dirOrth * x1;
        else
            return start + dirOrth * x2;
    }
    
    public static function randomPointInsideCircle(center:Vector2, r:Float):Vector2
    {
        var x = Math.random() * 2 * r + center.x - r;
        var height = Math.sqrt(r * r - x * x);
        var y = Math.random() * 2 * height + center.y - height;
        return Math.random() < 0.5? new Vector2(x, y) : new Vector2(y, x);
    }
}