USES DOS; { GetTime }

TYPE
  BlockPtr = ^Block;
  Block = ARRAY [0..65534] OF Char;  { TP40 limit of 65534 }
  BulkData = RECORD
    Part1: BlockPtr;
    Part2: BlockPtr;

    Part1_Cap: Word;
    Part2_Cap: Word;
  END;

VAR
  Bulk: BulkData;
  InFile, OutFile: FILE;
  TotalB: LongInt;
  TimerCount: ARRAY [0..9] OF LongInt;

PROCEDURE WriteTest(B: BlockPtr; Cap: Word);
VAR
  Idx: Word;
  V: Byte;
  KB: LongInt;
BEGIN
  Idx := 0;
  V := 65;
  WHILE Idx < Cap DO
  BEGIN
    B^[Idx] := CHR(V);
    INC(V);
    IF V > 90 THEN V := 65;
    INC(Idx);
  END;

  KB := Trunc( (LongInt(Cap)+1) / 1024 );
  Write('[W ', KB, ' KB]');
  BlockWrite(OutFile, B^, Cap);
END;

PROCEDURE ReadTest(B: BlockPtr; Cap: Word);
VAR
  KB: LongInt;
BEGIN
  KB := Trunc( (LongInt(Cap)+1) / 1024 );
  Write('[R ', KB, ' KB]');
  BlockRead(InFile, B^, Cap);
END;

PROCEDURE ClearOut(B: BlockPtr; Cap: Word);
VAR
  Idx: Word;
BEGIN
  Idx := 0;
  WHILE Idx < Cap DO
  BEGIN
    B^[Idx] := ' ';
    INC(Idx);
  END;
END;

PROCEDURE CheckTest(B: BlockPtr; Cap: Word);
VAR
  Idx: Word;
  V: Byte; { The Value }
  Err: Word;
BEGIN
  Err := 0;
  Idx := 0;
  V := 65;
  WHILE Idx < Cap DO
  BEGIN
    IF B^[Idx] <> CHR(V) THEN
    BEGIN
      INC(Err);
    END
    ELSE BEGIN
      IF Idx MOD 1024 = 0 THEN Write('.');
    END;
    INC(V);
    IF V > 90 THEN V := 65;
    INC(Idx);
  END;
  WriteLn;
  IF Err > 0 THEN WriteLn('Check Errors = ', Err);
END;

VAR
  H,M,S,MS: Word;

BEGIN

  { Prepare Test Size }
  Bulk.Part1_Cap := 64 * 1024 - 1;  { 65535 but 65534 limited }
  Bulk.Part2_Cap := 42 * 1024 + 1;  { 43009, +1 for missing byte above }

  TotalB :=
    LongInt(Bulk.Part1_Cap) +
    LongInt(Bulk.Part2_Cap);
  WriteLn('DiskTest (', TotalB, ' Bytes ==> ', Trunc(TotalB/1024), 'KB)');

  GetTime(H,M,S,MS);  TimerCount[0] := H*3600 + M*60 + S;
  GetMem(Bulk.Part1, Bulk.Part1_Cap);
  GetMem(Bulk.Part2, Bulk.Part2_Cap);
  GetTime(H,M,S,MS);  TimerCount[1] := H*3600 + M*60 + S;

  Assign(OutFile, 'TEST.DAT');
  ReWrite(OutFile, 1);

  GetTime(H,M,S,MS);  TimerCount[2] := H*3600 + M*60 + S;
  Write('Writing: ');
  WriteTest(Bulk.Part1, Bulk.Part1_Cap);
  WriteTest(Bulk.Part2, Bulk.Part2_Cap);
  WriteLn;
  GetTime(H,M,S,MS);  TimerCount[3] := H*3600 + M*60 + S;

  Close(OutFile);

  GetTime(H,M,S,MS);  TimerCount[4] := H*3600 + M*60 + S;
  ClearOut(Bulk.Part1, Bulk.Part1_Cap);
  ClearOut(Bulk.Part2, Bulk.Part2_Cap);
  GetTime(H,M,S,MS);  TimerCount[5] := H*3600 + M*60 + S;

  Assign(InFile, 'TEST.DAT');
  Reset(InFile, 1);

  GetTime(H,M,S,MS);  TimerCount[6] := H*3600 + M*60 + S;
  Write('Reading: ');
  ReadTest(Bulk.Part1, Bulk.Part1_Cap);
  ReadTest(Bulk.Part2, Bulk.Part2_Cap);
  WriteLn;
  GetTime(H,M,S,MS);  TimerCount[7] := H*3600 + M*60 + S;

  Close(InFile);

  GetTime(H,M,S,MS);  TimerCount[8] := H*3600 + M*60 + S;
  CheckTest(Bulk.Part1, Bulk.Part1_Cap);
  CheckTest(Bulk.Part2, Bulk.Part2_Cap);
  GetTime(H,M,S,MS);  TimerCount[9] := H*3600 + M*60 + S;

  FreeMem(Bulk.Part1, Bulk.Part1_Cap);
  FreeMem(Bulk.Part2, Bulk.Part2_Cap);

  WriteLn('Timer 1 ALLOC = ', TimerCount[1] - TimerCount[0]);
  WriteLn('Timer 2 WRITE = ', TimerCount[3] - TimerCount[2]);
  WriteLn('Timer 3 CLEAR = ', TimerCount[5] - TimerCount[4]);
  WriteLn('Timer 4 READ  = ', TimerCount[7] - TimerCount[6]);
  WriteLn('Timer 5 CHECK = ', TimerCount[9] - TimerCount[8]);
END.