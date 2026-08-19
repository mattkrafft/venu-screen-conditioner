import Toybox.System;
import Toybox.WatchUi;

class QuickWorkoutEndDelegate extends WatchUi.ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            getApp().saveAndFinish();
            System.exit();
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}
