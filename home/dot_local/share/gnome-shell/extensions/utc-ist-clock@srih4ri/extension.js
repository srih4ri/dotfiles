// Shows "UTC 13:05  IST 18:35" next to the top bar clock.
// Lives inside the date menu button, so clicking it opens the calendar.
import GLib from 'gi://GLib';
import GnomeDesktop from 'gi://GnomeDesktop';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const ZONES = [
    ['UTC', GLib.TimeZone.new_utc()],
    ['IST', GLib.TimeZone.new_identifier('Asia/Kolkata')],
];

export default class UtcIstClock extends Extension {
    enable() {
        this._label = new St.Label({
            // Not 'clock': the Bauhaus theme underlines that; keep it on local time only.
            style_class: 'utc-ist-clock',
            y_align: Clutter.ActorAlign.CENTER,
        });
        const clockDisplay = Main.panel.statusArea.dateMenu._clockDisplay;
        clockDisplay.get_parent().insert_child_above(this._label, clockDisplay);

        // WallClock ticks on the minute (and on time zone / suspend changes).
        this._wallClock = new GnomeDesktop.WallClock();
        this._clockId = this._wallClock.connect('notify::clock', () => this._update());
        this._update();
    }

    _update() {
        this._label.text = ZONES
            .map(([name, tz]) => `${name} ${GLib.DateTime.new_now(tz).format('%H:%M')}`)
            .join('   ');
    }

    disable() {
        this._wallClock?.disconnect(this._clockId);
        this._wallClock = null;
        this._label?.destroy();
        this._label = null;
    }
}
