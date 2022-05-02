unit Atom.MQTT.Socket.Indy;

interface

uses
  IdTCPClient, IdSocks, IdGlobal,
  Atom.MQTT.Headers,
  Atom.MQTT.Interfaces;

type
  TIndyMQTTSocket = class (TBaseMQTTSocket)
  private
    FSocket                     : TIdTCPClient;

  protected
    procedure                   SendPacketToSocket(APacket: IMQTTPacket); override;
    procedure                   RecvPackets; override;

  public
    constructor                 Create(AVersion: TMQTTVersion = V_PREV_3_1); override;
    destructor                  Destroy; override;

    procedure                   ConnectTo(AHost: string; APort: Integer = 1883); override;

  end;

implementation

uses
  System.Classes,
  System.SysUtils;

{ TIndyMQTTSocket }

procedure TIndyMQTTSocket.ConnectTo(AHost: string; APort: Integer);
begin
  FSocket.Connect(AHost, APort);
end;

constructor TIndyMQTTSocket.Create(AVersion: TMQTTVersion);
begin
  inherited;

  FSocket                     := TIdTCPClient.Create(nil);
end;

destructor TIndyMQTTSocket.Destroy;
begin
  if Assigned(FSocket) then
  begin
    if FSocket.Connected then
    begin
      FSocket.Disconnect;
    end;
    FSocket.Free;
  end;

  inherited;
end;

procedure TIndyMQTTSocket.RecvPackets;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      while not IsTerminated do
      begin
        if FSocket.Connected then
        begin
          //
          // 분할해서 패킷 받는거 확인
          FSocket.IOHandler.InputBuffer.PeekByte()
        end;
      end;
    end
  ).Start;
end;

procedure TIndyMQTTSocket.SendPacketToSocket(APacket: IMQTTPacket);
var
  vBuffer                     : TBytes;
begin
  vBuffer                     := APacket.GetBytes;
  FSocket.IOHandler.Write(TIdBytes(vBuffer));
end;

end.
