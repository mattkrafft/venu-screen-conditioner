import Toybox.ActivityRecording;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;
import Toybox.UserProfile;
import Toybox.WatchUi;

class QuickWorkoutApp extends Application.AppBase {

    const VITALITY_GOAL_MS = 2700000; // 45 minutes

    var session = null;
    var currentHeartRate = null;
    var running = false;
    var finished = false;

    var accumulatedMs = 0;
    var runStartedMs = 0;

    var maxHeartRate = null;
    var vitalityThreshold = null;
    var aboveThreshold = false;
    var vitalityStartedMs = 0;
    var vitalityAchieved = false;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        loadVitalityTarget();
        startHeartRate();
        startWorkout();
    }

    function onStop(state as Dictionary?) as Void {
        Sensor.enableSensorEvents(null);
        Sensor.setEnabledSensors([]);
    }

    function loadVitalityTarget() as Void {
        try {
            var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
            if (zones != null && zones.size() >= 6) {
                maxHeartRate = zones[5];
                vitalityThreshold = ((maxHeartRate * 60 + 99) / 100).toNumber();
            }
        } catch (e) {
            maxHeartRate = null;
            vitalityThreshold = null;
        }
    }

    function startHeartRate() as Void {
        Sensor.setEnabledSensors([Sensor.SENSOR_ONBOARD_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function onSensor(info as Sensor.Info) as Void {
        currentHeartRate = info.heartRate;

        if (running && !vitalityAchieved && vitalityThreshold != null && currentHeartRate != null) {
            if (currentHeartRate >= vitalityThreshold) {
                if (!aboveThreshold) {
                    aboveThreshold = true;
                    vitalityStartedMs = System.getTimer();
                }

                if (getVitalityMs() >= VITALITY_GOAL_MS) {
                    vitalityAchieved = true;
                }
            } else {
                aboveThreshold = false;
                vitalityStartedMs = 0;
            }
        }

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

            if (!vitalityAchieved) {
                aboveThreshold = false;
                vitalityStartedMs = 0;
            }
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
            return 0;
        }
        return delta;
    }

    function getVitalityMs() as Number {
        if (vitalityAchieved) {
            return VITALITY_GOAL_MS;
        }

        if (!running || !aboveThreshold || vitalityStartedMs == 0) {
            return 0;
        }

        var delta = System.getTimer() - vitalityStartedMs;
        if (delta < 0) {
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
