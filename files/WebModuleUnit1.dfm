object WebModule1: TWebModule1
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModuleDefaultHandlerAction
    end
    item
      MethodType = mtGet
      Name = 'ToursAction'
      PathInfo = '/tours'
      OnAction = ToursActionAction
    end
    item
      Name = 'BookAction'
      PathInfo = '/book'
      OnAction = BookActionAction
    end>
  Height = 230
  Width = 415
end
