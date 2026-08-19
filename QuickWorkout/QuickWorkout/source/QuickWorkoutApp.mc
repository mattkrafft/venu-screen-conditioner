import Toybox.ActivityRecording;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;
import Toybox.WatchUi;

class QuickWorkoutApp extends Application.AppBase {

    var session = null;
    var currentHeartRate = null;
    var running = false;
    var finished = false;

    var accumulatedMs = 0;
    var runStartedMs = 0;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        startHeartRate();
        startWorkout();
    }

    function onStop(state as Dictionary?) as Void {
        Sensor.enableSensorEvents(null);
        Sensor.setEnabledSensors([]);
    }

    function startHeartRate() as Void {
        // Explicitly request the Venu's onboard optical HR sensor for this app.
        Sensor.setEnabledSensors([Sensor.SENSOR_ONBOARD_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function onSensor(info as Sensor.Info) as Void {
        currentHeartRate = info.heartRate;
        WatchUi.requestUpdate();
    }

    function startWorkout() as Void {
        if (session == null) {
            session = ActivityRecording.createSession({
                :name => "Quick Workout",
                :sport => ActivityRecording.SPORT_TRAINING,
                :subSport => ActivityRecording.SUB_SPORT_GENERIC
            });
        }

        if (!session.isRecording()) {
            session.start();
        }

        running = true;
        finished = false;
        runStartedMs = System.getTimer();
    }

    function togglePause() as Void {
        if (finished || session == null) {
            return;
        }

        if (running) {
            accumulatedMs += elapsedSinceRunStart();
            session.stop();
            running = false;
        } else {
            session.start();
            runStartedMs = System.getTimer();
            running = true;
        }

        WatchUi.requestUpdate();
    }

    function getElapsedMs() as Number {
        if (running) {
            return accumulatedMs + elapsedSinceRunStart();
        }
        return accumulatedMs;
    }

    function elapsedSinceRunStart() as Number {
        var now = System.getTimer();
        var delta = now - runStartedMs;
        if (delta < 0) {
            // getTimer() eventually rolls over; a normal workout will almost
            // never cross it, but don't allow a negative display if it does.
            return 0;
        }
        return delta;
    }

    function saveAndFinish() as Void {
        if (session == null || finished) {
            return;
        }

        if (running) {
            accumulatedMs += elapsedSinceRunStart();
            session.stop();
            running = false;
        }

        session.save();
        session = null;
        finished = true;

        Sensor.enableSensorEvents(null);
        Sensor.setEnabledSensors([]);
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new QuickWorkoutView();
        return [view, new QuickWorkoutDelegate(view)];
    }
}

function getApp() as QuickWorkoutApp {
    return Application.getApp() as QuickWorkoutApp;
}
