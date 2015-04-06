unit unitrob1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ShellCtrls,
  EditBtn, StdCtrls, ComCtrls, ExtCtrls, Buttons, Process, smtpsend;

type

  { TFireCopy }

  TFireCopy = class(TForm)
    Label1: TLabel;
    mBackup: TCheckBox;
    Seg_NTFS: TCheckBox;
    MIR: TCheckBox;
    Log: TCheckBox;
    LogFile: TEdit;
    RoboCopy: TButton;
    Origen: TDirectoryEdit;
    Destino: TDirectoryEdit;
    procedure LogFileChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RoboCopyClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FireCopy: TFireCopy;
  i: integer = 1;
  comando: TProcess;


implementation

function SendMail(User, Password, MailFrom, MailTo, SMTPHost, SMTPPort: string; MailData: string
    ): Boolean;
  var
    SMTP: TSMTPSend;
    sl:TStringList;
  begin
    Result:=False;
    SMTP:=TSMTPSend.Create;
    sl:=TStringList.Create;
    try
      sl.text:=Maildata;
      SMTP.UserName:=User;
      SMTP.Password:=Password;
      SMTP.TargetHost:=SMTPHost;
      SMTP.TargetPort:=SMTPPort;
      SMTP.AutoTLS:=true;
      if SMTPPort<> '25' then
        SMTP.FullSSL:=true;
      if SMTP.Login then
      begin
        result:=SMTP.MailFrom(MailFrom, Length(MailData)) and
           SMTP.MailTo(MailTo) and
           SMTP.MailData(sl);
        SMTP.Logout;
      end;
    finally
      SMTP.Free;
      sl.Free;
    end;
  end;
{$R *.lfm}

{ TFireCopy }

procedure TFireCopy.FormCreate(Sender: TObject);
begin

end;

procedure TFireCopy.LogFileChange(Sender: TObject);
begin

end;

procedure TFireCopy.RoboCopyClick(Sender: TObject);
var
  unalista: TStringList;
begin
  i := i + 1;
  // Creamos el objeto TStringList.
  UnaLista := TStringList.Create;

  // Ahora creamos UnProceso.
  comando := TProcess.Create(nil);

  // Asignamos a UnProceso la orden que debe ejecutar.
  // Vamos a lanzar el compilador de FreePascal
  comando.Executable := 'robocopy';
  comando.Parameters.Add(Origen.Directory);
  comando.Parameters.Add(Destino.Directory);
  comando.Parameters.Add('/s');

  if MIR.Checked then
    comando.Parameters.Add('/mir');
  if Seg_NTFS.Checked then
      comando.Parameters.Add('/COPYALL');
  if mBackup.Checked then
    comando.Parameters.Add('/b');
  if Log.Checked then
    comando.Parameters.Add('/log:' + LogFile.Text+'.log');


  // We will define an option for when the program
  // is run. This option will make sure that our program
  // does not continue until the program we will launch
  // has stopped running.              vvvvvvvvvvvvvv
  comando.Options := comando.Options + [poWaitOnExit];
  ShowMessage(comando.Parameters.GetText());

  comando.Execute;
  // Ahora leemos la salida del programa que acabamos de ejecutar
  // dentro de TStringList.
  // UnaLista.LoadFromStream(comando.Output);

  // Guardamos la salida en un archivo.
  UnaLista.SaveToFile('salida.txt');

  // Nuestro programa espera hasta que 'ppc386' finaliza.



  // We will define an option for when the program
  // is run. This option will make sure that our program
  // does not continue until the program we will launch
  // has stopped running.              vvvvvvvvvvvvvv
  comando.Options := comando.Options + [poWaitOnExit];

  comando.Execute;
  comando.Free;

  SendMail('jabaselga@gmail.com', 'COMEXSISTEMAS', 'jabaselga@gmail.com',
        'ja@baselga.net', 'smtp.gmail.com', '587', 'preuba');


end;

end.

