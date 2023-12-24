#ifndef LIB_TESTING_MINUNIT_H
#define LIB_TESTING_MINUNIT_H
/* file: minunit.h */

#define MINUNIT_S1(x) #x
#define MINUNIT_S2(x) MINUNIT_S1(x)
#define MINUNIT_LOCATION __FILE__ ":" MINUNIT_S2(__LINE__) ": "
#define mu_assert(message, test) do { if (!(test)) return MINUNIT_LOCATION  message; } while (0)
#define mu_run_test(test) do { char *message = test(); tests_run++; \
                               if (message) return message; } while (0)
extern int tests_run;

void minunit_write_test_ok();

#endif //  LIB_TESTING_MINUNIT_H_
