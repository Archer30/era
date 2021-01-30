unit Main;

interface

uses
  Windows, Classes, SysUtils, Dialogs, H32GameFunction;

procedure BeginWork1; stdcall;

const
  //���Ļ�ʹ��ȫ�ֱ���
  CutTemp1: integer = $004B5A3A;
  CutTemp2: integer = $004B5A5B;
  WordWarp1: integer = $004B57B4;
  WordWarp2: integer = $004B57CD;

var
  F12, F24, F10: TMemoryStream;
  DialogResult: integer;

implementation

//�Ѻ�����Ҫ�õ���2�ֵ����ֿ�װ���ڴ�,��2������ֱ���12*12��hzk12��24*24��hzk24
procedure InitFont;
var
  path: array[0..255] of char;

begin
  F10 := TMemoryStream.Create;
  F12 := TMemoryStream.Create;
  F24 := TMemoryStream.Create;
  
  GetModuleFileName(HInstance, path, Length(path));
  
  if not fileexists(extractfilepath(strpas(path)) + 'hzk12') then begin
    ShowMessage('û���ҵ������ļ�hzk12');
    exit;
  end;
  
  if not fileexists(extractfilepath(strpas(path)) + 'HZK24') then begin
    ShowMessage('û���ҵ������ļ�HZK24H');
    exit;
  end;
  
  F12.LoadFromFile(extractfilepath(strpas(path)) + 'hzk12');
  F24.LoadFromFile(extractfilepath(strpas(path)) + 'HZK24');
  F10.LoadFromFile(extractfilepath(strpas(path)) + 'HZK10');
end;

function GetH3Version: integer;
var
  Buf: array[0..7] of byte;
  BytesRead: dword;

begin
  result := 0;
  ReadProcessMemory(GetCurrentProcess, pointer($004f8701), @Buf, 8, BytesRead);

  if (Buf[0] = $2d) and (Buf[1] = $49) and (Buf[2] = $9c) and (Buf[3] = $00) and (Buf[4] = $00) and
    (Buf[5] = $74) and (Buf[6] = $7c) and (Buf[7] = $83) then
    result := 32;
end;
//ʹ���з���ֱ��д��ַ���ȶ�����WOG�汾���Գɹ�������32���л����ԭ����
procedure BeginWork; stdcall;
begin
  case GetH3Version of
    32:
    begin
      InitFont;
      //HOOK $004b5a32,�ض��ַ�������
      pByte($004b5a32)^      := $e9;
      pInteger($00004b5a33)^ := integer(@MyCutWidth) - $004b5a37;
      pByte($004b5a37)^      := $90;
      pByte($004b5a38)^      := $90;
      pByte($004b5a39)^      := $90;
      //����Ӣ�����-��
      pByte($004b5202)^ := $e9;
      pInteger($00004b5203)^ := integer(@MyTextOut_New) - $004b5207;
      pByte($004b5207)^ := $90;
      //����������һ������һ��ʹ��
      pByte($004f6569)^ := $b8;
      pByte($004f656a)^ := $80;
      pByte($004f656b)^ := $01;
      pByte($004f656c)^ := $00;
      pByte($004f656d)^ := $00;
      pByte($004f656e)^ := $90;
      pByte($004f656f)^ := $90;
      pByte($004f6570)^ := $90;
      //����һ������һ�𣬽�����Ļ���ð�ս�����һЩ�Ҽ���ʾ�Ի��򳤶�̫�����⣬
      //�����Ҽ�����ز��л���ť
      pByte($004f6599)^ := $b8;
      pByte($004f659a)^ := $80;
      pByte($004f659b)^ := $01;
      pByte($004f659c)^ := $00;
      pByte($004f659d)^ := $00;
      pByte($004f659e)^ := $90;
      pByte($004f659f)^ := $90;
      pByte($004f65a0)^ := $90;
      //WordWrap
      pByte($004b57ab)^ := $e9;
      pInteger($004b57ac)^ := integer(@MyWordWarp) - $004b57b0;
      pByte($004b57b0)^ := $90;
      pByte($004b57b1)^ := $90;
      pByte($004b57b2)^ := $90;
      pByte($004b57b3)^ := $90;
      //����һ�����ֵ�������
      pByte($004b5580)^ := $e9;
      pInteger($004b5581)^ := integer(@MyDialog) - $004b5585;
      pByte($004b5585)^ := $90;
    end;
  end;
end;

procedure BeginWork1; stdcall;
const
  Data: byte = $e9;
  Data1: byte = $90;
  Data4: array[0..4] of byte = ($b8, $80, $01, 0, 0);
var
  BytesRead: dword;
  pMyCutWidth, pMyTextOut, pMyWordWarp, pMyDialog: integer;
begin
  case GetH3Version of
    32:
    begin
      InitFont;
      //HOOK $004b5a32,�ض��ַ�������
      pMyCutWidth := integer(@MyCutWidth);
      pMyCutWidth := pMyCutWidth - $004b5a37;
      WriteProcessMemory(GetCurrentProcess, pointer($004b5a32), @Data, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5a33), @pMyCutWidth, 4, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5a37), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5a38), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5a39), @data1, 1, BytesRead);
      //����Ӣ�����-��
      pMyTextOut := integer(@MyTextOut_New);
      pMyTextOut := pMyTextOut - $004b5207;
      WriteProcessMemory(GetCurrentProcess, pointer($004b5202), @Data, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5203), @pMyTextOut, 4, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5207), @data1, 1, BytesRead);
      //����һ������һ��ʹ��
      // Patch GetMaxWordWidth
      WriteProcessMemory(GetCurrentProcess, pointer($004f6569), @data4, 5, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004f656e), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004f656f), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004f6570), @data1, 1, BytesRead);
      //�������ǽ�����Ļ���ð�ս�����һЩ�Ҽ���ʾ�Ի��򳤶�̫�����⣬�����Ҽ�����ز��л���ť
      // Patch GetMaxLineWidth to be 352px
      WriteProcessMemory(GetCurrentProcess, pointer($004f6599), @data4, 5, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004f659e), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004f659f), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004f65a0), @data1, 1, BytesRead);
      //DIALOG(WordWrap)
      pMyWordWarp := integer(@MyWordWarp);
      pMyWordWarp := pMyWordWarp - $004b57b0;
      WriteProcessMemory(GetCurrentProcess, pointer($004b57ab), @Data, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b57ac), @pMyWordWarp, 4, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b57b0), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b57b1), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b57b2), @data1, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b57b3), @data1, 1, BytesRead);
      //DIALOG(���ضԻ��������)
      pMyDialog := integer(@MyDialog);
      pMyDialog := pMyDialog - $004b5585;
      WriteProcessMemory(GetCurrentProcess, pointer($004b5580), @Data, 1, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5581), @pMyDialog, 4, BytesRead);
      WriteProcessMemory(GetCurrentProcess, pointer($004b5585), @data1, 1, BytesRead);
    end;
  end;
end;

end.