unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, StdCtrls, uConexao, ZDbcIntfs, cUsuarioLogado, uUtils,
  uAtualizaDB, LCLIntf, PopupNotifier, ZCompatibility;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    imgMysql: TImage;
    Label1: TLabel;
    mmuCadastro: TMenuItem;
    mmuAcoesDeAcesso: TMenuItem;
    mmuPermissaoDeAcoesParaUsuario: TMenuItem;
    mmuUsuario: TMenuItem;
    mmuSeparacao2: TMenuItem;
    mmuFechar: TMenuItem;
    mmuPrincipal: TMainMenu;
    pnlDbImg: TPanel;
    pgcForms: TPageControl;
    Panel1: TPanel;
    StbPrincipal: TStatusBar;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgMysqlClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure mmuAcoesDeAcessoClick(Sender: TObject);
    procedure mmuCategoriaClick(Sender: TObject);
    procedure mmuFecharClick(Sender: TObject);
    procedure mmuPermissaoDeAcoesParaUsuarioClick(Sender: TObject);
    procedure mmuUsuarioClick(Sender: TObject);
  private
    procedure AtualizacaoBancoDados(aForm: TfrmAtualizaBancoDados);
    procedure CriarAcoes;

  public

  end;

var
  frmPrincipal: TfrmPrincipal;
  oUsuarioLogado: TUsuarioLogado;

implementation

{$R *.lfm}

uses uCadUsuario, cArquivoIni, cAtualizacaoBancoDeDados, uLogin,
     cAcaoAcesso, uCadAcaoAcesso, cInstanciarForm, uUsuarioVsAcoes;

{ TfrmPrincipal }


procedure TfrmPrincipal.mmuCategoriaClick(Sender: TObject);
begin

end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var  bfinalizarAplicacao:Boolean;
begin
  bfinalizarAplicacao:=false;
  try
    frmAtualizaBancoDados:=TfrmAtualizaBancoDados.Create(self);
    frmAtualizaBancoDados.Show;
    frmAtualizaBancoDados.Refresh;

    if not FileExists(TArquivoIni.ArquivoIni) then  begin
      TArquivoIni.AtualizarIni('SERVER', 'TipoDataBase', 'MYSQL');
      TArquivoIni.AtualizarIni('SERVER', 'HostName', 'localhost');
      TArquivoIni.AtualizarIni('SERVER', 'Port', '3306');
      TArquivoIni.AtualizarIni('SERVER', 'User', 'root');
      TArquivoIni.AtualizarIni('SERVER', 'Password', '123456');
      TArquivoIni.AtualizarIni('SERVER', 'Database', 'dbvendas');
      MessageOK('Arquivo '+ TArquivoIni.ArquivoIni +' Criado com sucesso' +#13+
                 'Configure o arquivo antes de inicializar aplicação',MtInformation);

     //Application.Terminate;
     bfinalizarAplicacao:=true;

    end
    else begin
      DtmPrincipal:=TDtmPrincipal.Create(self);     //Instancia o DataModule
      with DtmPrincipal.ConDataBase do begin
        Connected:=False;
        SQLHourGlass:=true;                        //Habilita o Cursor em cada transação no banco de dados
       // LibraryLocation:=ExtractFilePath(Application.ExeName)+'dll\libmysql.dll';  //Seta a DLL para conexao do SQL
        LibraryLocation:=ExtractFilePath(Application.ExeName)+'dll\libmariadb.dll';  //Seta a DLL para conexao do SQL
        Protocol:='mysql';            //Protocolo do banco de dados
        ControlsCodePage:=cCP_UTF8;
        ClientCodepage:='';
        imgMysql.Visible:=true;

        HostName:= TArquivoIni.LerIni('SERVER','HostName'); //Instancia do SQLServer
        Port    := StrToInt(TArquivoIni.LerIni('SERVER','Port'));  //Porta do SQL Server
        User    := TArquivoIni.LerIni('SERVER','User');  //Usuario do Banco de Dados
        Password:= TArquivoIni.LerIni('SERVER','Password');  //Senha do Usuário do banco
        Database:= TArquivoIni.LerIni('SERVER','DataBase');;  //Nome do Banco de Dados
        AutoCommit:= True;
        TransactIsolationLevel:=tiReadCommitted;
        Connected:=True;  //Faz a Conexão do Banco

        AtualizacaoBancoDados(frmAtualizaBancoDados);
        CriarAcoes;

      end;
    end;

    //AtualizacaoBancoDados(frmAtualizaBancoDados);
    //CriarAcoes;
    //
  finally
     frmAtualizaBancoDados.Free;
  end;
  
  if bfinalizarAplicacao then
     begin
      Application.Terminate;
      halt;
     end;

end;

procedure TfrmPrincipal.CriarAcoes;
begin
  try
    TAcaoAcesso.CriarAcoes(TfrmCadUsuario,  DtmPrincipal.ConDataBase);
    TAcaoAcesso.CriarAcoes(TfrmCadAcaoAcesso,DtmPrincipal.ConDataBase);
    TAcaoAcesso.CriarAcoes(TfrmUsuarioVsAcoes,DtmPrincipal.ConDataBase);
  finally
    TAcaoAcesso.PreencherUsuariosVsAcoes(DtmPrincipal.ConDataBase);
  end;
end;

procedure TfrmPrincipal.AtualizacaoBancoDados(aForm:TfrmAtualizaBancoDados);
var oAtualizarDB:TAtualizaBancoDados;
begin
  try
    oAtualizarDB:=TAtualizaBancoDados.Create(DtmPrincipal.ConDataBase);
    oAtualizarDB.AtualizarBancoDeDados;
  finally
    if Assigned(oAtualizarDB) then
       FreeAndNil(oAtualizarDB);
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  try
    oUsuarioLogado := TUsuarioLogado.Create;

    frmLogin:=TfrmLogin.Create(Self);
    frmLogin.ShowModal;

  finally
    frmLogin.Release;
    StbPrincipal.Panels[0].Text:='USUÁRIO: '+oUsuarioLogado.nome;
  end;
end;

procedure TfrmPrincipal.imgMysqlClick(Sender: TObject);
begin

end;

procedure TfrmPrincipal.Label1Click(Sender: TObject);
begin
  OpenURL('https://www.udemy.com/desenvolver-sistema-com-delphi-e-sql-server-na-pratica/');
end;

procedure TfrmPrincipal.mmuAcoesDeAcessoClick(Sender: TObject);
begin
  TInstanciarForm.CriarForm(TfrmCadAcaoAcesso, oUsuarioLogado, DtmPrincipal.ConDataBase);
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(oUsuarioLogado) then
     FreeAndNil(oUsuarioLogado);

  if Assigned(DtmPrincipal) then
     FreeAndNil(DtmPrincipal);
end;

procedure TfrmPrincipal.mmuFecharClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmPrincipal.mmuPermissaoDeAcoesParaUsuarioClick(Sender: TObject);
begin
  TInstanciarForm.CriarForm(TfrmUsuarioVsAcoes, oUsuarioLogado, DtmPrincipal.ConDataBase);
end;

procedure TfrmPrincipal.mmuUsuarioClick(Sender: TObject);
begin
  TInstanciarForm.CriarForm(TfrmCadUsuario, oUsuarioLogado, DtmPrincipal.ConDataBase);
end;

end.

