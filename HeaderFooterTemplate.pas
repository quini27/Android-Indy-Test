//******************************************************************************
//   Indy Test for Android
//   Program to communicate a IoT module with an Android device
//   The IoT module acts as a server and the Android device as a client.
//   The IoT module must have the sketch test_indy.ino previously stored
//
//
// This application allows the user to communicate the Android device with an IoT device
//(Wemos or nodeMCU) using Indy components. The application has been written in
//Delphi and has been developed using the IDE RAD Studio ToKio 10.3
//
//In the application, the user must introduce firstly the IP address (local or public) and the port of
//the IoT device. The test_indy sketch set the local IP address to 192.168.0.200
// and the port to 100. If a public IP is used, it must be the public IP of the
//router, which must have the port 100 open (forwarding operation).
//
// Once the IP address and the port number are introduced, the device can be connected.
// A led drawn on the screen shows the connection status.
//A memo log window shows the state of the connection and prints the sentences sent by the
//server.
//Words can be written in a edit box and sent to de IoT device, which prints them in a serial monitor
//(if a serial monitor is connected). These words can be the commands
//    /LED=ON (to put on the builtin led on the board),
//    /LED=OFF (to put off the builtin led on the board),
//    /STATEBUTTON (to require the state of the builtin button (pressed or unpressed)
//         which will be printed on the Memo Log window.
//         This command only works with the nodeMCU board because the Wemos board
//         does not have a builtin button)
//    /STOPCLIENT (to close the connection, which also happens when the disconnect button is pressed)






unit HeaderFooterTemplate;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Edit, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, FMX.ScrollBox, FMX.Memo,
  System.ImageList, FMX.ImgList, IdThreadComponent;

type
  THeaderFooterForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    connectBtn: TButton;
    disconnectBtn: TButton;
    Circle1: TCircle;
    led: TCircle;
    Label1: TLabel;
    IdTCPClient1: TIdTCPClient;
    IPLabel: TLabel;
    EditIPaddress: TEdit;
    MemoLog: TMemo;
    Label2: TLabel;
    EditMsg: TEdit;
    SendBtn: TSpeedButton;
    ImageList1: TImageList;
    PortLabel: TLabel;
    EditPort: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure IdThreadComponentRun(Sender: TIdThreadComponent);
    procedure MemoLogChange(Sender: TObject);
    procedure connectBtnClick(Sender: TObject);
    procedure disconnectBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
    procedure EditPortChange(Sender: TObject);
    procedure EditIPaddressChange(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HeaderFooterForm: THeaderFooterForm;
         // ... TIdThreadComponent
  idThreadComponent   : TIdThreadComponent;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}

//Create an IdThreadComponent and assign the On Run event to a procedure
procedure THeaderFooterForm.FormCreate(Sender: TObject);
begin
    // ... create TIdThreadComponent
    idThreadComponent           := TIdThreadComponent.Create();
    // ... callback functions
    idThreadComponent.OnRun     := IdThreadComponentRun;
    EditIpAddress.Text:=IdTCPClient1.Host;
    EditPort.Text:=IntToStr(IdTCPClient1.Port);
    MemoLog.Canvas.Fill.Color:=$FF000001;         //no color
end;




//Event executed when the connect button is clicked
procedure THeaderFooterForm.connectBtnClick(Sender: TObject);
begin
    try
        IdTCPClient1.Connect;
    except
        on E: Exception do begin
            MemoLog.Lines.Add('Connection error: '+E.Message);
            //connect_btn.Enabled := True;
        end;
    end;
end;

//EVENT executed when disconnect button on click
procedure THeaderFooterForm.disconnectBtnClick(Sender: TObject);
begin
     //IdTCPClient1.IOHandler.close;
      IdTCPClient1.IOHandler.Writeln('/STOPCLIENT');       //warns the server to disconnect the client
      IdTCPClient1.Disconnect;
      //IdTCPClient1Disconnected(Sender)
end;

