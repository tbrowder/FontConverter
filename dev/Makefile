all: test1
#all: test2
#all: test3
#all: test4
#all: test1 test2 test3 test4

test1:
	(cd ..; raku -Ilib t/01*t)

test2:
	(cd ..; raku -Ilib t/02*t)

test3:
	(cd ..; raku -Ilib t/03*t)

test4:
	(cd ..; raku -Ilib t/04*t)

run:
	(cd ..; raku -Ilib bin/fc-convert-font t/fonts/cmbsy10.pfb)
