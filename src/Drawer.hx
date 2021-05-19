package;

import hxmath.math.Vector2;
import openfl.system.Capabilities;
import openfl.geom.Point;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

enum PointType
{
    Pursuer;
    Evader;
    Focal;
}

enum TrajType
{
    Pursuer;
    Evader;
}

class Drawer
{
    public static function drawPoint(type:PointType, addOnto:DisplayObjectContainer):Sprite
    {
        var color = switch type 
        {
            case Pursuer: 0x00FFFF;
            case Evader: 0xFFFF00;
            case Focal: 0x00FF00;
        }

        var point:Sprite = new Sprite();
		point.graphics.beginFill(color);
        point.graphics.drawCircle(0, 0, 4);
        addOnto.addChild(point);
        return point;
    }

    public static function drawTraj(type:TrajType, start:Vector2, bg:Sprite, addOnto:DisplayObjectContainer):Sprite
    {
        var color = switch type 
        {
            case Pursuer: 0x0000FF;
            case Evader: 0xFF0000;
        }

        var traj:Sprite = new Sprite();
		traj.x = bg.x;
		traj.y = bg.y;
		traj.graphics.lineStyle(3, color, 0.5);
		traj.graphics.moveTo(start.x, start.y);

        addOnto.addChild(traj);
        return traj;
    }

    public static function drawBG():Sprite
    {
        var bg:Sprite = new Sprite();
		bg.x = Capabilities.screenResolutionX / 2;
		bg.y = Capabilities.screenResolutionY / 2;
		bg.graphics.lineStyle(4, 0x000000);
		bg.graphics.drawCircle(0, 0, Main.R);
		return bg;
    }
}