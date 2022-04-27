unit Atom.MQTT.Interfaces;

interface

uses
  Atom.MQTT.Headers,
  System.SysUtils;

type
  IMQTTPacket = interface ['{CFB71C7B-FDC3-4043-A43C-7705755FAD7C}']
  end;

  IMQTTSocket = interface ['{2FD72D7F-E950-4592-B9E0-C9176B6B483B}']
    procedure                   SendPacket(APacket: IMQTTPacket);
    function                    RecvPacket: IMQTTPacket;
  end;

  TBaseMQTTSocket = class (TInterfacedObject, IMQTTSocket)
  private
    FMQTTVersion                : TMQTTVersion;

  public
    procedure                   SendPacket(APacket: IMQTTPacket); virtual; abstract;
    function                    RecvPacket: IMQTTPacket; virtual; abstract;

    constructor                 Create(AVersion: TMQTTVersion = V_PREV_3_1);
  end;

  IMQTTClient = interface ['{9DB085CC-BA0F-44D6-B06D-25DDEC7DC255}']
  end;

  IMQTTBroker = interface ['{2E9B6239-22AA-461F-BD56-6723E4255F60}']
  end;

implementation

{ TBaseMQTTSocket }

constructor TBaseMQTTSocket.Create(AVersion: TMQTTVersion);
begin
  FMQTTVersion                := FMQTTVersion;
end;

end.
