/*
** This vector defines all the methods that can operate on an
** unqlite_file for OpenVMS.
*/
static const unqlite_io_methods vmsIoMethod = {
  1,                              /* iVersion */
  vmsClose,                       /* xClose */
  vmsRead,                        /* xRead */
  vmsWrite,                       /* xWrite */
  vmsTruncate,                    /* xTruncate */
  vmsSync,                        /* xSync */
  vmsFileSize,                    /* xFileSize */
  vmsLock,                        /* xLock */
  vmsUnLock,                      /* xUnlock */
  vmsCheckReservedLock,           /* xCheckReservedLock */
  vmsSectorSize,                  /* xSectorSize */
};

int unqlite_os_init(void){
  static unqlite_vfs vmsVfs = {
    "vms",               /* zName */
    1,                   /* iVersion */
    sizeof(vmsFile),     /* szOsFile */
#if defined(NAML$C_MAXRSS)
    NAML$C_MAXRSS,       /* mxPathname */
#else
    NAM$C_MAXRSS,        /* mxPathname */
#endif
    vmsOpen,             /* xOpen */
    vmsDelete,           /* xDelete */
    vmsAccess,           /* xAccess */
    vmsFullPathname,     /* xFullPathname */
    vmsTmpDir,		 /* xTmpDir */
    vmsSleep,            /* xSleep */
    vmsCurrentTime,      /* xCurrentTime */
    vmsGetLastError,     /* xGetLastError */
  };

  return UNQLITE_OK;
}
