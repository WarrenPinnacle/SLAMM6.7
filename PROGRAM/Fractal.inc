//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//


{***************************}
{ Compute Fractal Dimension }
{ for Marsh-Water Interface }
{***************************}

Procedure TSLAMM_Simulation.Calc_Fractal;
VAR  LengthX,
     LMax,
     FType, LengthY: INTEGER;
     isite: Integer;
Begin
 For iSite := 0 to Site.NOutputSites do
  With FRs[isite] do
    For FType := 0 to 1 do
      Begin
        LengthX := MaxFDRow[FType] - MinFDRow[FType];
        LengthY := MaxFDCol[FType] - MinFDCol[FType];
        IF LengthX > LengthY THEN
          LMax := LengthX
        ELSE
          LMax := LengthY;
        IF LMax > 1 THEN
          BEGIN
          FractalD[FType] := Log10(NBox[FType])/Log10(LMax);
          FractalP[FType] := 1.0/LMax * NBox[FType];
          END
        ELSE
          BEGIN
           FractalD[FType] := 0.0;
           FractalP[FType] := 0.0;
          END;

        MaxFDRow[FType]:= 0;  {reinitialize for the next step}
        MaxFDCol[FType] := 0;
        MinFDRow[FType] := 65535;
        MinFDCol[FType] := 65535;
        NBox[FType] := 0;
      End;
END;


{****************************}
{* Define Set for Fractal D *}
{****************************}
Procedure TSLAMM_Simulation.FractalNos(ER,EC: Integer; Var Cell: CompressedCell; Var FSite: TSite);

    Function AdjCell(Var AdjRow,AdjCol: Integer; Lee: Boolean): Boolean;

    {********************************************}
    {* Return adjacent cell to lee if Lee=True  *}
    {* AdjRow and AdjCol are inputs and outputs *}
    {* Function False if out-of-bounds          *}
    {* JClough, December 2005 (adds modularity) *}
    {********************************************}
    Var Step: Integer;
        PSS: TSubSite;
    Begin
      If Lee then Step := -1
             else Step :=  1;

      PSS := FSite.GetSubSite(EC {X}, ER {Y});  {Subsite with highest number gets dominance}

      Case PSS.Direction_OffShore of
         Westerly : AdjCol := AdjCol - Step;
         Easterly : AdjCol := AdjCol + Step;
         Northerly: AdjRow := AdjRow - Step;
         Southerly: AdjRow := AdjRow + Step;
        End; {Case}

      AdjCell := (AdjRow>=0) and (AdjCol>=0) and
                 (AdjRow<FSite.Rows) and (AdjCol<FSite.Cols);
    End;

Var Include, Cont: Boolean;
    iSite, FType: Integer;
    AdjRow, AdjCol: Integer;
    AdjC: CompressedCell;
    ThisMarsh, AdjacentMarsh: Double;
Begin
 For iSite := 0 to FSite.NOutputSites do
  If (iSite =0) or FSite.InOutSite(EC,ER,iSite) then
   With FRs[isite] do
     Begin
        For FType := 0 to 1 do
          IF ((FType = 0) and ((CellWidth(@Cell,Mangrove)       + CellWidth(@Cell,RegFloodMarsh) +
                                CellWidth(@Cell,IrregFloodMarsh)  ) / FSite.Scale >= 0.1))
          OR ((FType = 1) and ((CellWidth(@Cell,RegFloodMarsh)    ) / FSite.Scale >= 0.1))
             Then
               Begin
                 Include := (CellWidth(@Cell,OpenOcean) + CellWidth(@Cell,EstuarineWater) +
                             CellWidth(@Cell,TidalCreek) + CellWidth(@Cell,RiverineTidal) >= 0.1);

                 If (Not Include) and (ER>0) then
                    Include := GetBit(MostlyWater,ER-1,EC);
                 If (Not Include) and (EC>0) then
                    Include := GetBit(MostlyWater,ER,EC-1);
                 If (Not Include) and (ER<FSite.Rows-1) then
                    Include := GetBit(MostlyWater,ER+1,EC);
                 If (Not Include) and (EC<FSite.Cols-1) then
                    Include := GetBit(MostlyWater,ER,EC+1);

                 If Include then
                    Begin
                      Inc(NBox[FType]);           {count cells with interface}
                      IF ER < MinFDRow[FType] THEN MinFDRow[FType] := ER;
                      IF EC < MinFDCol[FType] THEN MinFDCol[FType] := EC;
                      IF ER > MaxFDRow[FType] THEN MaxFDRow[FType] := ER;
                      IF EC > MaxFDCol[FType] THEN MaxFDCol[FType] := EC;
                    End; {If Include}
               End; {If FType...}

        If ((Cellwidth(@Cell,DevDryLand)) + (Cellwidth(@Cell,UndDryLand))) > 0.1 then
          Begin
            AdjRow := ER; AdjCol := EC;
            AdjacentMarsh := CellWidth(@Cell,RegFloodMarsh) + CellWidth(@Cell,IrregFloodMarsh) + CellWidth(@Cell,ScrubShrub);
               {m}
            Repeat
             Cont := False;
             If AdjCell(AdjRow,AdjCol,False) then {if there is an adjacent cell}
              If GetBit(Saltwater,AdjRow,AdjCol) then {if the adjacent cell is not dry land}
                Begin
                  RetA(AdjRow,AdjCol,AdjC);
                  ThisMarsh := CellWidth(@AdjC,RegFloodMarsh) + CellWidth(@AdjC,IrregFloodMarsh) +  CellWidth(@AdjC,ScrubShrub);
                  AdjacentMarsh := AdjacentMarsh + ThisMarsh;
                  If (ThisMarsh > 0) then Cont := True;
                End;
            Until (Not Cont) or (AdjacentMarsh > 30);
            IF (AdjacentMarsh > 30) then ShoreProtect := ShoreProtect + (FSite.Scale/1000);  {km shoreline protected}
                  {m}
          End;

    { 1.  IF a cell is upland and has tidal marsh, salt marsh or brackish marsh within the cell or immediately
          contiguous to the cell in the "direction off-shore" THEN look in the cell to the "direction off-shore."
      2.  IF the width of wetlands within that cell plus the width of wetlands within the uplands cell
          >= 30 meters THEN add 30 meters to our count of protected shoreline (if there are 30 horizontal meters
          of protection then we count the 30 vertical meters as protected.) }

     End; {With FRs}

End; {FractalNos}


