'use strict';

const { Meta, Shell } = imports.gi;
const Main = imports.ui.main;
const ExtensionUtils = imports.misc.extensionUtils;

let settings = null;

function swapAllWindows() {
    const display = global.display;

    if (display.get_n_monitors() !== 2) {
        Main.notify(
            'Swap All Monitors',
            '이 확장은 2개의 모니터를 사용하는 경우에 맞춰져 있습니다.'
        );
        return;
    }

    const workspace = global.workspace_manager.get_active_workspace();

    const windows = workspace.list_windows().filter(win => {
        return !win.skip_taskbar &&
               (win.get_monitor() === 0 || win.get_monitor() === 1);
    });

    // 이동하기 전에 양쪽 창 목록을 먼저 저장해야
    // 이동 도중 목록이 섞이지 않음
    const monitor0 = windows.filter(win => win.get_monitor() === 0);
    const monitor1 = windows.filter(win => win.get_monitor() === 1);

    for (const win of monitor0)
        win.move_to_monitor(1);

    for (const win of monitor1)
        win.move_to_monitor(0);
}

function init() {
}

function enable() {
    settings = ExtensionUtils.getSettings(
        'org.gnome.shell.extensions.swapall'
    );

    Main.wm.addKeybinding(
        'swap-all',
        settings,
        Meta.KeyBindingFlags.NONE,
        Shell.ActionMode.ALL,
        swapAllWindows
    );
}

function disable() {
    Main.wm.removeKeybinding('swap-all');
    settings = null;
}
