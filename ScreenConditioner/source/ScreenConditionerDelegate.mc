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
        _view.nextMode();
        return true;
    }

    function onBack() as Boolean {
        return false;
    }
}
