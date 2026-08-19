import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ScreenConditionerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new ScreenConditionerView();
        return [ view, new ScreenConditionerDelegate(view) ];
    }
}

function getApp() as ScreenConditionerApp {
    return Application.getApp() as ScreenConditionerApp;
}
