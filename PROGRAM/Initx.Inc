//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//



FUNCTION TSLAMM_Simulation.LowerBound(Cat: Integer; Var SS: TSubSite): Double; {lower bound for category in M above MTL}
Begin
  With SS do With Categories.GetCat(Cat).ElevDat do
     Case MinUnit of
       SaltBound: Result  := MinElev * SaltElev;
       HalfTide: Result := MinElev * MHHW;
       else {Meters:} Result := MinElev;
     End; {Case}
End;

FUNCTION TSLAMM_Simulation.UpperBound(Cat: Integer; Var SS: TSubSite): Double; {lower bound for category in M above MTL}
Begin
  With SS do With Categories.GetCat(Cat).ElevDat do
     Case MaxUnit of
       SaltBound: Result  := MaxElev * SaltElev;
       HalfTide: Result := MaxElev * MHHW;
       else {Meters:} Result := MaxElev;
     End; {Case}
End;

{----------------------------------------------------------------------------------}

Function TSLAMM_Simulation.PreprocessWetlands: Boolean;

CONST ONLY_PREPROC_NODATA = FALSE;  //FIXME - Make it true  if you want preprocess only the cells with no data.

Var  CategoryLoop      : Integer;
     CatMinElev,
     CatMaxElev        : Double;
     NumProcessed      : Integer;
     CurrentSubSiteN   : Integer;
     CurrentSubSite    : TSubSite;
     DirOffshore       : WaveDirection;
   {------------------------------------------------------}


   Procedure ProcessStrip(FromRow,FromCol,ToRow,ToCol, SumAdjacentWetlandCells: Integer;
                          EndInWater: Boolean);
     {Processes a strip of wetland uphill from beginning to end}

   Var DeltaRow,DeltaCol: Integer;
       ProcessRow,ProcessCol: Integer;
       Cl: CompressedCell;
       LoopVar: Integer;
       MaxElev,MaxElev_PrevCl : Double;
       AdjacentCellMinElev : Double;
       AdjacentRow, AdjacentCol: Integer;
       CellSubSiteN : Integer;

   Begin
     ProcessRow:=FromRow; ProcessCol:=FromCol;

     CellSubSiteN := Site.GetSubSiteNum(FromCol {x},FromRow {y});
     IF not CellSubSiteN = CurrentSubSiteN then exit;

     MaxElev_PrevCl := CatMinElev;

     MaxElev := CatMaxElev;
     If EndInWater {and (CategoryLoop=TidalFlat)}
        then Maxelev := (CatMaxElev+CatMinelev) / 2;

     DeltaRow := 0; DeltaCol:=0;
     If FromRow>ToRow then DeltaRow:=-1;
     If FromRow<ToRow then DeltaRow:=1;
     If FromCol>ToCol then DeltaCol:=-1;
     If FromCol<ToCol then DeltaCol:= 1;

     For LoopVar:=1 to SumAdjacentWetlandCells do
       Begin
         AdjacentCellMinElev := -9999;
         AdjacentRow:=ProcessRow;
         AdjacentCol:=ProcessCol;

         Case DirOffshore of
           Northerly, Southerly: AdjacentCol := AdjacentCol-1;
           Easterly, Westerly  : AdjacentRow := AdjacentRow-1;
         End; {Case}

         If (AdjacentRow>0) and (AdjacentCol>0) then
           Begin
             RetA(AdjacentRow,AdjacentCol,Cl);

             If CellWidth(@CL,CategoryLoop)>0 then
                AdjacentCellMinElev := CatElev(@Cl,CategoryLoop);

             If AdjacentCellMinElev > 998 then AdjacentCellMinElev := -9999;  //no data, must be in another subsite
           End;

         RetA(ProcessRow,ProcessCol,Cl);

         Cl.TanSlope := Abs((MaxElev-CatMinElev)/(SumAdjacentWetlandCells*Site.RunScale));
                              {m}       {m}              {scalar}               {m}
         SetCatElev(@Cl,CategoryLoop,MaxElev_PrevCl);
         MaxElev_PrevCl := CatElev(@Cl,CategoryLoop) + Cl.Tanslope * Site.RunScale;

         If AdjacentCellMinElev<>-9999 then
          Begin          {Average elevation with elevation of adjacent cell}
            SetCatElev(@Cl,CategoryLoop,(CatElev(@Cl,CategoryLoop) + AdjacentCellMinelev) * 0.5);
          End;

         SetA(ProcessRow,ProcessCol,Cl);

         ProcessRow:=ProcessRow+DeltaRow; {move to next cell to be processed}
         ProcessCol:=ProcessCol+DeltaCol;
      End;
   End;  {ProcessStrip}

   {------------------------------------------------------}
   Procedure Processmap(FromRow,FromCol,ToRow,ToCol: Integer);
   {Process vertical or horizontal rows of cells depending on passed parameters}
   Var Loop: Integer;
       Previous_Was_Water     : Boolean;
       Previous_Was_Category   : Boolean;
       SumAdjacentWetlandCells : Integer;
       FirstWetlandRow,FirstWetlandCol: Integer;

       {------------------------------------------------------}
       Procedure ProcessCell(ProcRow,ProcCol: Integer; LastCell: Boolean);
       { Run for every cell of the CategoryLoop}

       Var ProcCat: Integer;
           CellIsWetlandCategory: Boolean;   // is this cell in the relevant CategoryLoop?
           CellIsWater: Boolean;
           Cl: CompressedCell;
           CellSubSiteN : Integer;
           CellOutOfRange: Boolean;

       Begin
         CellIsWetlandCategory:=False;
         CellIsWater := False;

         CellSubSiteN := Site.GetSubSiteNum(ProcCol {x}, ProcRow {y});
         CellOutOfRange := (CellSubSiteN <> CurrentSubSiteN);

         RetA(ProcRow,ProcCol,Cl);
         ProcCat := GetCellCat(@Cl); {Get the category of the current cell}


         {Set whether Cell is the current wetland category or water}
         If (Categories.GetCat(ProcCat).IsOpenWater) then CellIsWater :=True;
         If (ProcCat=CategoryLoop) then CellIsWetlandCategory := True;
         If ClassicDike and CL.ProtDikes then CellIsWetlandCategory := False;   //3.11.2010 cannot pre-process land protected by dikes on the basis of tidal range
         if (not ClassicDike) and (CL.ProtDikes) and (not CL.ElevDikes) then CellIsWetlandCategory := False;


         If ONLY_PREPROC_NODATA then
           if (CatElev(@Cl,ProcCat)<998.5) then CellIsWetlandCategory := False;  //no data tagged with 999

         {"Boost" non-tidal cells that have initial conditions below the salt boundary due to low precision DEM}
         {If the cell is non tidal and is above salt boundary, set CellIsWetlandCategory to false so it is ignored}
         If (not Categories.GetCat(ProcCat).IsTidal) then if   // 12/17/2009 removed any tidal categories for boosting (TidalFreshMarsh,TidalSwamp) as we now know that they are below the salt boundary in most cases
             ((CatElev(@Cl,ProcCat)>CurrentSubSite.SaltElev) or ((ProcCat<>Categories.UndDryLand) and (FwInfluenced(ProcRow,ProcCol)))) then CellIsWetlandCategory := False;
              {don't boost cells above the salt bound}              {don't boost wetland cells in an estuary}

         { Either:     Cell is water                                                    (case 1)
                       Cell is current wetland category                                 (case 2)
                       Cell is another wetland / dryland category                       (case 3)      }

         If CellIsWater and (not CellOutOfRange) then {case 1}
           Begin
             If Previous_Was_Category and
               (FirstWetlandRow>-1) then
                 Begin {Process strip of Wetland that IS bounded by water on both sides}
                   ProcessStrip(FirstWetlandRow,FirstWetlandCol,
                                ProcRow,ProcCol,SumAdjacentWetlandCells, TRUE);

                   FirstWetlandRow := -1; {reset vars for next processing}
                   FirstWetlandCol := -1;
                 End;

             Previous_Was_Water      :=True; {set vars for processing next cell}
             Previous_Was_Category   :=False;
             SumAdjacentWetlandCells := 0;
           End;

         If CellIsWetlandCategory and (Not CellOutOfRange) {case 2}
          Then
           Begin
             SumAdjacentWetlandCells := SumAdjacentWetlandCells + 1;

             If not Previous_Was_Category
               then begin {mark first wetland cell in series}
                      FirstWetlandRow := ProcRow;
                      FirstWetlandCol := ProcCol;
                    end;

             Previous_Was_Water    := False;
             Previous_Was_Category := True;
           End;

         If LastCell or CellOutOfRange or ((Not CellIsWetlandCategory) and (Not CellIsWater)) then
           Begin  {case 3}
             If Previous_Was_Category and
               (FirstWetlandRow>-1) then
                  Begin {Process Wetland that is NOT bounded by water on both sides}
                    ProcessStrip(FirstWetlandRow,FirstWetlandCol,
                                 ProcRow,ProcCol,SumAdjacentWetlandCells, FALSE);

                    FirstWetlandRow := -1; {reset vars for next processing}
                    FirstWetlandCol := -1;
                  End;

             Previous_Was_Category   := False;  {set vars for processing next cell}
             Previous_Was_Water      := False;
             SumAdjacentWetlandCells := 0;
           End;

