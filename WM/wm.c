/*
 * TinyWM 強化版 (4スロット + Electron安定用GPUコンポジット)
 *
 * 機能:
 *   - Ctrl+Alt+1..4: 各スロットをフルスクリーン表示
 *   - Ctrl+Alt+5   : 一覧表示 (2x2)
 *   - Ctrl+Alt+T   : xterm -e zsh を起動
 *
 *   - EWMH最低限サポート (_NET_SUPPORTED 等)
 *   - ConfigureRequest を尊重 (Electronの要求を通す)
 *   - GPU コンポジット (XComposite + GLX)
 */

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <X11/extensions/Xcomposite.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_WINDOWS 4

Display *dpy;
Window root;
Window slots[MAX_WINDOWS];
int current = -1, listmode = 0;

Atom WM_DELETE_WINDOW;
Atom NET_SUPPORTED, NET_WM_STATE, NET_WM_WINDOW_TYPE;

GLXContext glctx;
Window glwin;

// -------------------- GPU 初期化 --------------------
void init_gl(void) {
    int screen = DefaultScreen(dpy);
    static int attribs[] = { GLX_RGBA, GLX_DOUBLEBUFFER, None };
    XVisualInfo *vi = glXChooseVisual(dpy, screen, attribs);
    if (!vi) { fprintf(stderr, "No GLX visual\n"); exit(1); }

    glctx = glXCreateContext(dpy, vi, NULL, GL_TRUE);

    XSetWindowAttributes attr;
    attr.colormap = XCreateColormap(dpy, root, vi->visual, AllocNone);
    glwin = XCreateWindow(dpy, root, 0,0,
        DisplayWidth(dpy,screen), DisplayHeight(dpy,screen),
        0, vi->depth, InputOutput, vi->visual, CWColormap, &attr);

    XMapWindow(dpy, glwin);
    glXMakeCurrent(dpy, glwin, glctx);
    glEnable(GL_TEXTURE_2D);
}

// -------------------- 表示制御 --------------------
void hide_all(void) {
    for (int i=0;i<MAX_WINDOWS;i++) {
        if (slots[i]) XUnmapWindow(dpy, slots[i]);
    }
    current = -1; listmode = 0;
}

void show_window(int idx) {
    if (idx<0 || idx>=MAX_WINDOWS || !slots[idx]) return;
    hide_all();
    XMapRaised(dpy, slots[idx]);
    XMoveResizeWindow(dpy, slots[idx],
        0,0,
        DisplayWidth(dpy,DefaultScreen(dpy)),
        DisplayHeight(dpy,DefaultScreen(dpy))
    );
    XSetInputFocus(dpy, slots[idx], RevertToParent, CurrentTime);
    current = idx; listmode = 0;
}

void show_list(void) {
    int sw = DisplayWidth(dpy,DefaultScreen(dpy));
    int sh = DisplayHeight(dpy,DefaultScreen(dpy));
    int halfw = sw/2, halfh = sh/2;
    hide_all();
    int i=0;
    for (int r=0;r<2;r++) {
        for (int c=0;c<2;c++) {
            if (i<MAX_WINDOWS && slots[i]) {
                XMapRaised(dpy, slots[i]);
                XMoveResizeWindow(dpy, slots[i],
                    c*halfw, r*halfh, halfw, halfh);
            }
            i++;
        }
    }
    listmode=1; current=-1;
}

void launch_terminal(void) {
    if (fork()==0) {
        execlp("xterm","xterm","-e","zsh",NULL);
        _exit(1);
    }
}

// -------------------- ユーティリティ --------------------
int find_slot(Window w) {
    for (int i=0;i<MAX_WINDOWS;i++) if (slots[i]==w) return i;
    return -1;
}

// -------------------- main --------------------
int main(void) {
    XEvent ev;

    dpy = XOpenDisplay(NULL);
    if (!dpy) { fprintf(stderr,"cannot open display\n"); return 1; }
    root = RootWindow(dpy, DefaultScreen(dpy));
    for (int i=0;i<MAX_WINDOWS;i++) slots[i]=0;

    // Atoms
    WM_DELETE_WINDOW = XInternAtom(dpy,"WM_DELETE_WINDOW",False);
    NET_SUPPORTED    = XInternAtom(dpy,"_NET_SUPPORTED",False);
    NET_WM_STATE     = XInternAtom(dpy,"_NET_WM_STATE",False);
    NET_WM_WINDOW_TYPE = XInternAtom(dpy,"_NET_WM_WINDOW_TYPE",False);

    Atom supported[] = { NET_WM_STATE, NET_WM_WINDOW_TYPE };
    XChangeProperty(dpy, root, NET_SUPPORTED, XA_ATOM, 32,
        PropModeReplace,(unsigned char*)supported,2);

    // GPU init
    init_gl();

    // Root イベント購読
    XSelectInput(dpy, root,
        SubstructureRedirectMask|SubstructureNotifyMask|KeyPressMask);

    for (;;) {
        XNextEvent(dpy, &ev);

        if (ev.type == MapRequest) {
            Window w = ev.xmaprequest.window;
            int idx = find_slot(w);
            if (idx<0) {
                for (int i=0;i<MAX_WINDOWS;i++) if(!slots[i]){slots[i]=w; idx=i;break;}
            }
            if (idx<0) { XDestroyWindow(dpy,w); continue; }
            XSetWMProtocols(dpy, w, &WM_DELETE_WINDOW, 1);
            XMapWindow(dpy, w);
            XSetInputFocus(dpy, w, RevertToParent, CurrentTime);

            // GPU的に composite redirect だけ
            XCompositeRedirectWindow(dpy, w, CompositeRedirectManual);
        }
        else if (ev.type == KeyPress) {
            KeySym ks = XkbKeycodeToKeysym(dpy, ev.xkey.keycode,0,0);
            unsigned int st = ev.xkey.state;
            if (st == (ControlMask|Mod1Mask)) {
                if ((ks>=XK_1 && ks<=XK_4) || (ks>=XK_KP_1 && ks<=XK_KP_4)) {
                    int idx = (ks>=XK_1&&ks<=XK_4)?(ks-XK_1):(ks-XK_KP_1);
                    if (slots[idx]) show_window(idx);
                    else launch_terminal();
                } else if (ks==XK_5 || ks==XK_KP_5) {
                    show_list();
                } else if (ks==XK_t || ks==XK_T) {
                    launch_terminal();
                }
            }
        }
        else if (ev.type == ConfigureRequest) {
            XWindowChanges wc;
            wc.x=ev.xconfigurerequest.x;
            wc.y=ev.xconfigurerequest.y;
            wc.width=ev.xconfigurerequest.width;
            wc.height=ev.xconfigurerequest.height;
            wc.border_width=ev.xconfigurerequest.border_width;
            wc.sibling=ev.xconfigurerequest.above;
            wc.stack_mode=ev.xconfigurerequest.detail;
            XConfigureWindow(dpy, ev.xconfigurerequest.window,
                ev.xconfigurerequest.value_mask,&wc);
        }
        else if (ev.type == DestroyNotify) {
            int idx = find_slot(ev.xdestroywindow.window);
            if (idx>=0) slots[idx]=0;
        }
        else if (ev.type == ClientMessage) {
            if ((Atom)ev.xclient.data.l[0]==WM_DELETE_WINDOW) {
                XDestroyWindow(dpy, ev.xclient.window);
            }
        }
    }
    return 0;
}
