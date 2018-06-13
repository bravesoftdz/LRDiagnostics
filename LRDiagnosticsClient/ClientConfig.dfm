inherited fmClientConfig: TfmClientConfig
  Caption = 'Client Config'
  ClientHeight = 184
  ClientWidth = 486
  ExplicitWidth = 492
  ExplicitHeight = 213
  PixelsPerInch = 96
  TextHeight = 18
  inherited RzPanel1: TRzPanel
    Width = 486
    Height = 149
    ExplicitWidth = 486
    ExplicitHeight = 149
    object lbURL: TRzLabel
      Left = 8
      Top = 8
      Width = 23
      Height = 18
      Caption = 'URL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
    end
    object lblUserName: TRzLabel
      Left = 152
      Top = 73
      Width = 68
      Height = 18
      Caption = 'User Name'
    end
    object lblPassword: TRzLabel
      Left = 325
      Top = 73
      Width = 59
      Height = 18
      Caption = 'Password'
    end
    object ebURL: TcxTextEdit
      Left = 8
      Top = 32
      TabOrder = 0
      Width = 470
    end
    object ckbRequireAuth: TRzCheckBox
      Left = 8
      Top = 72
      Width = 107
      Height = 20
      Caption = 'Requires Auth'
      HotTrack = True
      State = cbUnchecked
      TabOrder = 1
      OnClick = ckbRequireAuthClick
    end
    object ebUserName: TRzEdit
      Left = 152
      Top = 97
      Width = 153
      Height = 26
      Text = ''
      FrameStyle = fsBump
      FrameVisible = True
      TabOrder = 2
    end
    object ebPassword: TRzEdit
      Left = 325
      Top = 97
      Width = 153
      Height = 26
      Text = ''
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  inherited RzPanel2: TRzPanel
    Top = 149
    Width = 486
    ExplicitTop = 149
    ExplicitWidth = 486
    inherited pnOKCancel: TRzPanel
      Left = 325
      ExplicitLeft = 325
    end
  end
end
