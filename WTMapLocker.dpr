program WTMapLocker;

uses
  System.StartUpCopy,
  FMX.Forms,
  U in 'U.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
