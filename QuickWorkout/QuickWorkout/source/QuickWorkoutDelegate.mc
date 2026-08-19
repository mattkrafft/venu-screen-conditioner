import Toybox.Lang;
import Toybox.WatchUi;

class QuickWorkoutDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new QuickWorkoutMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}