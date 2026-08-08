object DataModule1: TDataModule1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 240
  Width = 320
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Left = 40
    Top = 40
  end
  object ADOQueryTours: TADOQuery
    Connection = ADOConnection1
    Left = 40
    Top = 104
  end
  object ADOQueryBookingInsert: TADOQuery
    Connection = ADOConnection1
    Left = 40
    Top = 168
  end
end
