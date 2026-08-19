import Toybox.Lang;
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
        }

        // Garmin dismisses the confirmation view automatically on NO/CANCEL.
        // Do not pop the view manually; that can pop the workout view too.
        return true;
    }
}
