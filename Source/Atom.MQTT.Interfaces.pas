unit Atom.MQTT.Interfaces;

interface

uses
  Atom.MQTT.Headers,
  System.Generics.Collections,
  System.Classes,
  System.SysUtils;

type
  IMQTTPacket = interface ['{CFB71C7B-FDC3-4043-A43C-7705755FAD7C}']
    function                    GetBytes: TBytes;
  end;

  TOnMQTTPacketReceive        = procedure (ASender: TObject; APacket: IMQTTPacket) of object;
  TOnMQTTSocketConnected      = procedure (ASender: TObject) of object;
  TOnMQTTSocketDisconnect     = procedure (ASender: TObject) of object;

  /// <summary>
  ///  MQTT 패킷 분석 및 조합 하여 socket으로 전달하는 인터페이스
  /// </summary>
  IMQTTParser = interface ['{3CA71611-D9A2-4CFA-A03C-E4C33FB8F22C}']
    /// <summary>
    ///  Socket에서 받은 스트림 (TBytes)를 받아서 분석 처리하는 곳
    function                    DoParse(ABuffer: TBytes): Boolean;
  end;

  IMQTTSocket = interface ['{2FD72D7F-E950-4592-B9E0-C9176B6B483B}']
    function                    GetIsTerminated: Boolean;

    procedure                   SetOnMQTTPacketReceive(AProc: TOnMQTTPacketReceive);
    function                    GetOnMQTTPacketReceive: TOnMQTTPacketReceive;
    procedure                   SetOnMQTTSocketConnected(AProc: TOnMQTTSocketConnected);
    function                    GetOnMQTTSocketConnected: TOnMQTTSocketConnected;
    procedure                   SetOnMQTTSocketDisconnect(AProc: TOnMQTTSocketDisconnect);
    function                    GetOnMQTTSocketDisconnect: TOnMQTTSocketDisconnect;

    procedure                   SendPacket(APacket: IMQTTPacket);
    procedure                   ConnectTo(AHost: string; APort: Integer = 1883);

    property                    IsTerminated: Boolean read GetIsTerminated;
    property                    OnMQTTPacketReceive: TOnMQTTPacketReceive read GetOnMQTTPacketReceive write SetOnMQTTPacketReceive;
    property                    OnMQTTSocketConnected: TOnMQTTSocketConnected read GetOnMQTTSocketConnected write SetOnMQTTSocketConnected;
    property                    OnMQTTSocketDisconnect: TOnMQTTSocketDisconnect read GetOnMQTTSocketDisconnect write SetOnMQTTSocketDisconnect;
  end;

  TBaseMQTTSocket = class (TInterfacedObject, IMQTTSocket)
  private
    FPacketQueue                : TThreadedQueue<IMQTTPacket>;

    FMQTTVersion                : TMQTTVersion;

    FOnMQTTPacketReceive        : TOnMQTTPacketReceive;
    FOnMQTTSocketConnected      : TOnMQTTSocketConnected;
    FOnMQTTSocketDisconnect     : TOnMQTTSocketDisconnect;

    FIsTerminated               : Boolean;

    function                    GetIsTerminated: Boolean;

    procedure                   SetOnMQTTPacketReceive(AProc: TOnMQTTPacketReceive);
    function                    GetOnMQTTPacketReceive: TOnMQTTPacketReceive;

    procedure                   SetOnMQTTSocketConnected(AProc: TOnMQTTSocketConnected);
    function                    GetOnMQTTSocketConnected: TOnMQTTSocketConnected;
    procedure                   SetOnMQTTSocketDisconnect(AProc: TOnMQTTSocketDisconnect);
    function                    GetOnMQTTSocketDisconnect: TOnMQTTSocketDisconnect;

  protected
    procedure                   SendPacketToSocket(APacket: IMQTTPacket); virtual; abstract;
    procedure                   RecvPackets; virtual; abstract;

  public
    property                    IsTerminated: Boolean read GetIsTerminated;
    property                    OnMQTTPacketReceive: TOnMQTTPacketReceive read GetOnMQTTPacketReceive write SetOnMQTTPacketReceive;
    property                    OnMQTTSocketConnected: TOnMQTTSocketConnected read GetOnMQTTSocketConnected write SetOnMQTTSocketConnected;
    property                    OnMQTTSocketDisconnect: TOnMQTTSocketDisconnect read GetOnMQTTSocketDisconnect write SetOnMQTTSocketDisconnect;

    procedure                   SendPacket(APacket: IMQTTPacket);
    procedure                   ConnectTo(AHost: string; APort: Integer = 1883); virtual; abstract;

    constructor                 Create(AVersion: TMQTTVersion = V_PREV_3_1); virtual;
    destructor                  Destroy; override;
  end;

  IMQTTClient = interface ['{9DB085CC-BA0F-44D6-B06D-25DDEC7DC255}']
  end;

  IMQTTBroker = interface ['{2E9B6239-22AA-461F-BD56-6723E4255F60}']
  end;

implementation

uses
  System.Types;

{ TBaseMQTTSocket }

constructor TBaseMQTTSocket.Create(AVersion: TMQTTVersion);
begin
  FMQTTVersion                := FMQTTVersion;
  FPacketQueue                := TThreadedQueue<IMQTTPacket>.Create(128, INFINITE, 10);
  FIsTerminated               := False;

  TThread.CreateAnonymousThread(
    procedure
    var
      vQueueSize                  : Integer;
      vPacket                     : IMQTTPacket;
    begin
      while not FIsTerminated do
      begin
        if FPacketQueue.PopItem(vPacket) = wrSignaled then
        begin
          if FIsTerminated then
            Exit;

          SendPacketToSocket(vPacket);
        end;
      end;
    end
  ).Start;
end;

destructor TBaseMQTTSocket.Destroy;
begin
  FIsTerminated               := True;
  FPacketQueue.DoShutDown;
  FPacketQueue.Free;

  inherited;
end;

function TBaseMQTTSocket.GetIsTerminated: Boolean;
begin
  Result                      := FIsTerminated;
end;

function TBaseMQTTSocket.GetOnMQTTPacketReceive: TOnMQTTPacketReceive;
begin
  Result                      := FOnMQTTPacketReceive;
end;

function TBaseMQTTSocket.GetOnMQTTSocketConnected: TOnMQTTSocketConnected;
begin
  Result                      := FOnMQTTSocketConnected;
end;

function TBaseMQTTSocket.GetOnMQTTSocketDisconnect: TOnMQTTSocketDisconnect;
begin
  Result                      := FOnMQTTSocketDisconnect;
end;

procedure TBaseMQTTSocket.SendPacket(APacket: IMQTTPacket);
begin
  FPacketQueue.PushItem(APacket);
end;

procedure TBaseMQTTSocket.SetOnMQTTPacketReceive(AProc: TOnMQTTPacketReceive);
begin
  FOnMQTTPacketReceive        := AProc;
end;

procedure TBaseMQTTSocket.SetOnMQTTSocketConnected(
  AProc: TOnMQTTSocketConnected);
begin
  FOnMQTTSocketConnected      := AProc;
end;

procedure TBaseMQTTSocket.SetOnMQTTSocketDisconnect(
  AProc: TOnMQTTSocketDisconnect);
begin
  FOnMQTTSocketDisconnect     := AProc;
end;

end.
