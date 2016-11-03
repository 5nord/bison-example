AC_PREREQ([2.69])
AC_INIT([bison-example], [1.0], [matthias.simon@nokia.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_SRCDIR([main.c])
AM_INIT_AUTOMAKE([1.9 tar-pax subdir-objects foreign -Wall])
AM_SILENT_RULES([yes])

AC_PROG_CC
AC_PROG_YACC
AC_PROG_LEX
AC_PROG_RANLIB
AM_PROG_AR

AC_CHECK_HEADERS([stdlib.h string.h])
AC_C_INLINE
AC_CHECK_FUNCS([strdup])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
