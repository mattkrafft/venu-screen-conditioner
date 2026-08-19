import Toybox.Lang;
import Toybox.WatchUi;

class ScreenConditionerDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        _view.nextMode();
        return true;
    }

    function onSelect() as Boolean {
        _view.toggleRunning();
        return true;
    }

    function onMenu() as Boolean {
        _view.toggleRunning();
        return true;
    }

    function onBack() as Boolean {
        // Bottom/back button exits the app normally.
        return false;
    }
}
