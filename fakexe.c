#define _GNU_SOURCE

#include <dlfcn.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

ssize_t readlink(const char *pathname, char *buf, size_t bufsiz) {
    static ssize_t (*libc_readlink)(const char *pathname, char *buf, size_t bufsiz) = NULL;
    if (!libc_readlink) libc_readlink = dlsym(RTLD_NEXT, "readlink");

    const char *orig = getenv("FAKEXE_ORIG");
    const char *repl = getenv("FAKEXE_REPL");
    ssize_t ret = libc_readlink(pathname, buf, bufsiz);

    if (ret > 0 && strcmp(pathname, "/proc/self/exe") == 0 && orig && repl && strncmp(buf, orig, ret) == 0) {
        int sz = strlen(repl);
        if (sz > bufsiz) sz = bufsiz;
        memcpy(buf, repl, sz);
        return sz;
    }
    return ret;
}
