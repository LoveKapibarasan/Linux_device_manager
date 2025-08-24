// reference (https://qiita.com/ai56go/items/dec1307f634181d923f5)
/*
 * TinyWM 改造版 (Ctrl+W削除 / コメント付き)
 *
 * 機能:
 *  - 最大nつのウィンドウを管理
 *  - Ctrl+Alt+1..n で該当ウィンドウを全画面表示 (他は隠す)
 *  - Ctrl+Alt+n+1 で登録済みウィンドウを 2x2 一覧表示
 *  - Ctrl+Alt+T で端末 (xterm) 起動
 *  - WM自体の終了は 起動元ターミナルで Ctrl+C
 *
 * 注意:
 *  - ICCCM/EWMH は考慮していないので実用WMではありません
 *  1. Compile= gcc -o <name> <name.c> -lX11
 *  2. Edit /.xinitrc and add execute command
 *  3. startx
 *  Note; Display Environment Variable Error
 *  echo $DISPLAY
 *  If this is empty, add ~/.bashrc
 *  export DISPLAY=localhost:0.0((=:0))
 */

#include <X11/Xlib.h>
#include <X11/keysym.h> //deprecated(2025)
#include <X11/XKBlib.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_WINDOWS 4

Display *dpy;
Window root;
Window slots[MAX_WINDOWS];   // 管理する最大nつのウィンドウ
int current = -1;            // 現在表示中のスロット番号
int listmode = 0;            // 一覧表示中フラグ

// --- 全ウィンドウを隠す ---
void hide_all() {
    for(int i=0; i<MAX_WINDOWS; i++) {
        if(slots[i]) XUnmapWindow(dpy, slots[i]);
    }
    listmode = 0;
}

// --- 指定番号のウィンドウをフルスクリーン表示 ---
void show_window(int idx) {
    if(idx < 0 || idx >= MAX_WINDOWS || !slots[idx]) return;
    hide_all();
    XMapRaised(dpy, slots[idx]);
    XMoveResizeWindow(dpy, slots[idx], 0, 0,
        DisplayWidth(dpy, DefaultScreen(dpy)),
        DisplayHeight(dpy, DefaultScreen(dpy)));
    current = idx;
}

// --- 一覧表示 (\root n \cdot \root n に並べる) ---
void show_list() {
    hide_all();
    int sw = DisplayWidth(dpy, DefaultScreen(dpy));
    int sh = DisplayHeight(dpy, DefaultScreen(dpy));
    int halfw = sw/2, halfh = sh/2;

    int i=0;
    for(int r=0; r<2; r++) {
        for(int c=0; c<2; c++) {
            if(i<MAX_WINDOWS && slots[i]) {
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

// --- 端末起動 (Default: xterm) ---
void launch_terminal() {
    if(fork()==0) {
        execlp("xterm", "xterm", NULL);
        _exit(1);
    }
}

int main() {
    XEvent ev;
    int screen;

    dpy = XOpenDisplay(0);
    if(!dpy) return 1;
    screen = DefaultScreen(dpy);
    root = RootWindow(dpy, screen);

    for(int i=0; i<MAX_WINDOWS; i++) slots[i] = 0;

    // --- キーグラブ (Ctrl+Alt+1..5, T) ---
    unsigned int mask = ControlMask|Mod1Mask;
    for(int k=1; k<=5; k++)
        XGrabKey(dpy,
            XKeysymToKeycode(dpy, XStringToKeysym((char[]){'0'+k,0})),
            mask, root, True, GrabModeAsync, GrabModeAsync);

    XGrabKey(dpy, XKeysymToKeycode(dpy, XStringToKeysym("t")),
             mask, root, True, GrabModeAsync, GrabModeAsync);

    // --- 新しいウィンドウ通知を受け取る ---
    XSelectInput(dpy, root, SubstructureRedirectMask|SubstructureNotifyMask);

    // --- イベントループ ---
    for(;;) {
        XNextEvent(dpy, &ev);

        if(ev.type == MapRequest) {
	    int stored=0;
            // 新しいウィンドウが来た → 空いているスロットに登録
            for(int i=0; i<MAX_WINDOWS; i++) {
                if(!slots[i]) { 
			slots[i] = ev.xmaprequest.window; 
			stored = 1;
			break; }
            }
	    if(stored){
            	XMapWindow(dpy, ev.xmaprequest.window);
	    }else{
	    	XDestroyWindow(dpy,ev.xmaprequest.window);
	    }
        }
        else if(ev.type == KeyPress) {
            KeySym ks = XkbKeycodeToKeysym(dpy, ev.xkey.keycode, 0, 0);

            if((ev.xkey.state & ControlMask) && (ev.xkey.state & Mod1Mask)) {
                if(ks >= XK_1 && ks <= XK_4) {
                    show_window(ks - XK_1);
                } else if(ks == XK_5) {
                    show_list();
                } else if(ks == XK_t || ks == XK_T) {
                    launch_terminal();
                }
            }
        }
		else if (ev.type == ConfigureRequest) {
    		 Window w = ev.xconfigurerequest.window;
    		if (listmode) {
        		// 2x2 配置を再教育
        		show_list();
    		} else if (current >= 0 && slots[current] == w) {
        	// 現在表示しているウィンドウならフルスクリーンを再教育
        	show_window(current);
    		} else {
        	// それ以外（非表示スロットとか）は要求無視
        	// （→勝手にサイズ変えようとしても「黙って座ってろ！」）
    		}
		}
		else if (ev.type == DestroyNotify) {
    		// 管理リストから削除
		    for (int i = 0; i < MAX_WINDOWS; i++) {
    	    	if (slots[i] == ev.xdestroywindow.window) {
        		    slots[i] = 0;
        		}
		 	}
		}
		else if (ev.type == UnmapNotify) {
    	// これも一応クリーンアップ
    		for (int i = 0; i < MAX_WINDOWS; i++) {
        		if (slots[i] == ev.xunmap.window) {
            		slots[i] = 0;
        		}
    	}
}

    }
    return 0;
}