(*         If (ProcCat in [EstuarineWater,OpenOcean]) and (CategoryLoop = RockyInterTidal)
           Then Begin
                  SetCatElev(@Cl,ProcCat,CurrentSubSite.MLLW);  {SET ELEVS TO MLLW for Mapping}
                  SetA(ProcRow,ProcCol,Cl);
                End;      JSC 7/7/2011 commented out as this ruins bathymetry over NED data*)
       End; {ProcessCell}
       {------------------------------------------------------}

   Begin   {ProcessMap}
           {run once for each non-open-water land cover category (CategoryLoop)}

     Application.ProcessMessages;

     SumAdjacentWetlandCells := 0;
     FirstWetlandRow := -1; FirstWetlandCol := -1;
     Previous_Was_Water :=True; Previous_Was_Category:=False;

     If (FromRow > ToRow) then
       For Loop := FromRow downto ToRow do
         ProcessCell(Loop,FromCol,Loop=ToRow);
     If (ToRow > FromRow) then
       For Loop := FromRow to ToRow do
         ProcessCell(Loop,FromCol,Loop=ToRow);
     If (FromCol > ToCol) then
       For Loop := FromCol downto ToCol do
         ProcessCell(FromRow,Loop,Loop=ToCol);
     If (ToCol > FromCol) then
       For Loop := FromCol to ToCol do
         ProcessCell(FromRow,Loop,Loop=ToCol);
   End; {ProcessMap}
   {------------------------------------------------------}

