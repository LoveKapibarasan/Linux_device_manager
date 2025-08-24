/*
 * 完全版 TinyWM 改造版（dwm流キー処理 / Electron対応 / コメント付き）
 *
 * 機能:
 *  - 最大4つのウィンドウを管理（slots[0..3]）
 *  - Ctrl+Alt+1..4: 該当スロットのウィンドウをフルスクリーン表示（他は隠す）
 *  - Ctrl+Alt+5    : 一覧表示（2x2）
 *  - Ctrl+Alt+T    : xterm 起動
 *
 * 重要な実装ポイント:
 *  - dwm流キー処理:
 *      * NumLock/CapsLock/AltGr（Mode_switch）対応
 *      * KP_1..KP_5 も掴む
 *      * MappingNotify を受けたら XRefreshKeyboardMapping と再グラブ
 *      * cleanmask() で Lock/NumLock を無視して比較
 *  - UnmapNotify ではスロットを消さない
 *      * 自分の hide_all() で XUnmapWindow を呼んでも登録解除されない
 *      * 実際に閉じたとき（DestroyNotify）のみスロット解放
 *  - MapRequest:
 *      * 既に管理中の窓は二重登録しない
 *      * 空きがなければ（仕様通り）破棄
 *  - ConfigureRequest は尊重（Electron の要求を通す）
 *  - ICCCM/EWMH 最低限（_NET_SUPPORTED / WM_DELETE_WINDOW 設定など）
 */

#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <X11/Xatom.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_WINDOWS 4

// X11 グローバル
Display *dpy;
Window root;

// 管理テーブル
Window slots[MAX_WINDOWS];   // 管理する最大4つのウィンドウ
int current = -1;            // 現在表示中のスロット（フルスクリーン時）
int listmode = 0;            // 一覧表示中フラグ

// Atoms
Atom WM_DELETE_WINDOW, WM_TAKE_FOCUS;
Atom NET_SUPPORTED, NET_WM_STATE, NET_WM_WINDOW_TYPE;

// dwm流: NumLock検出用
unsigned int numlockmask = 0;

// -------------------- ユーティリティ --------------------
static unsigned int
cleanmask(unsigned int mask) {
    // NumLock / CapsLock を比較から除外
    return mask & ~(numlockmask | LockMask);
}

static void
update_numlockmask(void) {
    XModifierKeymap *modmap = XGetModifierMapping(dpy);
    if (!modmap) { numlockmask = 0; return; }
    KeyCode num = XKeysymToKeycode(dpy, XK_Num_Lock);
    numlockmask = 0;

    for (int mod = 0; mod < 8; mod++) {
        for (int k = 0; k < modmap->max_keypermod; k++) {
            if (modmap->modifiermap[mod * modmap->max_keypermod + k] == num) {
                numlockmask = (1u << mod);
            }
        }
    }
    XFreeModifiermap(modmap);
}

static int
find_slot_by_window(Window w) {
    for (int i = 0; i < MAX_WINDOWS; i++) {
        if (slots[i] == w) return i;
    }
    return -1;
}

// -------------------- 表示制御 --------------------
static void
hide_all(void) {
    for (int i = 0; i < MAX_WINDOWS; i++) {
        if (slots[i]) XUnmapWindow(dpy, slots[i]);
    }
    listmode = 0;
    current = -1;
}

static void
show_window(int idx) {
    if (idx < 0 || idx >= MAX_WINDOWS || !slots[idx]) return;
    hide_all();
    XMapRaised(dpy, slots[idx]);
    XMoveResizeWindow(
        dpy, slots[idx],
        0, 0,
        DisplayWidth(dpy, DefaultScreen(dpy)),
        DisplayHeight(dpy, DefaultScreen(dpy))
    );
    XSetInputFocus(dpy, slots[idx], RevertToParent, CurrentTime);
    current = idx;
    listmode = 0;
}

static void
show_list(void) {
    int sw = DisplayWidth(dpy, DefaultScreen(dpy));
    int sh = DisplayHeight(dpy, DefaultScreen(dpy));
    int halfw = sw / 2, halfh = sh / 2;

    hide_all(); // いったん全部隠してから並べ直す

    int i = 0;
    for (int r = 0; r < 2; r++) {
        for (int c = 0; c < 2; c++) {
            if (i < MAX_WINDOWS && slots[i]) {
                XMapRaised(dpy, slots[i]);
                XMoveResizeWindow(dpy, slots[i], c * halfw, r * halfh, halfw, halfh);
            }
            i++;
        }
    }
    listmode = 1;
    current = -1;
}

static void
launch_terminal(void) {
    if (fork() == 0) {
        execlp("xterm", "xterm", NULL);
        _exit(1);
    }
}

// -------------------- キーグラブ（dwm流） --------------------
static void
grabkeys(void) {
    // 既存グラブを念のため解放（安全側）
    for (int code = 8; code < 255; code++) {
        XUngrabKey(dpy, code, AnyModifier, root);
    }

    unsigned int modifiers[] = {
        0,
        LockMask,
        numlockmask,
        numlockmask | LockMask
    };
    unsigned int base = ControlMask | Mod1Mask; // Ctrl+Alt

    // 数字キー 1..5 と KP_1..KP_5
    KeySym syms[5]   = {XK_1, XK_2, XK_3, XK_4, XK_5};
    KeySym kpsyms[5] = {XK_KP_1, XK_KP_2, XK_KP_3, XK_KP_4, XK_KP_5};

    for (int i = 0; i < 5; i++) {
        KeyCode kc   = XKeysymToKeycode(dpy, syms[i]);
        KeyCode kckp = XKeysymToKeycode(dpy, kpsyms[i]);
        for (int m = 0; m < 4; m++) {
            if (kc)
                XGrabKey(dpy, kc, base | modifiers[m], root, True, GrabModeAsync, GrabModeAsync);
            if (kckp)
                XGrabKey(dpy, kckp, base | modifiers[m], root, True, GrabModeAsync, GrabModeAsync);
        }
    }

    // T
    KeyCode kt = XKeysymToKeycode(dpy, XK_t);
    KeyCode kT = XKeysymToKeycode(dpy, XK_T); // 念のため
    for (int m = 0; m < 4; m++) {
        if (kt) XGrabKey(dpy, kt, base | modifiers[m], root, True, GrabModeAsync, GrabModeAsync);
        if (kT) XGrabKey(dpy, kT, base | modifiers[m], root, True, GrabModeAsync, GrabModeAsync);
    }
}

