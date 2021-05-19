package;

import Demonstration.PursuerStrategy;
import Demonstration.EvaderStrategy;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import hxmath.math.Vector2;
import openfl.display.Sprite;

enum Mode
{
	Absolute;
	Relative;
	Prescripted;
}

class Main extends Sprite
{
	public static var R:Float = 250;
	public static var A:Float = 4;
	public static var B:Float = 3.5;

	public static var ndir = 8;
	public static var depth = 500;
	public static var bufferSize = 3;
	
	public static var Rsq:Float = R * R;
	public static var sectorAngle:Float = 2 * Math.PI / ndir;
	
	public function initGraphic(eStrat:EvaderStrategy, pStrat:PursuerStrategy, mode:Mode, ?startEPos:Vector2, ?startPPos:Vector2, ?prescriptedV:Array<Vector2>) 
	{
		var evaderPos = startEPos != null? startEPos : Geom.randomPointInsideCircle(Vector2.zero, R);
		var pursuerPos = startPPos != null? startPPos : Geom.randomPointInsideCircle(Vector2.zero, R);

		var demo:Demonstration = new Demonstration(evaderPos, pursuerPos);

		var bg:Sprite = Drawer.drawBG();
		addChild(bg);

		demo.focal = Drawer.drawPoint(Focal, bg);
		demo.evader = Drawer.drawPoint(Evader, bg);
		demo.pursuer = Drawer.drawPoint(Pursuer, bg);

		demo.evaderTraj = Drawer.drawTraj(Evader, evaderPos, bg, this);
		demo.pursuerTraj = Drawer.drawTraj(Pursuer, pursuerPos, bg, this);

		var onPress:KeyboardEvent->Void;

		onPress = (e) ->
		{
			if (e.keyCode != Keyboard.ENTER)
				return;

			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onPress);
			switch mode 
			{
				case Absolute: demo.initAbs(eStrat, pStrat);
				case Relative: demo.initRel(eStrat, pStrat);
				case Prescripted: demo.initPresc(prescriptedV, pStrat);
			}
		};

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
	}

	public function new()
	{
		super();
		//For random start positions:
		var evaderPosStart = Geom.randomPointInsideCircle(Vector2.zero, R);
		var pursuerPosStart = Geom.randomPointInsideCircle(Vector2.zero, R);
		//For fixed start positions (fromPolar args can be replaced):
		/*var evaderPosStart = Vector2.fromPolar(Math.PI, 0);
		var pursuerPosStart = Vector2.fromPolar(-2, 7 * 25);*/

		//For optimization over the likely strategies (same goes for brute force simulation):
		var vs = Simulation.likelyFitting(PursuerStrats.parallel, evaderPosStart, pursuerPosStart);
		initGraphic(EvaderStrats.simple, PursuerStrats.parallel, Prescripted, evaderPosStart, pursuerPosStart, vs);

		//To test one of the likely strategies:
		/*LikelihoodEvasion.setParams(evaderPosStart, pursuerPosStart, 0.1, 5, 2);
        LikelihoodEvasion.init();
		initGraphic(LikelihoodEvasion.move, PursuerStrats.parallel, Relative, evaderPosStart, pursuerPosStart);*/

		//Just to simulate the usage of the two fixed strategies:
		//initGraphic(EvaderStrats.simple, PursuerStrats.parallel, Relative, evaderPosStart, pursuerPosStart);

		//To gather experimental data (ratio() efficiency test or parallel() vs parallel2()):
		//Simulation.ratioTest();
		
	}	
}