Var RLoop: Integer;
    CLoop: Integer;
    NSubSite, Rowmin,RowMax,ColMin,ColMax: Integer;


Begin
  Result := True;

  ProgForm.ProgressLabel.Caption:='Pre-Processing Wetlands Elevations';
  ProgForm.Gauge1.Progress:=0;
  ProgForm.YearLabel.Visible:=True;
  ProgForm.Show;
  ProgForm.Update;
//  Rowmin := 0; RowMax:=0; ColMin:=0; ColMax := 0;

  For NSubSite := 0 to Site.NSubSites do
    Begin
      NumProcessed := 0;
      CurrentSubSiteN := NSubSite;
      If NSubSite = 0 then Begin
                             If not Site.GlobalSite.Use_Preprocessor then Continue; {go to next subsite}
                             RowMin := 0; RowMax := Site.RunRows-1;
                             ColMin := 0; ColMax := Site.RunCols-1;
                             DirOffShore := Site.GlobalSite.Direction_Offshore;
                             CurrentSubSite := Site.GlobalSite;
                           End
                      else With Site.SubSites[NSubSite-1] do
                           Begin
                             If not Site.SubSites[NSubSite-1].Use_Preprocessor then Continue;  {go to next subsite}
                             RowMin := Max(ScalePoly.MinRow,0);
                             RowMax := Min(ScalePoly.MaxRow,Site.RunRows-1);
                             ColMin := Max(ScalePoly.MinCol,0);
                             ColMax := Min(ScalePoly.MaxCol,Site.RunCols-1);
                             DirOffShore := Site.SubSites[NSubSite-1].Direction_Offshore;
                             CurrentSubSite := Site.SubSites[NSubSite-1];
                           End;

      {Go through each non-open-water category, one at a time, and pre-process wetland elevations}
      For CategoryLoop := 0 to Categories.NCats-1 do
       If not Categories.GetCat(CategoryLoop).isOpenWater then
         Begin
            CatMinElev := LowerBound(CategoryLoop, CurrentSubSite);
            CatMaxElev := UpperBound(CategoryLoop, CurrentSubSite);

            Case DirOffshore of
              Northerly: For CLoop:= ColMin to ColMax do
                             ProcessMap(RowMin,CLoop,RowMax,CLoop);
              Southerly: For CLoop:= ColMin to ColMax do
                             ProcessMap(RowMax,CLoop,RowMin,CLoop);
              Easterly:  For RLoop:= RowMin to RowMax do
                             ProcessMap(RLoop,ColMax,RLoop,ColMin);
              Westerly:  For RLoop:= RowMin to RowMax do
                             ProcessMap(RLoop,ColMin,RLoop,ColMax);
            End; {Case}
            Inc(NumProcessed);
            ProgForm.YearLabel.Caption:= Categories.GetCat(CategoryLoop).TextName;
            Result := ProgForm.Update2Gages(Trunc(100*(CategoryLoop/Categories.NCats)),0);
            If Not Result then Exit;
         End;
    End; {subsites}

End; {PreprocessWetlands}


{----------------------------------------------------------------------------------}


