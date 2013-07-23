!
! 2013 July 12
!
! The author disclaims copyright to this source code.  In place of
! a legal notice, here is a blessing:
!
!    May you do good and not evil.
!    May you find forgiveness for yourself and forgive others.
!    May you share freely, never taking more than you give.
!
!***********************************************************************
! Build description file for OpenVMS VAX, Alpha and I64 version of 
! UnQLite.
!
.IF "$(MMSARCH_NAME)" .EQ "Alpha"
ARCH = AXP
.ELSIF "$(MMSARCH_NAME)" .EQ "IA64"
ARCH = I64
.ELSIF "$(MMSARCH_NAME)" .EQ "VAX"
ARCH = VAX
.ELSE
.ERROR You must define the ARCH macro as one of: VAX, AXP or I64
.ENDIF

MG_FACILITY = UNQLITE
.IFDEF __MADGOAT_BUILD__
BINDIR = MG_BIN:[$(MG_FACILITY)]
ETCDIR = MG_ETC:[$(MG_FACILITY)]
KITDIR = MG_KIT:[$(MG_FACILITY)]
SRCDIR = MG_SRC:[$(MG_FACILITY)]
.ELSE
BINDIR = SYS$DISK:[.BIN-$(ARCH)]
ETCDIR = SYS$DISK:[.ETC-$(ARCH)]
KITDIR = SYS$DISK:[.KIT-$(ARCH)]
SRCDIR = SYS$DISK:[]
.ENDIF

.FIRST
.IFDEF __VAX__
    @ IF (F$SEARCH("SYS$COMMON:[GCC]LOGIN.COM") .NES. "") THEN -
       @SYS$COMMON:[GCC]LOGIN
    @ IF (F$SEARCH("SYS$COMMON:[GCC]LOGIN.COM") .EQS. "") THEN -
       WRITE SYS$OUTPUT "%F, this software will not build without GCC for VAX"
.ENDIF
    @ IF F$PARSE("$(BINDIR)") .EQS. "" THEN CREATE/DIR $(BINDIR)
    @ DEFINE/NOLOG BIN_DIR $(BINDIR)
    @ IF F$PARSE("$(ETCDIR)") .EQS. "" THEN CREATE/DIR $(ETCDIR)
    @ DEFINE/NOLOG ETC_DIR $(ETCDIR)
    @ IF F$PARSE("$(KITDIR)") .EQS. "" THEN CREATE/DIR $(KITDIR)
    @ DEFINE/NOLOG KIT_DIR $(KITDIR)
    @ DEFINE/NOLOG SRC_DIR $(SRCDIR)

MUNG = EDIT/TECO/EXECUTE=

OPT = .$(ARCH)_OPT
CFLAGS = $(CFLAGS)/NAME=AS_IS

.IFDEF __VAX__
CC = GCC
CFLAGS = $(CFLAGS)/OPT=2/SCAN=$(ETCDIR)CONFIG.H
MFLAGS = $(MFLAGS)/NAMES=DEFINITIONS=BOTH
VEC = $(BINDIR)SQLITE3_VECTOR.OBJ,$(BINDIR)SQLITE3_ALIASES.OBJ
{$(SRCDIR)}.C{$(BINDIR)}.OBJ :
    $(CC)$(CFLAGS) $(MMS$SOURCE)
.ELSE
CFLAGS = $(CFLAGS)/WARN=DISABLE=(LONGEXTERN,EMPTYFILE) -
	 /FIRST_INCLUDE=$(ETCDIR)CONFIG.H/FLOAT=IEEE_FLOAT
VEC = $(SRCDIR)SQLITE3_VECTOR$(OPT)
{$(SRCDIR)}.C{$(BINDIR)}.OBJ :
    $(CC)$(CFLAGS) $(MMS$SOURCE)+SYS$LIBRARY:SYS$LIB_C/LIB

.ENDIF

OBJECTS = $(BINDIR)API.OBJ,$(BINDIR)BITVEC.OBJ,$(BINDIR)FASTJSON.OBJ,-
	  $(BINDIR)LHASH_KV.OBJ,$(BINDIR)MEM_KV.OBJ,$(BINDIR)OS.OBJ,-
	  $(BINDIR)OS_VMS.OBJ,$(BINDIR)PAGER.OBJ,$(BINDIR)UNQLITE_VM.OBJ

#JX9_API.C;5
#JX9_BUILTIN.C;5     JX9_COMPILE.C;4     JX9_CONST.C;4       JX9_HASHMAP.C;4
#JX9_JSON.C;4        JX9_LEX.C;4         JX9_LIB.C;4         JX9_MEMOBJ.C;4
#JX9_PARSE.C;4       JX9_VFS.C;4         JX9_VM.C;4

#OBJECTS = ! add objects here...

#$(BINDIR)SQLITE3.EXE : $(ETCDIR)CONFIG.H,-
#		       $(BINDIR)SHELL.OBJ,$(BINDIR)VMSSHELL.OBJ,-
#		       $(BINDIR)SQLITE3_SHR.EXE,-
#		       $(SRCDIR)SQLITE3$(OPT),$(ETCDIR)VERSION.OPT
#    < DEFINE/USER SQLITE3_SHR BIN_DIR:SQLITE3_SHR.EXE
#    $(LINK)/EXE=$(MMS$TARGET)/NOTRACEBACK/MAP=$(ETCDIR)/CROSS/FULL-
#	$(SRCDIR)SQLITE3$(OPT)/OPT,$(ETCDIR)VERSION.OPT/OPT

