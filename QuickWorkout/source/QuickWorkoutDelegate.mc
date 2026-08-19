import Toybox.Lang;
import Toybox.WatchUi;

class QuickWorkoutDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Consume screen taps so touching the display never pauses the workout.
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        return true;
    }

    // Some Venu input paths report the upper button as Select.
    function onSelect() as Boolean {
        getApp().togglePause();
        return true;
    }

    // On the original Venu the upper physical button may be delivered as Menu.
    function onMenu() as Boolean {
        getApp().togglePause();
        return true;
    }

    // Bottom/back button: never end immediately; ask first.
    function onBack() as Boolean {
        _view.showEndConfirmation();
        return true;
    }
}
