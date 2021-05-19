package;

import Demonstration.EvaderStrategy;
import hxmath.math.Vector2;

class EvaderStrats 
{
    public static var lastCornerDir:Null<Int>;

    public static function simple(ePosRel:Vector2, pPosRel:Vector2):Vector2
    {
        var v = new Vector2(Main.B, 0);
        if ((ePosRel + v).lengthSq <= Main.Rsq)
            return v;
        else 
            return onBorder(ePosRel, pPosRel);
    }

    public static function onBorder(ePosRel:Vector2, pPosRel:Vector2):Vector2
    {
        var candidates = Geom.circleIntersections(Vector2.zero, ePosRel, Main.R, Main.B);
        var dir = candidates[0].x > candidates[1].x? 0 : 1;
        var destination = candidates[dir];
        return destination - ePosRel;
    }

    public static function onBorderStubborn(ePosRel:Vector2, pPosRel:Vector2):Vector2
    {
        var candidates = Geom.circleIntersections(Vector2.zero, ePosRel, Main.R, Main.B);
        if (lastCornerDir == null)
            lastCornerDir = candidates[0].x > candidates[1].x? 0 : 1;
        for (i in 0...2)
            if (candidates[i].distanceTo(pPosRel) <= Main.A)
                lastCornerDir = 1 - i;
        var destination = candidates[lastCornerDir];
        return destination - ePosRel;
    }

    public static function ratio(ePosRel:Vector2, pPosRel:Vector2) 
    {
        var dr = ePosRel - pPosRel;
        var expectedCollision = Geom.rayCircleIntersection(dr, ePosRel, Main.R);
        var d = (expectedCollision - ePosRel).length;

        if (ePosRel.length > Main.R - Main.B)
            return simple(ePosRel, pPosRel);

        var ro = dr.length;
        var phi = expectedCollision.signedAngleWith(dr);
        var psi = (Math.PI / 2 - phi) * (1 - 1 / (1 + ro / (0.01 *d)));
        var unnormalized = dr.clone().rotate(psi, Vector2.zero);
        return unnormalized.normalizeTo(Main.B);
    }

    public static function withNoise(ePosRel:Vector2, pPosRel:Vector2) 
    {
        var angleIntervalRadius:Float = Math.PI / 3;
        var v = simple(ePosRel, pPosRel);
        var rnd = Math.random();

        if (ePosRel.lengthSq < (Main.R - Main.B)*(Main.R - Main.B))
            if (rnd < 0.5)
                return v.clone().rotate(angleIntervalRadius * (Math.sqrt(2 * rnd) - 1), Vector2.zero);
            else 
                return v.clone().rotate(angleIntervalRadius * (1 - Math.sqrt(2 * (1 - rnd))), Vector2.zero);
        else 
            return v;
    }
}