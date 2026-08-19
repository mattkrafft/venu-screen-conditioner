import Toybox.Graphics;
import Toybox.Timer;
import Toybox.WatchUi;

class ScreenConditionerView extends WatchUi.View {

    var _timer;
    var _mode = 0;
    var _tick = 0;

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _tick = 0;
        _timer.start(method(:onTimer), 100, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onTimer() as Void {
        _tick += 1;
        WatchUi.requestUpdate();
    }

    function nextMode() as Void {
        _mode = (_mode + 1) % 3;
        _tick = 0;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        if (_mode == 0) {
            drawColorCycle(dc);
        } else if (_mode == 1) {
            drawHorizontalWipe(dc);
        } else {
            drawVerticalWipe(dc);
        }
    }

    function getCycleColor(index) {
        var colors = [
            Graphics.COLOR_RED,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_BLUE,
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        ];
        return colors[index % colors.size()];
    }

    function drawColorCycle(dc as Dc) as Void {
        var colorIndex = (_tick / 6).toNumber();
        var color = getCycleColor(colorIndex);
        dc.setColor(color, color);
        dc.clear();
    }

    function drawHorizontalWipe(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var bandWidth = 90;
        var travel = width + bandWidth;
        var x = ((_tick * 8) % travel) - bandWidth;
        var color = getCycleColor((_tick / 50).toNumber());

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(color, color);
        dc.fillRectangle(x, 0, bandWidth, height);
    }

    function drawVerticalWipe(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var bandHeight = 90;
        var travel = height + bandHeight;
        var y = ((_tick * 8) % travel) - bandHeight;
        var color = getCycleColor((_tick / 50).toNumber());

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(color, color);
        dc.fillRectangle(0, y, width, bandHeight);
    }
}
