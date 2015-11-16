package ru.stablex.ui.widgets;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import ru.stablex.ui.events.WidgetEvent;


/**
* Slider implementation.
*
* @dispatch <type>ru.stablex.ui.events.WidgetEvent</type>.CHANGE - on change value
*/
class Slider extends Widget{
    //Minimum value
    public var min : Float = -100;
    //Maximum value
    public var max : Float = 100;
    //Current value
    public var value (get_value,set_value) : Float;
    private var _value : Float = 0;
    //Step change in the value
	public var step (get_step,set_step) : Float;
	private var _step : Float = 0;
    //Slider element
    public var slider : Widget;
    //Whether this slider is vertical or horizontal
    public var vertical : Bool = false;


    /**
    * Constructor
    *
    */
    public function new () : Void {
        super();

        this.slider = UIBuilder.create(Widget);
        this.addChild(this.slider);

        this.slider.addEventListener(MouseEvent.MOUSE_DOWN, this._slide);
        this.addEventListener(MouseEvent.CLICK, this._set);
    }//function new()


    /**
    * Getter for `.value`
    *
    */
    @:noCompletion private function get_value () : Float {
        return (
            this._value < this.min
                ? this.min
                : (
                    this._value > this.max
                        ? this.max
                        : this._value
                )
        );
    }//function get_value()


    /**
    * Setter for `.value`
    *
    */
    @:noCompletion private function set_value (v:Float) : Float {
        this._value = v;
        this._updateValueByStep();
        this._updateSliderPos();

        if( this.created ){
            this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
        }

        return v;
    }//function set_value()

    @:noCompletion private function get_step () : Float {
		return this._step;
	}//function get_step()
	@:noCompletion private function set_step (v:Float) : Float {
		this._step = v;
		var oldValue:Float = this._value;
		this._updateValueByStep();
		this._updateSliderPos();
		
		if (this.created && oldValue != this._value) {
			this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
		}
		
		return v;
	}//function set_step()
	
	/**
	 * Update slider value according to `.step` value
	 * 
	 */
	private inline function _updateValueByStep():Void {
		if (this.step != 0) this._value = Math.round(this._value / this.step) * this.step;
	}//function _updateValueByStep()

    /**
    * Update slider position according to `.value`
    *
    */
    private inline function _updateSliderPos() : Void {
        var pt : Float = (this._value - this.min) / (this.max - this.min);

        if( pt < 0 ){
            pt = 0;
        }else if( pt > 1 ){
            pt = 1;
        }

        if( this.vertical ){
            this.slider.top = (this._height - this.slider._height) * (1 - pt);
        }else{
            this.slider.left = (this._width - this.slider._width) * pt;
        }
    }//function _updateSliderPos()


    /**
    * Refresh `.slider` on refresh
    *
    */
    override public function refresh () : Void {
        super.refresh();
        this.slider.refresh();

        //update slider position on first refresh
        this._updateSliderPos();
    }//function refresh()


    /**
    * Handle clicking to immediately set current value
    *
    */
    private function _set (e:MouseEvent) : Void {
        if( e.target != this.slider ){
            //for vertical slider
            if( this.vertical ){
                var y : Float = (
                    this.mouseY - this.slider._height / 2 < 0
                        ? 0
                        : (
                            this.mouseY + this.slider._height / 2 > this._height
                                ? this._height - this.slider._height
                                : this.mouseY - this.slider._height / 2
                        )
                );
                this.slider.tween(0.25, {top:y}, 'Quad.easeOut');

                this._value = (1 - y / (this._height - this.slider._height)) * (this.max - this.min) + this.min;

            //for horizontal slider
            }else{
                var x : Float = (
                    this.mouseX - this.slider._width / 2 < 0
                        ? 0
                        : (
                            this.mouseX + this.slider._width / 2 > this._width
                                ? this._width - this.slider._width
                                : this.mouseX - this.slider._width / 2
                        )
                );
                this.slider.tween(0.25, {left:x}, 'Quad.easeOut');

                this._value = x / (this._width - this.slider._width) * (this.max - this.min) + this.min;
            }
            this._updateValueByStep();
            this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
        }//if()
    }//function _set()


    /**
    * Handle sliding
    * `.value` is set on mouseUp
    */
    private function _slide (e:MouseEvent) : Void {
        if( this.vertical ){
            this._slideVertically();
        }else{
            this._slideHorizontally();
        }
    }//function _slide()


    /**
    * Handle vertical sliding
    *
    */
    private inline function _slideVertically () : Void {
        var dy : Float = this.mouseY - this.slider.top;

        //make `.slider` follow mouse pointer
        var fn : Event->Void = function(e:Event) : Void {
            var y : Float = (
                this.mouseY - dy < 0
                    ? 0
                    : (
                        this.mouseY - dy + this.slider._height > this._height
                            ? this._height - this.slider._height
                            : this.mouseY - dy
                    )
            );
            if( y != this.slider.top ){
                this.slider.top = y;
                this._value = (1 - y / (this._height - this.slider._height)) * (this.max - this.min) + this.min;
                this._updateValueByStep();
                this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
            }
        };
        this.addEventListener(Event.ENTER_FRAME, fn);

        //release `.slider` on MOUSE_UP
        var fnRelease : MouseEvent->Void = null;
        fnRelease = function(e:MouseEvent) : Void {
            this.removeEventListener(Event.ENTER_FRAME, fn);
            Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, fnRelease);
        };

        //listen for MOUSE_UP
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, fnRelease);
    }//function _slideVertically()


    /**
    * Handle horizontal sliding.
    *
    */
    private inline function _slideHorizontally () : Void {
        var dx : Float = this.mouseX - this.slider.left;

        //make `.slider` follow mouse pointer
        var fn : Event->Void = function(e:Event) : Void {
            var x : Float = (
                this.mouseX - dx < 0
                    ? 0
                    : (
                        this.mouseX - dx + this.slider._width > this._width
                            ? this._width - this.slider._width
                            : this.mouseX - dx
                    )
            );
            if( x != this.slider.left ){
                this.slider.left = x;
                this._value = x / (this._width - this.slider._width) * (this.max - this.min) + this.min;
                this._updateValueByStep();
                this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
            }
        };
        this.addEventListener(Event.ENTER_FRAME, fn);

        //release `.slider` on MOUSE_UP
        var fnRelease : MouseEvent->Void = null;
        fnRelease = function(e:MouseEvent) : Void {
            this.removeEventListener(Event.ENTER_FRAME, fn);
            Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, fnRelease);
        };

        //listen for MOUSE_UP
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, fnRelease);
    }//function _slideHorizontally()


}//class Slider
