unit UnitIdClientAnd;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdThreadComponent, FMX.ScrollBox, FMX.Memo,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Objects;

type
  TForm3 = class(TForm)
    IdTCPClient1: TIdTCPClient;
    ToolBar1: TToolBar;
    ConnectBtn: TButton;
    Label1: TLabel;
    DisconnectBtn: TButton;
    SpeedButton1: TSpeedButton;
    MemoLog: TMemo;
    IPEdit: TEdit;
    CircleOut: TCircle;
    Circle1: TCircle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.iPhone4in.fmx IOS}

end.
