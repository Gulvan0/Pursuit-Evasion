package;

import openfl.display.Sprite;
import hxmath.math.Vector2;
import haxe.Timer;

typedef EvaderStrategy = (ePos:Vector2, pPos:Vector2) -> Vector2;
typedef PursuerStrategy = (ePos:Vector2, pPos:Vector2, v:Vector2) -> Vector2;

class Demonstration
{
    private var t:Timer;
    private var time:Int;
    private var evaderPos:Vector2;
    private var pursuerPos:Vector2;
    private var focalPos:Vector2;

    public var evader:Sprite;
    public var pursuer:Sprite;
    public var focal:Sprite;
    public var evaderTraj:Sprite;
    public var pursuerTraj:Sprite;
    
    private function tickRelative(eStrat:EvaderStrategy, pStrat:PursuerStrategy) 
    {
        MovingCS.set(evaderPos, pursuerPos);

		var oldRelEPos = MovingCS.toRelative(evaderPos);
        var oldRelPPos = MovingCS.toRelative(pursuerPos);
        
        var vRel:Vector2 = eStrat(oldRelEPos, oldRelPPos);
        var uRel:Vector2 = pStrat(oldRelEPos, oldRelPPos, vRel);
        
        vRel = vRel.normalizeTo(Main.B);
		var newRelEPos = oldRelEPos + vRel;
        var newRelPPos = oldRelPPos + uRel;
        var relFocalPos = focalPoint(oldRelEPos, oldRelPPos, vRel, uRel);
        
		evaderPos = MovingCS.toAbsolute(newRelEPos);
        pursuerPos = MovingCS.toAbsolute(newRelPPos);
		focalPos = MovingCS.toAbsolute(relFocalPos);
        
        update(evaderPos, pursuerPos, focalPos);
    }

    private function tickAbsolute(eStrat:EvaderStrategy, pStrat:PursuerStrategy) 
    {
        var v:Vector2 = eStrat(evaderPos, pursuerPos);
        var u:Vector2 = pStrat(evaderPos, pursuerPos, v);
        
        evaderPos += v;
        pursuerPos += u;
        focalPos = focalPoint(evaderPos, pursuerPos, v, u);

        update(evaderPos, pursuerPos, focalPos);
    }

    private function tickPrescripted(eStrat:Array<Vector2>, pStrat:PursuerStrategy) 
    {
        if (time + 1 >= eStrat.length)
            t.stop();

        MovingCS.set(evaderPos, pursuerPos);

		var oldRelEPos = MovingCS.toRelative(evaderPos);
        var oldRelPPos = MovingCS.toRelative(pursuerPos);

        var v:Vector2 = eStrat[time];
        var vRel:Vector2 = MovingCS.toRelative(v);
        var uRel:Vector2 = pStrat(oldRelEPos, oldRelPPos, vRel);
        
        var newRelPPos = oldRelPPos + uRel;
        var relFocalPos = focalPoint(oldRelEPos, oldRelPPos, vRel, uRel);
        
		evaderPos += v;
        pursuerPos = MovingCS.toAbsolute(newRelPPos);
		focalPos = MovingCS.toAbsolute(relFocalPos);
        
        update(evaderPos, pursuerPos, focalPos);
    }

    private function update(evaderPos:Vector2, pursuerPos:Vector2, focalPos:Vector2) 
    {
        evaderTraj.graphics.lineTo(evaderPos.x, evaderPos.y);
		evader.x = evaderPos.x;
        evader.y = evaderPos.y;
        
		pursuerTraj.graphics.lineTo(pursuerPos.x, pursuerPos.y);
		pursuer.x = pursuerPos.x;
        pursuer.y = pursuerPos.y;

		focal.x = focalPos.x;
		focal.y = focalPos.y;
        
        if (evaderPos.distanceTo(pursuerPos) <= Main.A - Main.B)
            t.stop();
		time += 1;
    }

    public function initRel(eStrat:EvaderStrategy, pStrat:PursuerStrategy) 
    {
        t = new Timer(100);
        t.run = tickRelative.bind(eStrat, pStrat);
    }

    public function initAbs(eStrat:EvaderStrategy, pStrat:PursuerStrategy) 
    {
        t = new Timer(100);
        t.run = tickAbsolute.bind(eStrat, pStrat);
    }

    public function initPresc(eStrat:Array<Vector2>, pStrat:PursuerStrategy) 
    {
        t = new Timer(100);
        t.run = tickPrescripted.bind(eStrat, pStrat);
    }

    public function new(eStartPos:Vector2, pStartPos:Vector2) 
    {
        time = 0;
        evaderPos = eStartPos.clone();
        pursuerPos = pStartPos.clone();
    }

    public static function focalPoint(ePos:Vector2, pPos:Vector2, v:Vector2, u:Vector2):Vector2
    {
        var T:Float = (ePos.x - pPos.x) / (u.x - v.x);
        return ePos + T * v;
    }
}