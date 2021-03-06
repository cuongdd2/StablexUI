package ru.stablex.ui.misc;

import flash.display.DisplayObject;
import flash.text.TextField;
import ru.stablex.ui.widgets.Widget;


/**
* Size calculations required due to some platforms inconsistency
*
*/
class SizeTools {


    /**
    * Get object width
    *
    */
    static public inline function width (obj:DisplayObject) : Float {
        // #if html5
            if( Std.is(obj, Widget) ){
                return cast(obj, Widget).w;
            }else if( Std.is(obj, TextField) ){
        if (obj.name == 'test') {
            trace(cast(obj, TextField).textWidth);
        }
                return cast(obj, TextField).textWidth + 4;
            }else{
                return obj.width;
            }
    }//function width()


    /**
    * Get object height
    *
    */
    static public inline function height (obj:DisplayObject) : Float {
        if( Std.is(obj, Widget) ){
            return cast(obj, Widget).h;
        }else if( Std.is(obj, TextField) ){
            return cast(obj, TextField).textHeight + 4;
        }else{
            return obj.height;
        }
    }//function height()


    /**
    * Set object x
    *
    */
    static public inline function setX (obj:DisplayObject, x:Float) : Void {
        #if html5
            obj.x = (Std.is(obj, TextField) ? obj.x = x + 2 : x);
        #else
            obj.x = x;
        #end
    }//function setX()


    /**
    * Set object y
    *
    */
    static public inline function setY (obj:DisplayObject, y:Float) : Void {
        #if html5
            obj.y = (Std.is(obj, TextField) ? obj.y = y + 2 : y);
        #else
            obj.y = y;
        #end
    }//function setY()

}//class SizeTools