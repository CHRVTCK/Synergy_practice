unit DataModuleUnit1;

{
  Модуль данных: подключение к MySQL через ADO + MySQL ODBC Driver.

  Требования:
    - Установлен MySQL Connector/ODBC 8.0 (64-bit или 32-bit —
      в соответствии с разрядностью сборки Delphi/IIS).
    - Строка подключения ниже использует драйвер ODBC напрямую
      через провайдера MSDASQL (стандартно доступен в Windows).

  Альтернатива (рекомендуется для production): использовать
  FireDAC с компонентом TFDConnection и драйвером MySQL —
  он не требует настройки ODBC DSN и работает быстрее.
  Ниже показан вариант на ADO для простоты и переносимости примера.
}

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TDataModule1 = class(TDataModule)
    ADOConnection1: TADOConnection;
    ADOQueryTours: TADOQuery;
    ADOQueryBookingInsert: TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function GetToursHTML: string;
    function InsertBooking(const ATourId: Integer;
      const AClientName, AClientPhone, AClientEmail: string;
      const ANumPeople: Integer): Boolean;
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.dfm}

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  // Подключение к MySQL через ODBC-драйвер (MySQL Connector/ODBC 8.0)
  // Замените SERVER_NAME, USER, PASSWORD на реальные значения.
  ADOConnection1.ConnectionString :=
    'Provider=MSDASQL;' +
    'Driver={MySQL ODBC 8.0 Unicode Driver};' +
    'Server=SERVER_NAME;' +
    'Database=tourism_web;' +
    'User=USER;' +
    'Password=PASSWORD;' +
    'Option=3;';
  ADOConnection1.LoginPrompt := False;
  ADOConnection1.Connected := True;
end;

function TDataModule1.GetToursHTML: string;
var
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    ADOQueryTours.Close;
    ADOQueryTours.SQL.Text := 'SELECT tour_id, tour_name, country_name, ' +
      'duration_days, price_per_person, description FROM vw_tour_list ' +
      'ORDER BY tour_name';
    ADOQueryTours.Open;

    sb.Append('<table border="1" cellpadding="6" cellspacing="0">');
    sb.Append('<tr><th>Тур</th><th>Страна</th><th>Дней</th>' +
      '<th>Цена, у.е./чел.</th><th>Описание</th><th>Бронирование</th></tr>');

    while not ADOQueryTours.Eof do
    begin
      sb.Append('<tr>');
      sb.Append('<td>' + ADOQueryTours.FieldByName('tour_name').AsString + '</td>');
      sb.Append('<td>' + ADOQueryTours.FieldByName('country_name').AsString + '</td>');
      sb.Append('<td>' + ADOQueryTours.FieldByName('duration_days').AsString + '</td>');
      sb.Append('<td>' + ADOQueryTours.FieldByName('price_per_person').AsString + '</td>');
      sb.Append('<td>' + ADOQueryTours.FieldByName('description').AsString + '</td>');
      sb.Append('<td><a href="book?tour_id=' +
        ADOQueryTours.FieldByName('tour_id').AsString +
        '">Забронировать</a></td>');
      sb.Append('</tr>');
      ADOQueryTours.Next;
    end;

    sb.Append('</table>');
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TDataModule1.InsertBooking(const ATourId: Integer;
  const AClientName, AClientPhone, AClientEmail: string;
  const ANumPeople: Integer): Boolean;
begin
  Result := False;
  try
    ADOQueryBookingInsert.Close;
    ADOQueryBookingInsert.SQL.Text :=
      'INSERT INTO bookings (tour_id, client_name, client_phone, client_email, num_people) ' +
      'VALUES (:TourId, :ClientName, :ClientPhone, :ClientEmail, :NumPeople)';
    ADOQueryBookingInsert.Parameters.ParamByName('TourId').Value := ATourId;
    ADOQueryBookingInsert.Parameters.ParamByName('ClientName').Value := AClientName;
    ADOQueryBookingInsert.Parameters.ParamByName('ClientPhone').Value := AClientPhone;
    ADOQueryBookingInsert.Parameters.ParamByName('ClientEmail').Value := AClientEmail;
    ADOQueryBookingInsert.Parameters.ParamByName('NumPeople').Value := ANumPeople;
    ADOQueryBookingInsert.ExecSQL;
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

end.
