import Toybox.Lang;
import Toybox.WatchUi;

class QuickWorkoutDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Top button: pause/resume only.
    function onSelect() as Boolean {
        getApp().togglePause();
        return true;
    }

    // Bottom/back button: never end immediately; ask first.
    function onBack() as Boolean {
        _view.showEndConfirmation();
        return true;
    }
}
