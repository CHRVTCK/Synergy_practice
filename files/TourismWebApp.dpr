library TourismWebApp;

{
  WEB-приложение "Бронирование туров"
  Технология: Delphi WebBroker, ISAPI-расширение для MS IIS
  БД: MS SQL Server (база TourismWeb)

  Развёртывание:
  1. Открыть проект в Delphi 10.2, собрать (Build) — получится
     TourismWebApp.dll
  2. В IIS создать новый сайт/виртуальный каталог, указать физический
     путь к папке с TourismWebApp.dll
  3. В Handler Mappings добавить сопоставление *.dll -> ISAPI, с
     правами Execute для скомпилированного файла
     (или использовать готовое ISAPI-расширение)
  4. Обратиться в браузере: http://<сервер>/TourismWebApp.dll/tours
}

uses
  WebBroker,
  ISAPIApp,
  WebModuleUnit1 in 'WebModuleUnit1.pas' {WebModule1: TWebModule},
  DataModuleUnit1 in 'DataModuleUnit1.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