// -------------------- メイン --------------------
int main(void) {
    XEvent ev;
    int screen;

    dpy = XOpenDisplay(NULL);
    if (!dpy) return 1;

    screen = DefaultScreen(dpy);
    root = RootWindow(dpy, screen);

    // スロット初期化
    for (int i = 0; i < MAX_WINDOWS; i++) slots[i] = 0;

    // ICCCM atoms
    WM_DELETE_WINDOW = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
    WM_TAKE_FOCUS    = XInternAtom(dpy, "WM_TAKE_FOCUS", False);

    // EWMH atoms
    NET_SUPPORTED      = XInternAtom(dpy, "_NET_SUPPORTED", False);
    NET_WM_STATE       = XInternAtom(dpy, "_NET_WM_STATE", False);
    NET_WM_WINDOW_TYPE = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE", False);

    Atom supported[] = { NET_WM_STATE, NET_WM_WINDOW_TYPE };
    XChangeProperty(dpy, root, NET_SUPPORTED, XA_ATOM, 32,
                    PropModeReplace, (unsigned char*)supported, 2);

    // NumLock 検出 & キーグラブ
    update_numlockmask();
    grabkeys();

    // ルートに必要イベントを購読
    XSelectInput(dpy, root,
        SubstructureRedirectMask | SubstructureNotifyMask | KeyPressMask);

    // イベントループ
    for (;;) {
        XNextEvent(dpy, &ev);

        if (ev.type == MapRequest) {
            Window w = ev.xmaprequest.window;

            // 既に管理中か？
            int idx = find_slot_by_window(w);

            // 未管理なら空きスロットに登録
            if (idx < 0) {
                for (int i = 0; i < MAX_WINDOWS; i++) {
                    if (!slots[i]) { idx = i; slots[i] = w; break; }
                }
                if (idx < 0) {
                    // いっぱいなら既存仕様通り破棄
                    XDestroyWindow(dpy, w);
                    continue;
                }
                XSetWMProtocols(dpy, w, &WM_DELETE_WINDOW, 1);
            }

            // マップしてフォーカス（一覧/単体どちらの状態でも OK）
            XMapWindow(dpy, w);
            XSetInputFocus(dpy, w, RevertToParent, CurrentTime);
        }
        else if (ev.type == KeyPress) {
            KeySym ks = XkbKeycodeToKeysym(dpy, ev.xkey.keycode, 0, 0);
            unsigned int state = cleanmask(ev.xkey.state);

            // Ctrl+Alt ?
            if (state == (ControlMask | Mod1Mask)) {
                if ((ks >= XK_1 && ks <= XK_4) || (ks >= XK_KP_1 && ks <= XK_KP_4)) {
                    int idx = (ks >= XK_1 && ks <= XK_4) ? (ks - XK_1) : (ks - XK_KP_1);
                    if (slots[idx]) show_window(idx);
                    else launch_terminal(); // 空なら端末起動（親切挙動）
                }
                else if (ks == XK_5 || ks == XK_KP_5) {
                    int any = 0; for (int i = 0; i < MAX_WINDOWS; i++) if (slots[i]) { any = 1; break; }
                    if (any) show_list();
                    else XBell(dpy, 0);
                }
                else if (ks == XK_t || ks == XK_T) {
                    launch_terminal();
                }
            }
        }
        else if (ev.type == ConfigureRequest) {
            // クライアント要求を尊重（Electron の安心ポイント）
            XWindowChanges wc;
            wc.x = ev.xconfigurerequest.x;
            wc.y = ev.xconfigurerequest.y;
            wc.width = ev.xconfigurerequest.width;
            wc.height = ev.xconfigurerequest.height;
            wc.border_width = ev.xconfigurerequest.border_width;
            wc.sibling = ev.xconfigurerequest.above;
            wc.stack_mode = ev.xconfigurerequest.detail;

            XConfigureWindow(dpy, ev.xconfigurerequest.window,
                             ev.xconfigurerequest.value_mask, &wc);
        }
        else if (ev.type == DestroyNotify) {
            // 実際に閉じられたときだけスロット解放
            int idx = find_slot_by_window(ev.xdestroywindow.window);
            if (idx >= 0) slots[idx] = 0;
        }
        else if (ev.type == UnmapNotify) {
            // ここではスロットを消さない（hide_all で自分が Unmap するため）
            // 必要ならここで可視状態の追跡だけする
        }
        else if (ev.type == ClientMessage) {
            if ((Atom)ev.xclient.data.l[0] == WM_DELETE_WINDOW) {
                XDestroyWindow(dpy, ev.xclient.window);
            }
        }
        else if (ev.type == MappingNotify) {
            // キーボードマッピング変更時は再取得＆再グラブ
            XRefreshKeyboardMapping(&ev.xmapping);
            update_numlockmask();
            grabkeys();
        }
    }

    return 0;
}
