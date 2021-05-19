package;

import sys.io.File;
import Demonstration.PursuerStrategy;
import hxmath.math.Vector2;

typedef Node = 
{
	var dir:Int;
	var epos:Vector2;
	var ppos:Vector2;
	var next:Null<Map<Int, Node>>;
}

class Simulation 
{

    private static function calcMaxDist(node:Node):{dist:Float, branch:Null<Node>}
	{
		if (node.next == null)
			return {dist: (node.epos - node.ppos).lengthSq, branch: null};
		
		var currentMax:Float = Math.NEGATIVE_INFINITY;
		var currentArgmax:Null<Node> = null;
		for (branch in node.next)
		{
			var md = calcMaxDist(branch);
			if (md.dist > currentMax)
			{
				currentMax = md.dist;
				currentArgmax = branch;
			}
		}
		return {dist: currentMax, branch: currentArgmax};
	}

	private static function gatherLeaves(node:Node):Array<Node>
	{
		if (node.next == null)
			return [node];

		var a:Array<Node> = [];
		for (branch in node.next)
			a = a.concat(gatherLeaves(branch));
		return a;
    }
    
    //--------------------------------------------------------------------------------------------------------

	public static function parallelConditionComparison()
	{
		var s:String = "";
		for (a in 0...8)
			for (i in 1...9)
				for (j in 1...9)
				{
					if (a == 0 && i == j)
						continue;

					var epos:Vector2 = Vector2.fromPolar(a * Math.PI / 8, j * 25);
					var ppos:Vector2 = Vector2.fromPolar(0, i * 25);
					var t1 = 0;

                    while (epos.distanceTo(ppos) > Main.A - Main.B)
                    {
						MovingCS.set(epos, ppos);
						var erel = MovingCS.toRelative(epos);
                        var prel = MovingCS.toRelative(ppos);
						var vrel = EvaderStrats.withNoise(erel, prel);
						
                        ppos = MovingCS.toAbsolute(prel + PursuerStrats.parallel2(erel, prel, vrel));
						epos = MovingCS.toAbsolute(erel + vrel);
						
						t1++;
					}

					epos = Vector2.fromPolar(a * Math.PI / 4, j * 25);
					ppos = Vector2.fromPolar(0, i * 25);
					var t2 = 0;

                    while (epos.distanceTo(ppos) > Main.A - Main.B)
                    {
						MovingCS.set(epos, ppos);
						var erel = MovingCS.toRelative(epos);
                        var prel = MovingCS.toRelative(ppos);
						var vrel = EvaderStrats.withNoise(erel, prel);
						
                        ppos = MovingCS.toAbsolute(prel + PursuerStrats.parallel(erel, prel, vrel));
						epos = MovingCS.toAbsolute(erel + vrel);
						
						t2++;
					}
					
					s += '$t1	$t2\n';
				}
		File.saveContent("Q:\\Github\\pursuit\\Export\\results_par.txt", s);
	}

	public static function ratioTest()
	{
		var s:String = "";
		for (a in 0...8)
			for (i in 1...9)
				for (j in 1...9)
				{
					if (a == 0 && i == j)
						continue;

					var epos:Vector2 = Vector2.fromPolar(a * Math.PI / 8, j * 25);
					var ppos:Vector2 = Vector2.fromPolar(0, i * 25);
					var t1 = 0;

					trace(a, i, j);

                    while (epos.distanceTo(ppos) > Main.A - Main.B)
                    {
						MovingCS.set(epos, ppos);
						var erel = MovingCS.toRelative(epos);
                        var prel = MovingCS.toRelative(ppos);
						var vrel = EvaderStrats.simple(erel, prel);
						vrel = vrel.normalizeTo(Main.B);
						
                        ppos = MovingCS.toAbsolute(prel + PursuerStrats.parallel(erel, prel, vrel));
						epos = MovingCS.toAbsolute(erel + vrel);
						
						t1++;
					}

					epos = Vector2.fromPolar(a * Math.PI / 4, j * 25);
					ppos = Vector2.fromPolar(0, i * 25);
					var t2 = 0;

                    while (epos.distanceTo(ppos) > Main.A - Main.B)
                    {
						MovingCS.set(epos, ppos);
						var erel = MovingCS.toRelative(epos);
                        var prel = MovingCS.toRelative(ppos);
						var vrel = EvaderStrats.ratio(erel, prel);
						vrel = vrel.normalizeTo(Main.B);
						
                        ppos = MovingCS.toAbsolute(prel + PursuerStrats.parallel(erel, prel, vrel));
						epos = MovingCS.toAbsolute(erel + vrel);
						
						t2++;
					}
					
					s += '$t1	$t2\n';
				}
		File.saveContent("Q:\\Github\\pursuit\\Export\\results_ratio.txt", s);
	}
	
