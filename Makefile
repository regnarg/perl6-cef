
libfakexe.so: fakexe.c
	gcc -o $@ -ldl -shared -fPIC $<
