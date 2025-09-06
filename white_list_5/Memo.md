# NSS (Name Service Switch)

* xxx <-> libness_xxx.so.2


* `_nss_<module_name>_gethostbyname2_r(...)`


* `gethostbyname2_r()` -> `_nss_regex_gethostbyname2_r()`
_r = reentrant（再入可能）
thread-safe -- マルチスレッド環境で、複数のスレッドが同じ関数を同時に呼んでも壊れないこと。


### Meaning of each option

```bash
gcc -fPIC -shared -o libnss_regex.so.2 nss_regex.c -ldl -Wall
```
* **`gcc`**
  Invokes the GNU C Compiler.

* **`-fPIC`**
  Generates *Position Independent Code (PIC)*.
  Shared libraries (`*.so`) must be position-independent because they can be loaded at different memory addresses.

* **`-shared`**
  Tells the compiler to create a **shared library** instead of an executable.
  This produces a `.so` file rather than `a.out`.

* **`-o libnss_regex.so.2`**
  Specifies the output file name.
  → Produces a shared library named `libnss_regex.so.2`.
  * `.so.2`
        * The .2 is the version number of the shared library’s ABI (Application Binary Interface).

* **`nss_regex.c`**
  The source file to be compiled.

* **`-ldl`**
  Links against `libdl` (the dynamic linking library).
  Required if you use functions such as `dlopen`, `dlsym`, or `dlclose` for dynamic loading.

* **`-Wall`**
  Enables most common compiler warnings to help detect potential issues in the code.
