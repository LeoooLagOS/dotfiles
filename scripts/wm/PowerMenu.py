#!/usr/bin/env python3
# Power menu (replaces wlogout): Lock fires on a tap, every other action has
# to be held for HOLD_MS so a stray keypress can't log out or power off.
# While held, the tile fills up from the bottom; releasing early drains it.

import os
import re
import subprocess
import time

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk, GtkLayerShell  # noqa: E402

HOLD_MS = 500
DRAIN_FACTOR = 3  # releasing empties the tile this many times faster
TILE_W, TILE_H, ICON_SIZE = 200, 260, 72

CONFIG = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
ICONS = os.path.join(CONFIG, "wlogout", "icons")
SCRIPTS = os.path.join(CONFIG, "hypr", "scripts")
COLORS = os.path.join(CONFIG, "waybar", "wallust", "colors-waybar.css")

# (key, label, icon, command, needs hold)
ACTIONS = [
    ("l", "Lock", "lock-2", f"{SCRIPTS}/LockScreen.sh", False),
    ("o", "Logout", "logout-box-r", f"{SCRIPTS}/Logout.sh", True),
    ("p", "Shutdown", "shut-down", "systemctl poweroff", True),
    ("r", "Reboot", "restart", "systemctl reboot", True),
    ("s", "Suspend", "hotel-bed", f"{SCRIPTS}/LockScreen.sh; sleep 1; systemctl suspend", True),
]


def wallust_colors():
    colors = {"foreground": "#F2E8EA", "background": "#141416", "color11": "#BD7BDE"}
    try:
        with open(COLORS) as f:
            for name, value in re.findall(r"@define-color\s+(\S+)\s+(#[0-9A-Fa-f]{6})", f.read()):
                colors[name] = value
    except OSError:
        pass
    return colors


def hex_rgb(value):
    return tuple(int(value[i : i + 2], 16) / 255 for i in (1, 3, 5))


def load_icon(name, color):
    with open(os.path.join(ICONS, f"{name}-line.svg"), "rb") as f:
        svg = f.read().replace(b"currentColor", color.encode())
    loader = GdkPixbuf.PixbufLoader()
    loader.set_size(ICON_SIZE, ICON_SIZE)
    loader.write(svg)
    loader.close()
    return loader.get_pixbuf()


def rounded_rect(cr, x, y, w, h, r):
    cr.new_sub_path()
    cr.arc(x + w - r, y + r, r, -1.5708, 0)
    cr.arc(x + w - r, y + h - r, r, 0, 1.5708)
    cr.arc(x + r, y + h - r, r, 1.5708, 3.1416)
    cr.arc(x + r, y + r, r, 3.1416, 4.7124)
    cr.close_path()


