unit unitrob1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ShellCtrls,
  EditBtn, StdCtrls, ComCtrls, ExtCtrls, Buttons, Process, smtpsend, ssl_openssl;

type

  { TFireCopy }
    ESMTP = class (Exception);
  TFireCopy = class(TForm)
    Label1: TLabel;
    mBackup: TCheckBox;
    Memo1: TMemo;
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

{function SendMail(User, Password, MailFrom, MailTo, SMTPHost, SMTPPort: string; MailData: string
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
        ShowMessage (sl.GetText);
      end;
    finally

      SMTP.Free;
      sl.Free;
    end;
  end;
}

procedure AddToLog(const a: string);
begin
  FireCopy.Memo1.Lines.Add(a);
end;


procedure MailSend(const sSmtpHost, sSmtpPort, sSmtpUser, sSmtpPasswd, sFrom, sTo, sFileName: AnsiString);
var
  smtp: TSMTPSend;
  msg_lines: TStringList;
begin
  msg_lines := TStringList.Create;
  smtp := TSMTPSend.Create;
  try
    msg_lines.LoadFromFile(sFileName);
    msg_lines.Insert(0, 'From: ' + sFrom);
    msg_lines.Insert(1, 'To: ' + sTo);

    smtp.UserName := sSmtpUser;
    smtp.Password := sSmtpPasswd;

    smtp.TargetHost := sSmtpHost;
    smtp.TargetPort := sSmtpPort;


    AddToLog('SMTP Login');
    if Trim(sSMTPPort)<>'25' then
      SMTP.FullSSL:=true;
    if not smtp.Login() then
      raise ESMTP.Create('SMTP ERROR: Login:' + smtp.EnhCodeString);
    AddToLog('SMTP StartTLS');
    if not smtp.StartTLS() then
      raise ESMTP.Create('SMTP ERROR: StartTLS:' + smtp.EnhCodeString);

    AddToLog('SMTP Mail');
    if not smtp.MailFrom(sFrom, Length(sFrom)) then
      raise ESMTP.Create('SMTP ERROR: MailFrom:' + smtp.EnhCodeString);
    if not smtp.MailTo(sTo) then
      raise ESMTP.Create('SMTP ERROR: MailTo:' + smtp.EnhCodeString);
    if not smtp.MailData(msg_lines) then
      raise ESMTP.Create('SMTP ERROR: MailData:' + smtp.EnhCodeString);

    AddToLog('SMTP Logout');
    if not smtp.Logout() then
      raise ESMTP.Create('SMTP ERROR: Logout:' + smtp.EnhCodeString);
    AddToLog('OK!');
  finally
    msg_lines.Free;
    smtp.Free;
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
  FireCopy.Memo1.Clear;
  MailSend('smtp.gmail.com', '465', 'jabaselga@gmail.com', 'COMEXSISTEMAS', 'jabaselga@gmail.com',
        'ja@baselga.net',  'example.txt');

//  procedure MailSend(const sSmtpHost, sSmtpPort, sSmtpUser, sSmtpPasswd, sFrom, sTo, sFileName: AnsiString);

end;

end.

