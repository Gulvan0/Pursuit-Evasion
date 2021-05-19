package;

import hxmath.math.Vector2;

class PursuerStrats
{

    public static var lastDir:Null<Vector2>;
    public static var toggled:Bool = false;

    public static function simple(ePosRel:Vector2, pPosRel:Vector2, vRel:Vector2):Vector2
    {
        var dr = ePosRel + vRel - pPosRel;
        if (dr.lengthSq <= Main.A * Main.A)
            return dr;

        return dr.normalizeTo(Main.A);
    }

    public static function parallel(ePosRel:Vector2, pPosRel:Vector2, vRel:Vector2):Vector2
    {
        var dr = ePosRel + vRel - pPosRel;
        if (dr.lengthSq <= Main.A * Main.A)
            return dr;

        var uRelXSq = Main.A * Main.A - vRel.y * vRel.y;
        var uRel = new Vector2(Math.sqrt(uRelXSq), vRel.y);

        if (Demonstration.focalPoint(ePosRel, pPosRel, vRel, uRel).lengthSq <= Main.Rsq)
            return uRel;
        else 
        {
            var S = Geom.rayCircleIntersection(vRel, ePosRel, Main.R);
            var l0 = Math.floor(S.distanceTo(ePosRel) / Main.B);
            var S1 = ePosRel + l0 * vRel;
            return (S1 - pPosRel).normalizeTo(Main.A);
        }
    }

    public static function parallel2(ePosRel:Vector2, pPosRel:Vector2, vRel:Vector2):Vector2
    {
        var dr = ePosRel + vRel - pPosRel;
        if (dr.lengthSq <= Main.A * Main.A)
            return dr;

        var uRelXSq = Main.A * Main.A - vRel.y * vRel.y;
        var uRel = new Vector2(Math.sqrt(uRelXSq), vRel.y);

        if ((pPosRel + uRel).lengthSq <= Main.Rsq)
            return uRel;
        else 
        {
            var S = Geom.rayCircleIntersection(vRel, ePosRel, Main.R);
            var l0 = Math.floor(S.distanceTo(ePosRel) / Main.B);
            var S1 = ePosRel + l0 * vRel;
            return (S1 - pPosRel).normalizeTo(Main.A);
        }
    }

    public static function toggle(ePosRel:Vector2, pPosRel:Vector2, vRel:Vector2):Vector2
    {
        var dr = ePosRel + vRel - pPosRel;
        if (dr.lengthSq <= Main.A * Main.A)
            return dr;

        var uRelXSq = Main.A * Main.A - vRel.y * vRel.y;
        var uRel = new Vector2(Math.sqrt(uRelXSq), vRel.y);

        if ((pPosRel + uRel).lengthSq <= Main.Rsq/*Demonstration.focalPoint(ePosRel, pPosRel, vRel, uRel).lengthSq <= Main.Rsq*/)
        {
            if (lastDir != null && Math.abs(lastDir.signedAngleWith(uRel)) > 0.5 * Math.PI)
                uRel = (ePosRel - pPosRel).normalizeTo(Main.A);
            lastDir = uRel.clone();
            return uRel;
        }
        else 
        {
            var S = Geom.rayCircleIntersection(vRel, ePosRel, Main.R);
            var l0 = Math.floor(S.distanceTo(ePosRel) / Main.B);
            var S1 = ePosRel + l0 * vRel;
            return (S1 - pPosRel).normalizeTo(Main.A);
        }
    }

    public static function oneTimeToggle(ePosRel:Vector2, pPosRel:Vector2, vRel:Vector2):Vector2
    {
        if (toggled)
            return simple(ePosRel, pPosRel, vRel);

        var dr = ePosRel + vRel - pPosRel;
        if (dr.lengthSq <= Main.A * Main.A)
            return dr;

        var uRelXSq = Main.A * Main.A - vRel.y * vRel.y;
        var uRel = new Vector2(Math.sqrt(uRelXSq), vRel.y);

        if ((pPosRel + uRel).lengthSq <= Main.Rsq/*Demonstration.focalPoint(ePosRel, pPosRel, vRel, uRel).lengthSq <= Main.Rsq*/)
        {
            if (lastDir != null && Math.abs(lastDir.signedAngleWith(uRel)) > 0.5 * Math.PI)
            {
                toggled = true;
                return simple(ePosRel, pPosRel, vRel);
            }
            lastDir = uRel.clone();
            return uRel;
        }
        else 
        {
            var S = Geom.rayCircleIntersection(vRel, ePosRel, Main.R);
            var l0 = Math.floor(S.distanceTo(ePosRel) / Main.B);
            var S1 = ePosRel + l0 * vRel;
            return (S1 - pPosRel).normalizeTo(Main.A);
        }
    }
}