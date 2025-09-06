DISKT106.EXE
DISKT106.PAS
Turbo Pascal source and resulting compiled EXE for MS-DOS x86 system.

GO.BAT
Command line compile the DISKT106.PAS source code.

TEST.DAT
Sample of the file written and read by the DISKT106.PAS program.

TPC.EXE
Command line Turbo Pascal Compiler for TP4.0.  TP4 was first version
to have the compiler external/standalone like this, making it easier to
script builds.

TURBO.TPL
Turbo Pascal Library.  Basically a .OBJ with supporting routines that
get linked into the built EXE as needed for various Turbo Pascal calls
(like GetMem, FreeMem, etc).  Required to do builds, but not required
when passing around the final built executable.
