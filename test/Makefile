csharedlib:	lowess.c
	mkdir -p sharedlib/
	gcc -o ./sharedlib/liblowess.so lowess.c -shared -fPIC -lm

clean: 
	rm -rf ./sharedlib