class Tile(Gtk.EventBox):
    def __init__(self, menu, key, label, icon, command, hold, colors):
        super().__init__()
        self.menu, self.key, self.command, self.hold = menu, key, command, hold
        self.fg = hex_rgb(colors["foreground"])
        self.accent = hex_rgb(colors["color11"])
        self.bg = hex_rgb(colors["background"])
        self.progress = 0.0
        self.holding = False
        self.hovered = False
        self.last_tick = None
        self.tick_id = None

        self.set_size_request(TILE_W, TILE_H)
        self.add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK)

        overlay = Gtk.Overlay()
        self.canvas = Gtk.DrawingArea()
        self.canvas.connect("draw", self.on_draw)
        overlay.add(self.canvas)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_valign(Gtk.Align.CENTER)
        box.pack_start(Gtk.Image.new_from_pixbuf(load_icon(icon, colors["foreground"])), False, False, 0)
        title = Gtk.Label(label=label)
        title.get_style_context().add_class("title")
        hint = Gtk.Label()
        hint.set_markup(f"{'Hold' if hold else 'Press'} <b>{key.upper()}</b>")
        hint.get_style_context().add_class("hint")
        box.pack_start(title, False, False, 0)
        box.pack_start(hint, False, False, 0)
        overlay.add_overlay(box)
        overlay.set_overlay_pass_through(box, True)
        self.add(overlay)

        self.connect("enter-notify-event", lambda *_: self.set_hover(True))
        self.connect("leave-notify-event", lambda *_: self.set_hover(False))
        self.connect("button-press-event", lambda _w, e: e.button == 1 and self.press())
        self.connect("button-release-event", lambda _w, e: e.button == 1 and self.release())

    def set_hover(self, value):
        self.hovered = value
        self.canvas.queue_draw()

    def press(self):
        if not self.hold:
            self.menu.run(self.command)
        elif not self.holding:
            self.holding = True
            self.start_ticking()

    def release(self):
        if self.holding:
            self.holding = False
            self.start_ticking()

    def start_ticking(self):
        if self.tick_id is None:
            self.last_tick = time.monotonic()
            self.tick_id = GLib.timeout_add(8, self.tick)

    def tick(self):
        now = time.monotonic()
        step = (now - self.last_tick) * 1000 / HOLD_MS
        self.last_tick = now
        if self.holding:
            self.progress = min(1.0, self.progress + step)
        else:
            self.progress = max(0.0, self.progress - step * DRAIN_FACTOR)
        self.canvas.queue_draw()

        if self.holding and self.progress >= 1.0:
            self.tick_id = None
            # Let the full tile render once before the menu closes.
            GLib.timeout_add(60, lambda: self.menu.run(self.command))
            return False
        if not self.holding and self.progress <= 0.0:
            self.tick_id = None
            return False
        return True

    def on_draw(self, widget, cr):
        w, h = widget.get_allocated_width(), widget.get_allocated_height()
        radius = 28
        active = self.hovered or self.holding

        rounded_rect(cr, 0.5, 0.5, w - 1, h - 1, radius)
        cr.set_source_rgba(*self.bg, 0.6)
        cr.fill_preserve()
        cr.set_source_rgba(1, 1, 1, 0.12 if active else 0.04)
        cr.fill_preserve()
        if self.progress > 0:
            cr.save()
            cr.clip()
            fill_h = h * self.progress
            cr.rectangle(0, h - fill_h, w, fill_h)
            cr.set_source_rgba(*self.accent, 0.55)
            cr.fill()
            cr.restore()
            rounded_rect(cr, 0.5, 0.5, w - 1, h - 1, radius)
        cr.set_source_rgba(*self.fg, 0.35 if active else 0.15)
        cr.set_line_width(1)
        cr.stroke()


class PowerMenu(Gtk.Window):
    def __init__(self):
        super().__init__()
        colors = wallust_colors()

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "powermenu")
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)
        GtkLayerShell.set_exclusive_zone(self, -1)
        for edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
            GtkLayerShell.set_anchor(self, edge, True)

        css = Gtk.CssProvider()
        css.load_from_data(
            f"""
            window {{ background-color: rgba(0, 0, 0, 0.4); }}
            label {{ color: {colors["foreground"]}; }}
            .title {{ font-size: 20pt; }}
            .hint {{ font-size: 11pt; opacity: 0.7; }}
            """.encode()
        )
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        row = Gtk.Box(spacing=40)
        row.set_halign(Gtk.Align.CENTER)
        row.set_valign(Gtk.Align.CENTER)
        self.tiles = {}
        for key, label, icon, command, hold in ACTIONS:
            tile = Tile(self, key, label, icon, command, hold, colors)
            self.tiles[key] = tile
            row.pack_start(tile, False, False, 0)
        self.add(row)

        self.connect("key-press-event", self.on_key_press)
        self.connect("key-release-event", self.on_key_release)
        self.connect("destroy", Gtk.main_quit)

    def tile_for(self, event):
        return self.tiles.get(Gdk.keyval_name(Gdk.keyval_to_lower(event.keyval)))

    def on_key_press(self, _widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
        elif tile := self.tile_for(event):
            tile.press()
        return True

    def on_key_release(self, _widget, event):
        if tile := self.tile_for(event):
            tile.release()
        return True

    def run(self, command):
        # Close first so the lock screen doesn't capture the menu.
        self.destroy()
        subprocess.Popen(["sh", "-c", command], start_new_session=True)
        return False


if __name__ == "__main__":
    PowerMenu().show_all()
    Gtk.main()
