import Toybox.Graphics;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class QuickWorkoutView extends WatchUi.View {

    var _timer;

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _timer.stop();
        _timer.start(method(:onTimer), 1000, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onTimer() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var centerX = width / 2;
        var app = getApp();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Current clock time is intentionally the dominant item.
        dc.drawText(centerX, 48, Graphics.FONT_LARGE, formatClock(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 135, Graphics.FONT_SMALL, "ELAPSED", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 160, Graphics.FONT_MEDIUM, formatElapsed(app.getElapsedMs()), Graphics.TEXT_JUSTIFY_CENTER);

        var hrText = "--";
        if (app.currentHeartRate != null) {
            hrText = app.currentHeartRate.format("%d");
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 226, Graphics.FONT_SMALL, "HEART RATE", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 251, Graphics.FONT_MEDIUM, hrText + " bpm", Graphics.TEXT_JUSTIFY_CENTER);

        var status = app.running ? "RUNNING" : "PAUSED";
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 322, Graphics.FONT_SMALL, status, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function formatClock() as String {
        var clock = System.getClockTime();
        var hour = clock.hour;
        var suffix = "AM";

        if (hour >= 12) {
            suffix = "PM";
        }
        hour = hour % 12;
        if (hour == 0) {
            hour = 12;
        }

        return hour.format("%d") + ":" + clock.min.format("%02d") + " " + suffix;
    }

    function formatElapsed(ms as Number) as String {
        var totalSeconds = (ms / 1000).toNumber();
        var hours = (totalSeconds / 3600).toNumber();
        var minutes = ((totalSeconds % 3600) / 60).toNumber();
        var seconds = (totalSeconds % 60).toNumber();

        if (hours > 0) {
            return hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }
        return minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    function showEndConfirmation() as Void {
        WatchUi.pushView(
            new WatchUi.Confirmation("Save and end workout?"),
            new QuickWorkoutEndDelegate(),
            WatchUi.SLIDE_IMMEDIATE
        );
    }
}
