package com.example;

import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.Lib;
import ru.stablex.ui.UIBuilder;


/**
* Simple demo project for StablexUI
*/
class Main extends ru.stablex.ui.widgets.Widget{

    /**
    * Enrty point
    *
    */
    static public function main () : Void{

throw 'DEMO IS NOT READY YET';

        Lib.current.stage.align     = StageAlign.TOP_LEFT;
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

        //initialize StablexUI
        UIBuilder.init('ui/defaults.xml');

        //register skins
        UIBuilder.regSkins('ui/skins.xml');

        //Create our UI
        UIBuilder.buildFn('ui/index.xml')().show();
    }//function main()


}//class Main


