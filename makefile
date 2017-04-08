ANSDIR=test_sample_no_credit/test_answer_student
TESTDIR=test_sample_no_credit
DIFF=diff --side-by-side --suppress-common-lines
test: scanner
	./scanner < myTest/1.c
lex.yy.c: scanner.l
	flex scanner.l
scanner: lex.yy.c
	gcc lex.yy.c -o scanner
diff: scanner
	# find ./test_sample_no_credit/ -name '*.c' -type f | while read NAME ; do ./scanner < ./test_sample_no_credit/${NAME} > a.out; diff ./test_sample_no_credit/test_answer_student/${NAME%.c}.out; done;
	./scanner < ${TESTDIR}/pragma_source_off.c 1> good.out && ${DIFF} good.out ${ANSDIR}/pragma_source_off.out
	./scanner < ${TESTDIR}/pragma_source_off_1.c 1> good.out && ${DIFF} good.out ${ANSDIR}/pragma_source_off_1.out
	./scanner < ${TESTDIR}/pragma_token_off.c 1> good.out && ${DIFF} good.out ${ANSDIR}/pragma_token_off.out
	./scanner < ${TESTDIR}/test0_1.c 1> good.out && ${DIFF} good.out ${ANSDIR}/test0_1.out
	./scanner < ${TESTDIR}/test0_2.c 1> good.out && ${DIFF} good.out ${ANSDIR}/test0_2.out
	./scanner < ${TESTDIR}/test0_1_error.c 1> good.out 2> bad.out || ${DIFF} bad.out ${ANSDIR}/test0_1_error.out
	./scanner < testcase_credit/testcase_1.c 1> good.out && ${DIFF} good.out testcase_credit/testcase_1.out
	./scanner < testcase_credit/testcase_error_1.c 1> good.out 2>bad.out || cat bad.out

clean:
	rm -f scanner lex.yy.c