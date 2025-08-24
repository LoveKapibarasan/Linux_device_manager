/*
 * TinyWM 改造版 + dwm流 keygrab 対応
 *
 * Ctrl+Alt+1..4 で各ウィンドウ
 * Ctrl+Alt+5    で一覧
 * Ctrl+Alt+T    で端末
 */

#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <X11/Xatom.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_WINDOWS 4

Display *dpy;
Window root;
Window slots[MAX_WINDOWS];
int current = -1;
int listmode = 0;

Atom WM_DELETE_WINDOW, WM_TAKE_FOCUS;
Atom NET_SUPPORTED, NET_WM_STATE, NET_WM_WINDOW_TYPE;

unsigned int numlockmask = 0;   // dwm流: NumLockMask 検出用

// -------------------- cleanmask (dwm流) --------------------
unsigned int cleanmask(unsigned int mask) {
    return mask & ~(numlockmask | LockMask);
}

// -------------------- numlockmask を求める --------------------
void update_numlockmask() {
    XModifierKeymap *modmap = XGetModifierMapping(dpy);
    KeyCode kc = XKeysymToKeycode(dpy, XK_Num_Lock);
    numlockmask = 0;
    for (int mod = 0; mod < 8; mod++) {
        for (int k = 0; k < modmap->max_keypermod; k++) {
            if (modmap->modifiermap[mod * modmap->max_keypermod + k] == kc) {
                numlockmask = (1u << mod);
            }
        }
    }
    XFreeModifiermap(modmap);
}

// -------------------- hide/show --------------------
void hide_all() {
    for (int i=0; i<MAX_WINDOWS; i++) {
        if (slots[i]) XUnmapWindow(dpy, slots[i]);
    }
    listmode = 0;
}

void show_window(int idx) {
    if (idx < 0 || idx >= MAX_WINDOWS || !slots[idx]) return;
    hide_all();
    XMapRaised(dpy, slots[idx]);
    XMoveResizeWindow(dpy, slots[idx], 0, 0,
        DisplayWidth(dpy, DefaultScreen(dpy)),
        DisplayHeight(dpy, DefaultScreen(dpy)));
    current = idx;
}

void show_list() {
    hide_all();
    int sw = DisplayWidth(dpy, DefaultScreen(dpy));
    int sh = DisplayHeight(dpy, DefaultScreen(dpy));
    int halfw = sw/2, halfh = sh/2;

    int i=0;
    for (int r=0; r<2; r++) {
        for (int c=0; c<2; c++) {
            if (i<MAX_WINDOWS && slots[i]) {
                XMapRaised(dpy, slots[i]);
                XMoveResizeWindow(dpy, slots[i],
                    c*halfw, r*halfh, halfw, halfh);
            }
            i++;
        }
    }
    listmode = 1;
    current = -1;
}

void launch_terminal() {
    if (fork() == 0) {
        execlp("xterm", "xterm", NULL);
        _exit(1);
    }
}

// -------------------- grabkeys (dwm流) --------------------
void grabkeys() {
    unsigned int modifiers[] = {
        0,
        LockMask,
        numlockmask,
        numlockmask|LockMask
    };
    unsigned int base = ControlMask|Mod1Mask; // Ctrl+Alt

    // 数字キー 1..5 と KP_1..KP_5
    KeySym syms[5] = {XK_1, XK_2, XK_3, XK_4, XK_5};
    KeySym kpsyms[5] = {XK_KP_1, XK_KP_2, XK_KP_3, XK_KP_4, XK_KP_5};

    for (int i=0; i<5; i++) {
        KeyCode kc = XKeysymToKeycode(dpy, syms[i]);
        KeyCode kckp = XKeysymToKeycode(dpy, kpsyms[i]);
        for (int m=0; m<4; m++) {
            XGrabKey(dpy, kc, base|modifiers[m], root, True,
                     GrabModeAsync, GrabModeAsync);
            if (kckp)
                XGrabKey(dpy, kckp, base|modifiers[m], root, True,
                         GrabModeAsync, GrabModeAsync);
        }
    }

    // T
    KeyCode kt = XKeysymToKeycode(dpy, XK_t);
    for (int m=0; m<4; m++) {
        XGrabKey(dpy, kt, base|modifiers[m], root, True,
                 GrabModeAsync, GrabModeAsync);
    }
}

