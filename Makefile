all:
	flex language.l
	bison -d language.y
	gcc lex.yy.c language.tab.c -o language
	rm -f lex.yy.c language.tab.c language.tab.h
remove:
	rm -f lex.yy.c language.tab.c language.tab.h language