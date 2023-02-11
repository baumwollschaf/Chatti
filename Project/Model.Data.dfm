object ModelData: TModelData
  OnCreate = DataModuleCreate
  Height = 327
  Width = 486
  object ChatGpt: TRDChatGpt
    ApiKey = ''
    Temperature = 0.100000000000000000
    Model = 'text-davinci-003'
    URL = 'https://api.openai.com/v1'
    OnAnswer = ChatGptAnswer
    OnModelsLoaded = ChatGptModelsLoaded
    Asynchronous = True
    Left = 224
    Top = 144
  end
end