// -------------------- main --------------------
int main() {
    XEvent ev;
    int screen;

    dpy = XOpenDisplay(0);
    if (!dpy) return 1;
    screen = DefaultScreen(dpy);
    root = RootWindow(dpy, screen);

    for (int i=0; i<MAX_WINDOWS; i++) slots[i] = 0;

    WM_DELETE_WINDOW = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
    WM_TAKE_FOCUS    = XInternAtom(dpy, "WM_TAKE_FOCUS", False);

    NET_SUPPORTED      = XInternAtom(dpy, "_NET_SUPPORTED", False);
    NET_WM_STATE       = XInternAtom(dpy, "_NET_WM_STATE", False);
    NET_WM_WINDOW_TYPE = XInternAtom(dpy, "_NET_WM_WINDOW_TYPE", False);

    Atom supported[] = {NET_WM_STATE, NET_WM_WINDOW_TYPE};
    XChangeProperty(dpy, root, NET_SUPPORTED, XA_ATOM, 32,
                    PropModeReplace, (unsigned char*)supported, 2);

    // NumLock mask 検出 & grab
    update_numlockmask();
    grabkeys();

    XSelectInput(dpy, root, SubstructureRedirectMask|SubstructureNotifyMask);

    for (;;) {
        XNextEvent(dpy, &ev);

        if (ev.type == MapRequest) {
            int stored=0;
            for (int i=0; i<MAX_WINDOWS; i++) {
                if (!slots[i]) {
                    slots[i] = ev.xmaprequest.window;
                    stored = 1;
                    break;
                }
            }
            if (stored) {
                XMapWindow(dpy, ev.xmaprequest.window);
                XSetWMProtocols(dpy, ev.xmaprequest.window, &WM_DELETE_WINDOW, 1);
                XSetInputFocus(dpy, ev.xmaprequest.window, RevertToParent, CurrentTime);
            } else {
                XDestroyWindow(dpy, ev.xmaprequest.window);
            }
        }
        else if (ev.type == KeyPress) {
            KeySym ks = XkbKeycodeToKeysym(dpy, ev.xkey.keycode, 0, 0);
            unsigned int state = cleanmask(ev.xkey.state);

            if (state == (ControlMask|Mod1Mask)) {
                if (ks >= XK_1 && ks <= XK_4) {
                    show_window(ks - XK_1);
                } else if (ks == XK_5 || ks == XK_KP_5) {
                    show_list();
                } else if (ks == XK_t || ks == XK_T) {
                    launch_terminal();
                } else if (ks >= XK_KP_1 && ks <= XK_KP_4) {
                    show_window(ks - XK_KP_1);
                }
            }
        }
        else if (ev.type == ConfigureRequest) {
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
            for (int i=0; i<MAX_WINDOWS; i++) {
                if (slots[i] == ev.xdestroywindow.window) {
                    slots[i] = 0;
                }
            }
        }
        else if (ev.type == UnmapNotify) {
            for (int i=0; i<MAX_WINDOWS; i++) {
                if (slots[i] == ev.xunmap.window) {
                    slots[i] = 0;
                }
            }
        }
        else if (ev.type == ClientMessage) {
            if ((Atom)ev.xclient.data.l[0] == WM_DELETE_WINDOW) {
                XDestroyWindow(dpy, ev.xclient.window);
            }
        }
        else if (ev.type == MappingNotify) {
            XRefreshKeyboardMapping(&ev.xmapping);
            update_numlockmask();
            grabkeys();
        }
    }
    return 0;
}
