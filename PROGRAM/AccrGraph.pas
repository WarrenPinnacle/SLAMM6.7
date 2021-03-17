unit AccrGraph;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, OleCtrls, StdCtrls, Buttons,
  CalcDist, DB, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, UncertDefn;

type
  TAccrGraphForm = class(TForm)
    Chart1: TChart;
    Series1: TAreaSeries;
    OKBtn: TButton;
    Button1: TButton;
    Memo1: TMemo;
    IsMultLabel: TLabel;
    MarshBox: TComboBox;
    SubSiteBox: TComboBox;
    ErrorPanel: TPanel;
    zz: TPanel;
    Label5: TLabel;
    Label4: TLabel;
    HTUBox: TCheckBox;
    procedure RetHandleClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure MarshBoxExit(Sender: TObject);
    procedure HTUBoxClick(Sender: TObject);
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
  private
    procedure updatescreen;
    { Private declarations }
  public
    PSS: Pointer;
    Procedure ShowAccrGraphs(TSS: Pointer);
    { Public declarations }
  end;

var
  AccrGraphForm: TAccrGraphForm;

Const ChartColors: Array[0..9] of TColor =
                (ClBlack, ClBlue, ClRed, ClGreen,
                 ClFuchsia, $000080FF, ClPurple, ClOlive, ClMaroon,  ClAqua );


implementation

uses selectinput, SLR6, SLAMMLegend, System.UITypes, Global, Utility;

{$R *.DFM}

Procedure TAccrGraphForm.ShowAccrGraphs(TSS: Pointer);
Var SS: TSLAMM_Simulation;
    i: Integer;
Begin
  PSS := TSS;
  SS := TSS;

  SubSiteBox.Items.Clear;
  SubsiteBox.Items.Add('All Subsites');
  SubsiteBox.Items.Add('G: '+SS.Site.GlobalSite.Description);
  for i := 1 to SS.Site.NSubSites do
    SubsiteBox.Items.Add(IntToStr(i)+': '+SS.Site.SubSites[i-1].Description);
  SubsiteBox.ItemIndex := 0;
  MarshBox.ItemIndex := 0;

 {SHOW SCREEN}
  UpdateScreen;
  ShowModal;
End;

procedure TAccrGraphForm.UpdateScreen;
Var Val : Double;
    Xmin,Xmax,XVal: Double;
    SSLoop, Loop, NumValues: Integer;
    GraphError: Boolean;
    NewSeries: TLineSeries;
    SS: TSLAMM_Simulation;
    SubS: TSubSite;
    Cat: Integer;
    SeriesIndex: Integer;
    i, ModelNum: Integer;
    MinElev, MaxElev: Double;
    Cell: CompressedCell;
    CatFound: Boolean;

