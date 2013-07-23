$!
$! 2013 July 23
$!
$! The author disclaims copyright to this source code.  In place of
$! a legal notice, here is a blessing:
$!
$!    May you do good and not evil.
$!    May you find forgiveness for yourself and forgive others.
$!    May you share freely, never taking more than you give.
$!
$!***********************************************************************
$! This procedure generates a linker IDENT string from unqlite.h.
$!
$ set noon
$ pipe search 'p1' "#define UNQLITE_VERSION" | -
	( read sys$pipe v ; -
	  v = f$element(2, " ", f$edit(v, "COMPRESS") - """" - """") ; -
	  define/job/nolog UNQLITE_VERSION &v )
$ version = f$trnlnm("UNQLITE_VERSION")
$ major = f$element(1, ".", version)
$ minor = f$element(2, ".", version)
$ edit  = f$element(3, ".", version)
$ if (edit .eqs. ".") then edit = ""
$ if (edit .nes. "") then edit = "-" + edit
$ close/nolog opt
$ open/write opt 'p2'
$ write opt "IDENT=""V''major'.''minor'''edit'""""
$ close/nolog opt
$ exit 1
