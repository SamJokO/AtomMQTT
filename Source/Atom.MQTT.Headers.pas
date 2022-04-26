unit Atom.MQTT.Headers;

interface

type
  TMQTTPacketType             = (
                                  Reserved,           // 0 : Reserved
                                  CONNECT,            // 1 : Client to Server, Connection reqeust
                                  CONNACK,            // 2 : Server To Client, Connect acknowledgment
                                  PUBLISH,            // 3 : Client to Server or Server to Client, Publish message
                                  PUBACK,             // 4 : Client to Server or Server To Client, Publish acknowledgment (QoS 1)
                                  PUBREC,             // 5 : Client to Server or Server To Client, Publish received (QoS 2 delivery part 1)
                                  PUBREL,             // 6 : Client to Server or Server to Client, Publish release (QoS 2 delivery part 2)
                                  PUBCOMP,            // 7 : Client to Server or Server to Client, Publish complete (QoS 2 delivery part 3)
                                  SUBSCRIBE,          // 8 : Client to Server, Subscribe request
                                  SUBACK,             // 9 : Server to Client, Subscribe acknowledgment
                                  UNSUBSCRIBE,        // 10 : Client to Server, Unsubscribe request
                                  UNSUBACK,           // 11 : Server to Client, Unsubscribe acknowledgment
                                  PINGREQ,            // 12 : Client to Server, PING request
                                  PINGRESP,           // 13 : Server to Client, PING response
                                  DISCONNECT,         // 14 : Client to Server or Server to Client, Disconnect notification
                                  AUTH                // 15 : Client to Server or Server to Client, Authentication exchange
                                );

{

}

  TMQTTFlags = packed record
  private
    function                    GetBits(const AIndex: Integer): Integer;
    procedure                   SetBits(const AIndex: Integer; const AValue: Integer);
  public
    Flags                       : Byte;

    property                    PacketType: Integer index $0404 read GetBits write SetBits;
    property                    Duplicate: Integer index $0301 read GetBits write SetBits;
    property                    QoSLevel: Integer index $0102 read GetBits write SetBits;
    property                    Retain: Integer index $0001 read GetBits write SetBits;

  end;

implementation

function GetDWordBits(const ABits: Byte; const AIndex: Integer): Integer;
begin
  Result                      := (ABits shr (AIndex shr 8)) and ((1 shl Byte(AIndex)) - 1);
end;

procedure SetDWordBits(var ABits: Byte; const AIndex: Integer; const AValue: Integer);
var
  vOffset                     : Byte;
  vMask                       : Integer;
begin
  vMask                       := ((1 shl Byte(AIndex)) - 1);
  Assert(AValue <= vMask);

  vOffset                     := AIndex shr 8;
  ABits                       := (ABits and (not (vMask shl vOffset))) or FixedUInt(AValue shl vOffset);
end;

{ TMQTTFlags }

function TMQTTFlags.GetBits(const AIndex: Integer): Integer;
begin
  Result                      := GetDWordBits(Flags, AIndex);
end;

procedure TMQTTFlags.SetBits(const AIndex, AValue: Integer);
begin
  SetDWordBits(Flags, AIndex, AValue);
end;

end.