	public static function finiteDepthBruteForce(pursuerStrat:PursuerStrategy, ?startEPos:Vector2, ?startPPos:Vector2):Array<Vector2>
	{
		var evaderPosStart = startEPos != null? startEPos : Geom.randomPointInsideCircle(Vector2.zero, Main.R);
		var pursuerPosStart = startPPos != null? startPPos : Geom.randomPointInsideCircle(Vector2.zero, Main.R);
		
		var savedPath:Array<Vector2> = [];
		var kernel:Node = {epos: evaderPosStart, ppos: pursuerPosStart, dir: 0, next: null};
		var leaves:Array<Node> = [kernel];

		for (i in 0...Main.depth)
		{
			var newLeafCount = 0;
			for (leaf in leaves)
			{
				leaf.next = [];
				MovingCS.set(leaf.epos, leaf.ppos);
				var v = leaf.epos.clone().normalizeTo(Main.B);
				for (j in 0...Main.ndir)
				{
					var nextEPos = leaf.epos + v;
					if (nextEPos.lengthSq > Main.Rsq)
						continue;

					var nextPPos = leaf.ppos + MovingCS.toAbsolute(pursuerStrat(MovingCS.toRelative(leaf.epos), MovingCS.toRelative(leaf.ppos), MovingCS.toRelative(v)));
					if ((nextEPos - nextPPos).length < Main.A - Main.B)
						continue;

					var newLeaf:Node = {ppos: nextPPos, epos: nextEPos, dir: j, next: null};
					leaf.next[j] = newLeaf;
					newLeafCount++;

					v.rotate(Main.sectorAngle, Vector2.zero);
				}
			}

			if (newLeafCount == 0)
				return convertToPresription(evaderPosStart, savedPath);

			if (i >= Main.bufferSize)
			{
				var mddata = calcMaxDist(kernel);
				savedPath.push(mddata.branch.epos);
				kernel = mddata.branch;
			}

			leaves = gatherLeaves(kernel);
			trace(i);
		}

		return convertToPresription(evaderPosStart, savedPath);
	}

	public static function likelyFitting(pursuerStrat:PursuerStrategy, startEPos:Vector2, startPPos:Vector2):Array<Vector2>
	{
        var aValues:Array<Float> = [for (i in 0...10) i / 10];
        var bValues:Array<Int> = [for (j in 0...10) j];
        var cValues:Array<Float> = [1/2, 2/3, 3/4, 3/5, 4/5, 5/6, 7/8, 1, 1.5, 2, 2.5, 3, 3.5, 4];

        var aOptimal:Float = 0;
        var bOptimal:Int = 0;
        var cOptimal:Float = 0;
        var optimalT:Int = 0;
        var optimalVs:Array<Vector2> = [];

        for (a in aValues)
            for (b in bValues)
                for (c in cValues)
                {
                    LikelihoodEvasion.setParams(startEPos, startPPos, a, b, c);
                    LikelihoodEvasion.init();

                    var epos:Vector2 = startEPos.clone();
                    var ppos:Vector2 = startPPos.clone();
                    var vs:Array<Vector2> = [];

                    while (epos.distanceTo(ppos) > Main.A - Main.B)
                    {
						MovingCS.set(epos, ppos);
						var erel = MovingCS.toRelative(epos);
                        var prel = MovingCS.toRelative(ppos);
						var vrel = LikelihoodEvasion.move(erel, prel);
						vrel = vrel.normalizeTo(Main.B);
						
						vs.push(MovingCS.toAbsolute(vrel));
						
						epos = MovingCS.toAbsolute(erel + vrel);
                        ppos = MovingCS.toAbsolute(prel + pursuerStrat(erel, prel, vrel));
                    }

                    if (vs.length > optimalT)
                    {
                        aOptimal = a;
                        bOptimal = b;
                        cOptimal = c;
                        optimalT = vs.length;
                        optimalVs = vs;
                    }
                    trace(a, b, c);
				}

        trace("Optimal: ", aOptimal, bOptimal, cOptimal);
		trace("Optimal t: ", optimalT);
		return optimalVs;
	}

    private static function convertToPresription(startPos:Vector2, bruteResult:Array<Vector2>):Array<Vector2>
    {
        var result:Array<Vector2> = [];
        var pos:Vector2 = startPos.clone();

        for (epos in bruteResult)
        {
            var v = epos - pos;
            result.push(v);
            pos = epos;
        }

        return result;
    }    
}