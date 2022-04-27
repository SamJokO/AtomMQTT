unit Atom.MQTT.Headers;

interface

uses
  System.SysUtils;

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

  TMQTTQoSType                = (
                                  AT_MOST_ONCE,       // 0
                                  AT_LEAST_ONCE,      // 1
                                  EXACTLY_ONCE        // 2
                                );

  TMQTTVersion                = (
                                  V_PREV_3_1,         // Previous 3.1 and with 3.1
                                  V_NEXT_3_1_1,       // Next 3.1 without 3.1
                                  V_NEXT_5            // Next 5 without 5
                                );

{
                       |   7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |
  FixedHeader Byte(1)  |   Control Packet Type  |        Flags          |
             Byte(2~n) |   Remaining Length (1 ~ 4byte, Total Length    | (without FixhedHeader Length)
  VariableHeader (3~n) |   Optional: Variable Length Header             |
  Payload      (n+1~m) |   Optional: Variable Length Message Payload    |
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

  TMQTTConnectFlags = packed record
  private
    function                    GetBits(const AIndex: Integer): Integer;
    procedure                   SetBits(const AIndex: Integer; const AValue: Integer);
  public
    Flags                       : Byte;

    property                    UserName: Integer index $0701 read GetBits write SetBits;
    property                    Password: Integer index $0601 read GetBits write SetBits;
    property                    WillRetain: Integer index $0501 read GetBits write SetBits;
    property                    WillQos: Integer index $0302 read GetBits write SetBits;
    property                    WillFlag: Integer index $0201 read GetBits write SetBits;
    property                    CleanStart: Integer index $0101 read GetBits write SetBits;
    property                    Reserved: Integer index $0001 read GetBits write SetBits;

  end;

  TMQTTVariableHeader = class
  private
    FBytes                      : TBytes;
  protected
    procedure                   AddField(AValue: Byte); overload;
    procedure                   AddField(AValues: TBytes); overload;
    procedure                   ClearField;
  public
    constructor                 Create;
    function                    ToBytes: TBytes; virtual;
  end;

const
  RC_SUCCESS                  = $00;
  RC_NORMAL_DISCONNECTION     = $00;
  RC_GRANTED_QOS_0            = $00;
  RC_GRANTED_QOS_1            = $01;
  RC_GRANTED_QOS_2            = $02;
  RC_DISCONNECT_WITH_WILL_MESSAGE
                              = $04;

  RC_NO_MATCHING_SUBSCRIBER   = $10;
  RC_NO_SUBSCRIPTION_EXISTED  = $11;

  RC_CONTINUE_AUTHENTICATION  = $18;
  RC_RE_AUTHENTICATE          = $19;

  RC_UNSPECIFIED_ERROR        = $80;
  RC_MALFORMED_PACKET         = $81;
  RC_PROTOCOL_ERROR           = $82;
  RC_IMPLEMENTATION_SPECIFIC_ERROR
                              = $83;
  RC_UNSUPPORTED_PROTOCOL_VERSION
                              = $84;
  RC_CLIENT_IDENTIFIER_NOT_VALID
                              = $85;
  RC_BAD_USER_NAME_OR_PASSWORD= $86;
  RC_NOT_AUTHORIZED           = $87;
  RC_SERVER_UNAVAILABLE       = $88;
  RC_SERVER_BUSY              = $89;
  RC_BANNED                   = $8A;
  RC_SERVER_SHUTTING_DOWN     = $8B;
  RC_BAD_AUTHENTICATION_METHOD= $8C;
  RC_KEEP_ALIVE_TIMEOUT       = $8D;
  RC_SESSION_TAKEN_OVER       = $8E;
  RC_TOPIC_FILTER_INVALID     = $8F;
  RC_TOPIC_NAME_INVALID       = $90;
  RC_PACKET_IDENTIFIER_IN_USE = $91;
  RC_PACKET_IDENTIFIER_NOT_FOUND
                              = $92;
  RC_RECEIVE_MAXIMUM_EXCEEDED = $93;
  RC_TOPIC_ALIAS_INVALID      = $94;
  RC_PACKET_TOO_LARGE         = $95;
  RC_MESSAGE_RATE_TOO_HIGH    = $96;
  RC_QUOTA_EXCEEDED           = $97;
  RC_ADMINISTRATIVE_ACTION    = $98;
  RC_PAYLOAD_FORMAT_INVALID   = $99;
  RC_RETAIN_NOT_SUPPORTED     = $9A;
  RC_QOS_NOT_SUPPORTED        = $9B;
  RC_USE_ANOTHER_SERVER       = $9C;
  RC_SERVER_MOVED             = $9D;
  RC_SHARED_SUBSCRIPTIONS_NOT_SUPPORTED
                              = $9E;
  RC_CONNECTION_RATE_EXCEEDED = $9F;
  RC_MAXIMUM_CONNECT_TIME     = $A0;
  RC_SUBSCRIPTION_IDENTIFIERS_NOT_SUPPORTED
                              = $A1;
  RC_WILDCARD_SUBSCRIPTIONS_NOT_SUPPORTED
                              = $A2;


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

{ TMQTTConnectFlags }

function TMQTTConnectFlags.GetBits(const AIndex: Integer): Integer;
begin
  Result                      := GetDWordBits(Flags, AIndex);
end;

procedure TMQTTConnectFlags.SetBits(const AIndex, AValue: Integer);
begin
  SetDWordBits(Flags, AIndex, AValue);
end;

{ TMQTTVariableHeader }

procedure TMQTTVariableHeader.AddField(AValue: Byte);
var
  vLength                     : Integer;
begin
  vLength                     := Length(FBytes);
  SetLength(FBytes, vLength + SizeOf(AValue));
  Move(AValue, FBytes[vLength], SizeOf(AValue));
end;

procedure TMQTTVariableHeader.AddField(AValues: TBytes);
var
  vLength                     : Integer;
begin
  vLength                     := Length(FBytes);
  SetLength(FBytes, vLength + Length(AValues));
  Move(AValues[0], FBytes[vLength], Length(AValues));
end;

procedure TMQTTVariableHeader.ClearField;
begin
  SetLength(FBytes, 0);
end;

constructor TMQTTVariableHeader.Create;
begin
  //
end;

function TMQTTVariableHeader.ToBytes: TBytes;
begin
  Result                      := FBytes;
end;

end.
