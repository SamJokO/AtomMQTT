unit Atom.MQTT.Interfaces;

interface

uses
  System.SysUtils;

type
  IMQTTSocket = interface ['{2FD72D7F-E950-4592-B9E0-C9176B6B483B}']
    procedure                   SendBuffer(ABuffer: TBytes);
//    function                    Recv
  end;

  IMQTTClient = interface ['{9DB085CC-BA0F-44D6-B06D-25DDEC7DC255}']
  end;

  IMQTTBroker = interface ['{2E9B6239-22AA-461F-BD56-6723E4255F60}']
  end;

implementation

end.
