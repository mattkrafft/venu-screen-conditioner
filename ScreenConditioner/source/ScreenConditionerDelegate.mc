import Toybox.Lang;
import Toybox.WatchUi;

class ScreenConditionerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new ScreenConditionerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}