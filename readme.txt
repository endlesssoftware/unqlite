	UnQLite for OpenVMS

    UnQLite is a transactional NoSQL database in the same vein as SQLite.
 This repository contain the OpenVMS port of unqlite-db 1.1.6.

    Much of the OpenVMS-sepecific code contained in this project has been
 built from the port of SQLite.

---

 Configuration options to put into DESCRIP.MMS

  - UNQLITE_ENABLE_THREADS
  - JX9_ENABLE_MATH_FUNC
  - UNQLITE_ENABLE_JX9_HASH_IO
  

 Run-time options (need to figure out setting these at compile):

  - #define UNQLITE_LIB_CONFIG_USER_MALLOC            1 /* ONE ARGUMENT: const SyMemMethods *pMemMethods */
  - #define UNQLITE_LIB_CONFIG_USER_MUTEX             3 /* ONE ARGUMENT: const SyMutexMethods *pMutexMethods */
  - #define UNQLITE_LIB_CONFIG_VFS                    6 /* ONE ARGUMENT: const unqlite_vfs *pVfs */
  - #define UNQLITE_LIB_CONFIG_PAGE_SIZE              8 /* ONE ARGUMENT: int iPageSize */

 What about the Jx9 stuff?  It has a VFS interface that wants to know
 how to set default, etc.

 Make sure __UNIXES__ and __WINNT__ are #undef'd