$(BINDIR)UNQLITE_SHR.EXE : $(ETCDIR)CONFIG.H,-
			   $(BINDIR)UNQLITE.OLB($(OBJECTS)),$(VEC),-
			   $(SRCDIR)UNQLITE_SHR$(OPT),$(ETCDIR)VERSION.OPT
    $(LINK)/SHARE=$(MMS$TARGET)/MAP=$(ETCDIR)/CROSS/FULL-
	$(SRCDIR)UNQLITE_SHR$(OPT)/OPT,$(ETCDIR)VERSION.OPT/OPT,-
	$(SRCDIR)UNQLITE_VECTOR$(OPT)/OPT

$(ETCDIR)VERSION.OPT : $(SRCDIR)UNQLITE.H
    @MAKE_VERSION $(MMS$SOURCE) $(MMS$TARGET)

$(BINDIR)UNQLITE_VECTOR.OBJ	: $(SRCDIR)UNQLITE_VECTOR.MAR
$(BINDIR)UNQLITE_ALIASES.OBJ	: $(SRCDIR)UNQLITE_ALIASES.S
    GAS -h 3 -o $(MMS$TARGET) $(MMS$SOURCE)

$(ETCDIR)CONFIG.H : $(SRCDIR)DESCRIP.MMS
    @ CLOSE/NOLOG UQP
    @ OPEN/WRITE UQP ETC_DIR:CONFIG.H
    @ WRITE UQP "#define UNQLITE_ENABLE_THREADS 1"
    @ WRITE UQP "#define UNQLITE_DEFAULT_PAGE_SIZE 512"
    @ WRITE UQP "#define UNQLITE_DEFAULT_SECTOR_SIZE 512"
    @ CLOSE/NOLOG UQP
    @ TYPE $(MMS$TARGET)

!
! Generate intermediate symbol vector...
!
.IFNDEF __VAX__
.IF "$(FINDSTRING VECTOR,$(MMSTARGETS))" .EQ "VECTOR"
$(SRCDIR)SYMBOL_VECTOR.TXT : $(SRCDIR)UNQLITE.H,-
			      $(SRCDIR)MAKE_SYMBOL_VECTOR.TEC
    $(LIBR)/LIST=$(ETCDIR)UNQLITE.LIS/NAMES $(BINDIR)UNQLITE.OLB/OBJECT
    $(MUNG) MAKE_SYMBOL_VECTOR.TEC -
	"$(SRCDIR)SYMBOL_VECTOR.TXT=$(ETCDIR)UNQLITE.LIS"

VECTOR : $(SRCDIR)SYMBOL_VECTOR.TXT
    @ CONTINUE
.ELSE
$(SRCDIR)SYMBOL_VECTOR.TXT :
    @ CONTINUE ! do we need message about possible rebuild with VECTOR target
.ENDIF
.ELSE
$(SRCDIR)SYMBOL_VECTOR.TXT :
    @ WRITE SYS$OUTPUT "SYMBOL_VECTOR.TXT cannot be built on a VAX, yet..."
.ENDIF

!
! VAX-specific transfer vector construction
!
$(SRCDIR)UNQLITE_VECTOR.MAR : $(SRCDIR)SYMBOL_VECTOR.TXT,-
			      $(SRCDIR)MAKE_VAX_VECTOR.TEC
    $(MUNG) MAKE_VAX_VECTOR.TEC -
	"$(MMS$TARGET)=$(MMS$SOURCE) $(SRCDIR)UNQLITE_ALIASES.S"

!
! Alpha/I64-specific transfer vector construction
!
$(SRCDIR)UNQLITE_VECTOR.AXP_OPT : $(SRCDIR)SYMBOL_VECTOR.TXT,-
			          $(SRCDIR)MAKE_LINKER_VECTOR.TEC
    $(MUNG) MAKE_LINKER_VECTOR.TEC "$(MMS$TARGET)=$(MMS$SOURCE)"

$(SRCDIR)UNQLITE_VECTOR.I64_OPT : $(SRCDIR)UNQLITE_VECTOR.AXP_OPT
    COPY $(MMS$SOURCE) $(MMS$TARGET)

$(SRCDIR)MAKE_SYMBOL_VECTOR.TEC : $(SRCDIR)MAKE_SYMBOL_VECTOR.TES
    $(MUNG) $(SRCDIR)SQU.TEC "/L:Y/B:Y/T:Y/C:Y/A:Y $(MMS$TARGET)=$(MMS$SOURCE)"
$(SRCDIR)MAKE_LINKER_VECTOR.TEC : $(SRCDIR)MAKE_LINKER_VECTOR.TES
    $(MUNG) $(SRCDIR)SQU.TEC "/L:Y/B:Y/T:Y/C:Y/A:Y $(MMS$TARGET)=$(MMS$SOURCE)"
$(SRCDIR)MAKE_VAX_VECTOR.TEC : $(SRCDIR)MAKE_VAX_VECTOR.TES
    $(MUNG) $(SRCDIR)SQU.TEC "/L:Y/B:Y/T:Y/C:Y/A:Y $(MMS$TARGET)=$(MMS$SOURCE)"

CLEAN :
    - DELETE/NOLOG $(BINDIR)*.*;*
    - DELETE/NOLOG $(ETCDIR)*.*;*
    - DELETE/NOLOG $(KITDIR)*.*;*