Begin
  SS := PSS;

  TRY

  ModelNum := MarshBox.ItemIndex;

  Cat := Blank;
  CatFound := False;
  For i :=  SS.Categories.NCats -1 downto 0 do
   If Not CatFound then
     Begin
      Case MarshBox.ItemIndex of
        0: If SS.Categories.GetCat(i).AccrModel = RegFM then CatFound := True;
        1: If SS.Categories.GetCat(i).AccrModel = IrregFM then CatFound := True;
        2: If SS.Categories.GetCat(i).AccrModel = BeachTF then CatFound := True;
        else If SS.Categories.GetCat(i).AccrModel = TidalFM then CatFound := True;
      End; {Case}
      If CatFound then Cat := i;
     End;

  If not CatFound then Begin ErrorPanel.Visible := True; ErrorPanel.BringtoFront; Exit; End;

  SeriesIndex := 0;
  While Chart1.SeriesCount>0 do Chart1.Series[0].Free;

  For SSLoop := 0 to SS.Site.NSubSites do
   If (SubSiteBox.ItemIndex = 0) // allsubsites
       or (SSLoop = SubSiteBox.ItemIndex-1) then
    Begin

      If SSLoop = 0 then SubS := SS.Site.GlobalSite
                    else SubS := SS.Site.SubSites[SSLoop-1];

      //Calculate min and max elevations in m
      MinElev := SS.LowerBound(Cat,SubS);
      MaxElev := SS.UpperBound(Cat,SubS);

      Xmin:=MinElev; XMax:=MaxElev;

        With Chart1 do
          begin
              NumValues:=99;

              NewSeries := TLineSeries.Create(Chart1);
              Inc(SeriesIndex);
              NewSeries.SeriesColor := ChartColors[SeriesIndex MOD 10];
              NewSeries.LinePen.Width := 2;
              If SeriesIndex<10 then NewSeries.LinePen.Style := psSolid
                                else NewSeries.LinePen.Style := psDash;

              If SSLoop = 0 then NewSeries.Title := 'G: '+SubS.Description
                            else NewSeries.Title := IntToSTr(SSLoop)+': '+SubS.Description;
              InitCell(@Cell);
              SETCELLWIDTH(@Cell,Cat,100);

              GraphError:=False;
              For Loop:=0 to NumValues do
                begin
                  XVal:=(((XMax-XMin)/NumValues)*loop)+XMin;

                  SetCatElev(@Cell,Cat,XVal);

                  Val := SS.DynamicAccretion(@Cell,Cat,SubS,ModelNum);

                  If HTUBox.Checked then XVal := XVal/SubS.MHHW;

                  NewSeries.AddXY(XVal,Val,'',clteecolor);
                end;

           Chart1.LeftAxis.LabelStyle := talValue;
           Chart1.AddSeries(NewSeries);

          End; {With Chart1}
    End; {SSLoop}

   Chart1.Title.Text.Clear;
   Memo1.Lines.Clear;
   Memo1.Lines.Add(MarshBox.Text+': '+SubSiteBox.Text);

   Chart1.Legend.Visible := SubSiteBox.ItemIndex = 0;

   If HTUBox.Checked then Chart1.BottomAxis.Title.Caption := 'Half-Tide Units (GT/2)'
                     else Chart1.BottomAxis.Title.Caption := 'Meters above MTL';

   If SubSiteBox.ItemIndex > 0 then
     With SubS do
     If not UseAccrModel[ModelNum]
       then Memo1.Lines.Add('Fixed Accretion Rate')
       else Memo1.Lines.Add('Max: '+FloatToStrf(MaxAccr[modelnum],ffgeneral,8,4)+'; '+
                            'Min: '+FloatToStrf(MinAccr[modelnum],ffgeneral,8,4)+'; '+
                            'A: '+FloatToStrf(AccrA[modelnum],ffgeneral,8,4)+'; '+
                            'B: '+FloatToStrf(AccrB[modelnum],ffgeneral,8,4)+'; '+
                            'C: '+FloatToStrf(AccrC[modelnum],ffgeneral,8,4)+'; '+
                            'D: '+FloatToStrf(AccrD[modelnum],ffgeneral,8,4));

   Memo1.Perform(EM_LINESCROLL, 0, -1);
   ErrorPanel.Visible := False;

  EXCEPT
    ErrorPanel.Visible:=True;
    ErrorPanel.BringToFront;
  End;

  update;
End;


procedure TAccrGraphForm.RetHandleClick(Sender: TObject);
begin
  UpdateScreen;
end;

procedure TAccrGraphForm.MarshBoxExit(Sender: TObject);
begin
  UpdateScreen;
end;

procedure TAccrGraphForm.OKBtnClick(Sender: TObject);
begin
  OKBtn.SetFocus;
end;

procedure TAccrGraphForm.Button1Click(Sender: TObject);
begin
  Chart1.CopyToClipboardMetafile(True);
end;

procedure TAccrGraphForm.Button2Click(Sender: TObject);
begin
  UpdateScreen;
end;

procedure TAccrGraphForm.Chart1ClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowMessage(Series.Title+', Elev: '+ Floattostrf(Series.XValue[valueindex],ffGeneral,6,3) + '; Accr: ' + Floattostrf(Series.YValue[valueindex],ffGeneral,6,3)+ 'mm/yr');
end;

procedure TAccrGraphForm.HTUBoxClick(Sender: TObject);
begin
  UpdateScreen;
end;

end.
