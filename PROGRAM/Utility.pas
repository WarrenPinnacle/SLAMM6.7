//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

UNIT UTILITY;

    INTERFACE

USES GLOBAL;

    (***************************************)
    (*   utilitiy procedures               *)
    (***************************************)


FUNCTION GetCellCat(Cl: PCompressedCell): Integer;  // position in the Categories Array
FUNCTION CellWidth(Cl: PCompressedCell; Cat: Integer): Single;
FUNCTION CatElev(Cl: PCompressedCell; Cat: Integer): Single;
PROCEDURE SETCatElev(Cl: PCompressedCell; Cat: Integer; SetVal: Single);
PROCEDURE SETCELLWIDTH(Cl: PCompressedCell; Cat: Integer; SetVal: Single);
Function GetMinElev(Cl: PCompressedCell): Double;
Function GetAvgElev(Cl: PCompressedCell; RunScale: Double): Double;
Function FloatToWord(INVar: Double): Word;
Function WordToFloat(InVar: Word): Double;

//Function BELOWSALTBOUND(Cl: PCompressedCell): Boolean;

  IMPLEMENTATION

{***************************************************
*                                                  *
*     GetCellCat: Determines the cell Integer     *
*       based on the percentages of classes.       *
*                                                  *
*   2/11/88       Written by - Manjit S. Trehan    *
*   3/13/88       Modified to Function by R. Park  *
***************************************************}

FUNCTION GetCellCat(Cl: PCompressedCell): Integer;

VAR
  i: Integer;          { Loop Variable }
  CellCat : Integer;
  MaxArea,
  CatArea : double;   { Percentage of the dominant class }

BEGIN { GetCellCat }
  MaxArea := 0.0;
  CellCat := -1;
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      CatArea := Cl.Widths[i];
      IF CatArea > MaxArea THEN
        BEGIN
          CellCat := Cl.Cats[i];
          MaxArea := CatArea;
        END;
    End;
   GetCellCat := CellCat;
END; { GetCellCat }



Function CellWidth(Cl: PCompressedCell; Cat: Integer): Single;
Var i: Integer;
Begin
  CellWidth := 0;
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      If Cl.Cats[i] = Cat then
        Begin
          CellWidth := Cl.Widths[i];
          Exit;
        End;
    End;
End;


Function CatElev(Cl: PCompressedCell; Cat: Integer): Single;
Var i: Integer;
Begin
  CatElev := 999;
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      If Cl.Cats[i] = Cat then
        Begin
          CatElev := Cl.MinElevs[i];
          Exit;
        End;
    End;
End;

PROCEDURE SetCatElev(Cl: PCompressedCell; Cat: Integer; SetVal: Single);
Var i: Integer;
Begin
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      If Cl.Cats[i] = Cat then
        Begin
          Cl.MinElevs[i] := SetVal;
          Exit;
        End;
    End;
End;

PROCEDURE SETCELLWIDTH(Cl: PCompressedCell; Cat: Integer; SetVal: Single);
Var i: Integer;
    MinWidth: Double;
Begin
  MinWidth := 99999;
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      If Cl.Cats[i] = Cat then
        Begin
          Cl.Widths[i] := SetVal;
          Exit;
        End;
      If MinWidth> Cl.Widths[i] then MinWidth := Cl.Widths[i];
    End;

  {Apparently Integer wasn't Found8}
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      If Cl.Widths[i] = MinWidth then
        Begin
          If MinWidth < SetVal then {keep maximum of two minimum categories}
            Begin
              Cl.Cats[i] := Cat;
              Cl.MinElevs[i] := 999;
            End;

          Cl.Widths[i]   := SetVal + MinWidth;
          Exit;
        End;
    End;



  Raise ESLAMMError.Create('Algorithm Error, SETCELLWIDTH, min width not found');

End;


Function GetMinElev(Cl: PCompressedCell): Double;
Var MnElev: Double;
    i: Integer;
Begin
  MnElev := 999;
  For i := 1 to NUM_CAT_COMPRESS do
    If (CL.MinElevs[i]<MnElev) and (Cl.Widths[i] > 0) then
        MnElev := CL.Minelevs[i];
  GetMinElev := MnElev;

End;

Function GetAvgElev(Cl: PCompressedCell; RunScale: Double): Double;
Var Min, SlopeAdjustment: Double;
Begin
  Min := GetMinElev(Cl);
  // Adjustment of the slope
  SlopeAdjustment := (RunScale*0.5) * Cl.TanSlope;   {QA 11.10.2005}

  Result := Min + SlopeAdjustment;
End;


Function FloatToWord(InVar: Double): Word;
{0..65535 in mm starting at - 10 meters  so range of -10.000m to 55.535 meters with 1mm precision}
Begin
  If (InVar) < -10
    then Result := 0
  else If (InVar) > 55.5
    then Result := 55500
  else Result:= Round((InVar+10)*1000);
End;


Function WordToFloat(InVar: Word): Double;
{0..65535 in mm starting at - 10 meters  so range of -10.000m to 55.535 meters with 1mm precision}
Begin
 Result := (InVar / 1000)-10;
End;

End.
