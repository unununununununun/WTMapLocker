unit U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, IOUtils, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, Windows,
  System.Win.Registry;

type
  TForm4 = class(TForm)
    ListBox1: TListBox;
    Edit1: TEdit;
    Label1: TLabel;
    btnSelectDir: TButton;
    Label2: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure ListBox1ChangeCheck(Sender: TObject);
    procedure SaveConfig;
    procedure LoadConfig;
    procedure UnlockAll;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RadioButton1Change(Sender: TObject);
  private
    FFilter: string;
    FIsLoadConfig: Boolean;
  public
    { Public declarations }
  end;

const buff_header: array [0..1] of Byte = ($FF, $44);

var
  Form4: TForm4;

implementation

{$R *.fmx}

procedure TForm4.SaveConfig;
begin
  var sl: TStringList := TStringList.Create;
  for var i: integer := 0 to ListBox1.Count - 1 do
    if ListBox1.ListItems[i].IsChecked then
      sl.Add(ListBox1.ListItems[i].Text);
  sl.SaveToFile(ExtractFileName(ParamStr(0)) + '.cfg');
end;

procedure TForm4.UnlockAll;
begin
  for var i: integer := 0 to ListBox1.Count - 1 do
  begin
    if FileExists(Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Items[i])) then
    begin
      TFile.Copy(Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Items[i]), ListBox1.Items[i], true);
      TFile.DElete(Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Items[i]));
    end;
  end;
  if DirectoryExists(Edit1.Text + 'bak\' ) then
    TDirectory.Delete(Edit1.Text + 'bak\' );
end;

function GetRegistryWTPath(KeyName: string): string;
 var Registry: TRegistry;
begin
 Registry := TRegistry.Create(KEY_READ);
 try
   Registry.RootKey := HKEY_CURRENT_USER;
   Registry.OpenKey(KeyName, False);
   Result := Registry.ReadString('dir');
 finally
   Registry.Free;
 end;
end;

procedure TForm4.btnSelectDirClick(Sender: TObject);
begin
  ListBox1.Clear;
  var dir: String := GetRegistryWTPath('SOFTWARE\Gaijin\WarThunder');
  if dir.IsEmpty then
    SelectDirectory('Select WT Maps direcftory', 'C:\', dir);
  if not dir.isEmpty then
  begin
    Edit1.Text := dir + '\levels\';
    for var Path:string in TDirectory.GetFiles(Edit1.Text, FFilter)  do
          Listbox1.Items.Add(Path);
  end;
end;

procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UnlockAll;
  SaveConfig
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  if FFilter.IsEmpty then
    FFilter := 'avg*';
  btnSelectDirClick(nil);
  if not DirectoryExists(Edit1.Text + '\bak') then
    IOUtils.TDirectory.CreateDirectory(Edit1.Text + '\bak');
  ListBox1.OnChangeCheck := nil;
  LoadConfig;
  ListBox1.OnChangeCheck := ListBox1ChangeCheck;
  for var i: Integer := 0 to ListBox1.Count - 1 do
  begin
    ListBox1.ItemIndex := i;
    ListBox1ChangeCheck(nil);
  end;
end;

procedure TForm4.ListBox1ChangeCheck(Sender: TObject);
begin
  var fs: TFileStream;
  if ListBox1.Selected.IsChecked then
  begin
    TFile.Copy(ListBox1.Selected.Text, Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Selected.Text), true);
    try
      fs := TFileStream.Create(ListBox1.Selected.Text, fmOpenReadWrite);
      ListBox1.Selected.Tag := 1;
      fs.Write(buff_header[0], 1);
    finally
      FreeAndNil(fs)
    end;
  end
  else
  begin
    if FileExists(Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Selected.Text)) then
    begin
      ListBox1.Selected.Tag := 0;
      TFile.Copy(Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Selected.Text), ListBox1.Selected.Text, true);
      TFile.Delete(Edit1.Text + 'bak\' + ExtractFileName(ListBox1.Selected.Text));
    end;
  end;
  if not FIsLoadConfig then
    SaveConfig;
end;

procedure TForm4.LoadConfig;
begin
  FIsLoadConfig := True;
  var sl: TStringList := TStringList.Create;
  sl.LoadFromFile(ExtractFileName(ParamStr(0)) + '.cfg');
  for var i: Integer := 0 to sl.Count - 1 do
  begin
    var idx: Integer := ListBox1.Items.IndexOf(sl.Strings[i]);
    if idx <> -1 then
    begin
      ListBox1.ItemIndex := idx;
      ListBox1.Selected.IsChecked := True;
    end;
  end;
  FIsLoadConfig := False;
end;

procedure TForm4.RadioButton1Change(Sender: TObject);
begin
  FFilter := TRadioButton(Sender).Text;
  FormCreate(nil)
end;

end.
