all:
	@flex language.l
	@bison -d language.y
	@gcc lex.yy.c language.tab.c -o language
	@rm -f lex.yy.c language.tab.c language.tab.h
remove:
	@rm -f lex.yy.c language.tab.c language.tab.h language


report:
	@flex language.l
	@bison --report all -d language.y
	@gcc -Wall lex.yy.c language.tab.c -o language
	@rm -f lex.yy.c language.tab.c language.tab.h

update:
	@flex language.l
	@bison --report all -t -d language.y
	@gcc lex.yy.c language.tab.c -o language
	@rm -f lex.yy.c language.tab.c language.tab.h

test:
	@make report
	@./language t1