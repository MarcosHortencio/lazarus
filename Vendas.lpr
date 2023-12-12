program Vendas;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uPrincipal, lazcontrols, zcomponent, uConexao, utelaheranca,
  cArquivoIni, uAtualizaDB, cAtualizacaoBancoDeDados, cAtualizacaoTabelaMYSQL,
  uenum, cusuariologado, ufuncaoCriptografia, uutils, catualizacaocampomysql,
  ccadusuario, ucadusuario, uLogin, cacaoacesso, uCadAcaoAcesso,
  cInstanciarForm, uUsuarioVsAcoes, cbase, Unit1, Unit2;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

