KD_MAKEFILE = Makefile-Linux-x86-64-gcc
DEFINES = -DKDU_INCLUDE_TIFF

all:
	cd coresys/make; make -f $(KD_MAKEFILE) all
	cd apps/make; make -f $(KD_MAKEFILE) all_but_hyperdoc
	cd managed/make; make -f $(KD_MAKEFILE) all

clean:
	cd coresys/make; make -f $(KD_MAKEFILE) clean
	cd apps/make; make -f $(KD_MAKEFILE) clean
	cd managed/make; make -f $(KD_MAKEFILE) clean

install:
	cp bin/Linux-x86-64-gcc/* /usr/bin
	cp lib//Linux-x86-64-gcc/* /usr/lib