//EVENT executed when the IP address is changed
procedure THeaderFooterForm.EditIPaddressChange(Sender: TObject);
begin
  IdTCPClient1.Host:=EditIPaddress.Text
end;

//EVENT executed when the port number is changed
procedure THeaderFooterForm.EditPortChange(Sender: TObject);
begin
    IdTCPClient1.Port:=StrToInt(EditPort.Text)
end;



//final event executed when form is closed
procedure THeaderFooterForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    if IdTCPClient1.connected then IdTCPClient1.Disconnect
end;


//*****************************************************************************
//EVENT  : On Connected
//            executed when IdTCPClient is connected
//*****************************************************************************
procedure THeaderFooterForm.IdTCPClient1Connected(Sender: TObject);
begin
    disconnectBtn.Enabled:=True;
    connectBtn.Enabled:=False;
    led.Fill.Color:=$FFFF0000;        //led color=red
    EditMsg.Enabled:=true;
    SendBtn.Enabled:=true;
    EditIPAddress.ReadOnly:=True;
    EditPort.ReadOnly:=True;
    MemoLog.Lines.Add('Client connected to server '+IdTCPClient1.Host+' at '+#13#10+'   '+FormatDateTime('hh:nn:ss', Now));
    //read welcome message
    MemoLog.Lines.Add('Server says: '+IdTCPClient1.IOHandler.ReadLn());
    //MemoLog.Lines.Add('Server also says: '+IdTCPClient1.IOHandler.ReadLn());  connectBtn.Enabled:=false;
    IdTCPClient1.IOHandler.Writeln('Hello server');
    //IdTCPClient1.IOHandler.Writeln('/LED=OFF');
    idThreadComponent.Active:=true;       //active idThreadComponent
end;



//*****************************************************************************
//EVENT  : On Disconnected
//            executed when IdTCPClient is disconnected
//*****************************************************************************
procedure THeaderFooterForm.IdTCPClient1Disconnected(Sender: TObject);
begin
     idThreadComponent.Active:=false;
     connectBtn.Enabled:=True;
     disconnectBtn.Enabled:=False;
     led.Fill.Color:=$FF800000;     //led color=maroon
     EditMsg.Enabled:=False;
     SendBtn.Enabled:=False;
     EditIPAddress.ReadOnly:=False;
     EditPort.ReadOnly:=False;
     MemoLog.Lines.Add('Client disconnected of server '+IdTCPClient1.Host+' at '+#13#10+'   '+FormatDateTime('hh:nn:ss', Now));
end;


//*****************************************************************************
//Event executed when the Send button is pressed
procedure THeaderFooterForm.SendBtnClick(Sender: TObject);
var str2send:string;
begin
  if EditMsg.Text<>'' then
    begin
        if EditMsg.Text='/STOPCLIENT' then
          disconnectBtnClick(Sender)
        else
          begin
            str2send:=EditMsg.Text;
            {if not IdTCPClient1.connected then
              begin
                IdTCPClient1.Connect;
                IdTCPClient1.Socket.WriteLn(str2send);
              end;
            EditMess.Text:='';}
            IdTCPClient1.IOHandler.Writeln(str2send);
          end;
        EditMsg.Text:=''
      end
end;


// *****************************************************************************
//   EVENT : onRun()
//           OCCURS WHEN THE CLIENT RECEIVES A MESSAGE FROM THE SERVER
// *****************************************************************************
procedure THeaderFooterForm.IdThreadComponentRun(Sender: TIdThreadComponent);
var  msgFromServ : string;
begin
    // ... read message from server
    msgFromServ := IdTCPClient1.IOHandler.ReadLn();
    MemoLog.Lines.Add('Message from server: '+msgFromServ)
end;


//EVENT executed when MemoLog is on change to scroll the memoLog until the last row
procedure THeaderFooterForm.MemoLogChange(Sender: TObject);
begin
  MemoLog.ScrollBy(0,MemoLog.Lines.Count);
  //SendMessage(MemoLog.Handle, EM_LINESCROLL, 0,MemoLog.Lines.Count);
end;



end.
