import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
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
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        var app = getApp();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawProgressRing(dc, app, centerX, centerY);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 50, Graphics.FONT_MEDIUM, formatClock(), Graphics.TEXT_JUSTIFY_CENTER);

        drawDivider(dc, 105);

        // Elapsed timer doubles as the running/paused indicator.
        dc.setColor(app.running ? Graphics.COLOR_GREEN : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 118, Graphics.FONT_SMALL, formatElapsed(app.getElapsedMs()), Graphics.TEXT_JUSTIFY_CENTER);

        drawDivider(dc, 160);
        drawHeartRateAndCalories(dc, app);
        drawDivider(dc, 238);
        drawVitality(dc, app, centerX);
    }

    function drawProgressRing(dc as Dc, app, centerX, centerY) as Void {
        var tickCount = 45;
        var vitalityMs = app.getVitalityMs();
        var activeTicks = ((vitalityMs * tickCount) / app.VITALITY_GOAL_MS).toNumber();
        if (activeTicks > tickCount) {
            activeTicks = tickCount;
        }

        var outerRadius = 178;
        var innerRadius = 166;

        for (var i = 0; i < tickCount; i += 1) {
            var angle = (-Math.PI / 2.0) + (2.0 * Math.PI * i.toFloat() / tickCount.toFloat());
            var cosA = Math.cos(angle);
            var sinA = Math.sin(angle);

            var x1 = centerX + (innerRadius * cosA).toNumber();
            var y1 = centerY + (innerRadius * sinA).toNumber();
            var x2 = centerX + (outerRadius * cosA).toNumber();
            var y2 = centerY + (outerRadius * sinA).toNumber();

            if (app.vitalityAchieved) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else if (i < activeTicks) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            }

            dc.drawLine(x1, y1, x2, y2);
        }
    }

    function drawDivider(dc as Dc, y) as Void {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(88, y, 302, y);
    }

    function drawHeartRateAndCalories(dc as Dc, app) as Void {
        var hrText = "--";
        if (app.currentHeartRate != null) {
            hrText = app.currentHeartRate.format("%d");
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(126, 169, Graphics.FONT_XTINY, "HR", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(264, 169, Graphics.FONT_XTINY, "CALORIES", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(getHeartRateZoneColor(app.getHeartRateZone()), Graphics.COLOR_TRANSPARENT);
        dc.drawText(126, 193, Graphics.FONT_SMALL, hrText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(264, 193, Graphics.FONT_SMALL, app.getCalories().format("%d"), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(195, 167, 195, 225);
    }

    function getHeartRateZoneColor(zone as Number) {
        // Garmin-style zone colors: Z1 white, Z2 blue, Z3 green, Z4 orange, Z5 red.
        if (zone == 2) {
            return Graphics.COLOR_BLUE;
        } else if (zone == 3) {
            return Graphics.COLOR_GREEN;
        } else if (zone == 4) {
            return Graphics.COLOR_ORANGE;
        } else if (zone == 5) {
            return Graphics.COLOR_RED;
        }
        return Graphics.COLOR_WHITE;
    }

    function drawVitality(dc as Dc, app, centerX) as Void {
        if (app.vitalityThreshold == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, 260, Graphics.FONT_XTINY, "VITALITY TARGET UNAVAILABLE", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var vitalityMs = app.getVitalityMs();

        if (app.vitalityAchieved) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, 260, Graphics.FONT_XTINY, "15 POINT GOAL MET", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, 260, Graphics.FONT_SMALL, formatElapsed(vitalityMs) + " / 45:00", Graphics.TEXT_JUSTIFY_CENTER);
        }
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
