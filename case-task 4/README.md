# WEB-приложение «Бронирование туров» — версия под MySQL

Отличия от версии на MS SQL Server (папка `../delphi_webbroker/`):

- База данных: `tourism_web_mysql.sql` (СУБД MySQL 8.x) вместо
  `tourism_web_mssql.sql`.
- Названия таблиц/полей в нижнем регистре со snake_case
  (`tours`, `tour_name`, `vw_tour_list` и т.д.) — как принято в MySQL.
- `DataModuleUnit1.pas` подключается через ADO + **MySQL Connector/ODBC
  8.0** (провайдер `MSDASQL`, драйвер `MySQL ODBC 8.0 Unicode Driver`)
  вместо `MSOLEDBSQL`.

## Установка

1. Установите **MySQL Connector/ODBC 8.0** той же разрядности
   (32/64 бит), что и сборка Delphi/пул приложений IIS.
2. Выполните `../tourism_web_mysql.sql` в MySQL Workbench —
   создастся база `tourism_web`.
3. В `DataModuleUnit1.pas` замените `SERVER_NAME`, `USER`, `PASSWORD`
   на реальные параметры подключения к вашему MySQL-серверу.
4. Дальнейшие шаги сборки в Delphi 10.2 и развёртывания на IIS —
   такие же, как описано в `../delphi_webbroker/README.md`.

## Альтернатива без ODBC

Если не хочется настраивать ODBC-драйвер, замените компоненты
`TADOConnection`/`TADOQuery` на `TFDConnection`/`TFDQuery` (FireDAC)
с драйвером MySQL, встроенным в Delphi 10.2 — тогда ODBC не
потребуется вовсе, а строка подключения задаётся через
`TFDConnection.Params` (DriverID=MySQL, Server, Database, User_Name,
Password).
