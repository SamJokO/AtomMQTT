program VclAPP;

uses
  Vcl.Forms,
  Form.Main in 'Form\Form.Main.pas' {Form1},
  Atom.MQTT.Interfaces in '..\..\Source\Atom.MQTT.Interfaces.pas',
  Atom.MQTT.Headers in '..\..\Source\Atom.MQTT.Headers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
