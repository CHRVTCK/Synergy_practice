unit WebModuleUnit1;

{
  Веб-модуль: определяет действия (маршруты), доступные по HTTP.

  Маршруты:
    /tours   (GET)  — список туров, подгружаемых из MS SQL Server
    /book    (GET)  — форма бронирования конкретного тура
    /book    (POST) — сохранение заявки на бронирование в БД
    /        (GET)  — главная страница со ссылкой на список туров
}

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, DataModuleUnit1;

type
  TWebModule1 = class(TWebModule)
    procedure WebModuleDefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
    procedure ToursActionAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure BookActionAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
  private
    function PageHeader(const ATitle: string): string;
    function PageFooter: string;
  public
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{$R *.dfm}

function TWebModule1.PageHeader(const ATitle: string): string;
begin
  Result :=
    '<!DOCTYPE html><html lang="ru"><head><meta charset="utf-8">' +
    '<title>' + ATitle + '</title></head><body>' +
    '<h1>Туристический портал — бронирование туров</h1>' +
    '<p><a href="tours">Список туров</a> | <a href="/">Главная</a></p><hr>';
end;

function TWebModule1.PageFooter: string;
begin
  Result := '<hr><p>Демо WEB-приложение: Delphi WebBroker + IIS + MS SQL Server</p>' +
    '</body></html>';
end;

procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  if not Assigned(DataModule1) then
    DataModule1 := TDataModule1.Create(Self);
end;

procedure TWebModule1.WebModuleDefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := PageHeader('Главная') +
    '<p>Добро пожаловать! Выберите пункт меню выше, чтобы посмотреть ' +
    'доступные туры и оформить бронирование.</p>' + PageFooter;
  Handled := True;
end;

procedure TWebModule1.ToursActionAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := PageHeader('Список туров') +
    '<h2>Доступные туры</h2>' + DataModule1.GetToursHTML + PageFooter;
  Handled := True;
end;

procedure TWebModule1.BookActionAction(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
var
  tourId: Integer;
  clientName, clientPhone, clientEmail: string;
  numPeople: Integer;
  html: string;
begin
  if Request.MethodType = mtPost then
  begin
    // Обработка отправленной формы бронирования
    tourId := StrToIntDef(Request.ContentFields.Values['tour_id'], 0);
    clientName := Request.ContentFields.Values['client_name'];
    clientPhone := Request.ContentFields.Values['client_phone'];
    clientEmail := Request.ContentFields.Values['client_email'];
    numPeople := StrToIntDef(Request.ContentFields.Values['num_people'], 1);

    if (tourId > 0) and (clientName <> '') and (clientPhone <> '') and
       DataModule1.InsertBooking(tourId, clientName, clientPhone, clientEmail, numPeople) then
    begin
      html := PageHeader('Бронирование оформлено') +
        '<h2>Спасибо!</h2><p>Ваша заявка на тур принята. ' +
        'Менеджер свяжется с вами по телефону ' + clientPhone + '.</p>';
    end
    else
    begin
      html := PageHeader('Ошибка') +
        '<h2>Не удалось оформить бронирование</h2>' +
        '<p>Проверьте правильность заполнения полей и попробуйте снова.</p>';
    end;

    Response.Content := html + PageFooter;
  end
  else
  begin
    // GET-запрос: показать форму бронирования для выбранного тура
    tourId := StrToIntDef(Request.QueryFields.Values['tour_id'], 0);

    Response.Content := PageHeader('Бронирование тура') +
      '<h2>Оформление заявки</h2>' +
      '<form method="POST" action="book">' +
      '<input type="hidden" name="tour_id" value="' + IntToStr(tourId) + '">' +
      '<p>ФИО: <input type="text" name="client_name" required></p>' +
      '<p>Телефон: <input type="text" name="client_phone" required></p>' +
      '<p>Email: <input type="text" name="client_email"></p>' +
      '<p>Количество человек: <input type="number" name="num_people" value="1" min="1"></p>' +
      '<p><input type="submit" value="Отправить заявку"></p>' +
      '</form>' + PageFooter;
  end;

  Handled := True;
end;

end.
