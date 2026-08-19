import Toybox.Graphics;
import Toybox.Lang;
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

        // Current time is the dominant item on the screen.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 30, Graphics.FONT_LARGE, formatClock(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 105, Graphics.FONT_SMALL, "ELAPSED", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 128, Graphics.FONT_MEDIUM, formatElapsed(app.getElapsedMs()), Graphics.TEXT_JUSTIFY_CENTER);

        var hrText = "--";
        if (app.currentHeartRate != null) {
            hrText = app.currentHeartRate.format("%d");
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 183, Graphics.FONT_SMALL, "HEART RATE", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 207, Graphics.FONT_MEDIUM, hrText + " bpm", Graphics.TEXT_JUSTIFY_CENTER);

        drawVitality(dc, app, centerX);

        var status = app.running ? "RUNNING" : "PAUSED";
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 350, Graphics.FONT_XTINY, status, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawVitality(dc as Dc, app, centerX) as Void {
        if (app.vitalityThreshold == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, 268, Graphics.FONT_SMALL, "VITALITY TARGET UNAVAILABLE", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var vitalityMs = app.getVitalityMs();
        var thresholdText = "60% MAX = " + app.vitalityThreshold.format("%d") + " bpm";

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 258, Graphics.FONT_XTINY, thresholdText, Graphics.TEXT_JUSTIFY_CENTER);

        if (app.vitalityAchieved) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, 282, Graphics.FONT_SMALL, "15 POINT GOAL MET", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, 282, Graphics.FONT_SMALL, formatElapsed(vitalityMs) + " / 45:00", Graphics.TEXT_JUSTIFY_CENTER);
        }

        var barX = 70;
        var barY = 315;
        var barWidth = 250;
        var barHeight = 12;
        var progress = vitalityMs.toFloat() / app.VITALITY_GOAL_MS.toFloat();
        if (progress > 1.0) {
            progress = 1.0;
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.fillRectangle(barX, barY, barWidth, barHeight);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(barX, barY, (barWidth * progress).toNumber(), barHeight);
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
