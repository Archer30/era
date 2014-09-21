unit TextOut;

(* ERA notes
 * Chinese character code > 160
 * If next character code <= 160, it becomes 161
 * Example [170][32] => [170][161]
 *)

interface
uses
  Dialogs,Windows,SysUtils,math;
  procedure DoMyTextOut_New(str:pAnsiChar;Surface,x,y,Width,Height,ColorA,Mode,hfont,unknow:integer);stdcall;
  procedure DoMyDialog(hfont,MaxWidth:integer;s:pAnsiChar);stdcall;
implementation
uses
  H32GameFunction,Main;
const
  Font24Width:integer=28;
  Font24Height:integer=25;
  //�����ͨ��΢���߶���������ϷЧ��
  Font12Width:integer=14;
  Font12Height:integer=16;
  FontTinyWidth:integer=11;
  FontTinyHeight:integer=11;
//����һ�����ֵ���λ��
procedure GetQWCode(HZ:pAnsiChar;var Q,W:word);stdcall;
begin
  Q := byte(HZ[0]) - 160;

  if byte(HZ[1]) > 160 then begin
    W := byte(HZ[1]) - 160;
  end // .if
  else begin
    W := 1;
  end; // .else
end;
procedure MakeChar12(StartY,StartX,Surface:integer;HZ:pAnsiChar;Color:word);stdcall;
var
  OffSet:integer;
  GetStr:array [0..23] of byte;
  temp,dis:byte;
  x,y,i,j,xy:integer;
  Q,W:word;
  ScreenWidth:integer;
begin
  ScreenWidth:=pInteger(Surface+$2c)^;
  GetQWCode(HZ,Q,W);
  OffSet:=(94*(Q-1)+(W-1))*24;
  F12.Position:=OffSet;
  F12.Read(GetStr,sizeof(GetStr));
  x:=0;
  y:=0;
  i:=0;
  while(i<=23) do
  begin
    temp:=GetStr[i];
    for j:=0 to 7 do begin
      dis:=temp and 128;
      dis:=dis shr 7;
      if dis=1 then
      begin
        xy:=(StartY+x)*ScreenWidth+(y+StartX)*2;
        pWord(pInteger(Surface+$30)^+xy)^:=Color;
      end;
      Inc(x);
      if x>15 then
      begin
        x:=0;
        Inc(y);
      end;
      temp:=temp shl 1;
    end;
    Inc(i);
  end;
end;
procedure MakeChar10(StartY,StartX,Surface:integer;HZ:pAnsiChar;Color:word);stdcall;
var
  OffSet:integer;
  GetStr:array[0..19] of byte;
  temp,dis:byte;
  x,y,i,j,xy:integer;
  Q,W:word;
  ScreenWidth:integer;
begin
  ScreenWidth:=pInteger(Surface+$2c)^;
  GetQWCode(HZ,Q,W);
  OffSet:=(94*(Q-1)+(W-1))*20;
  F10.Position:=OffSet;
  F10.Read(GetStr,sizeof(GetStr));
  x:=0;
  y:=0;
  i:=0;
  while(i<=19) do
  begin
    temp:=getstr[i];
    for j:=0 to 7 do
    begin
      dis:=temp and 128;
      dis:=dis shr 7;
      if dis=1 then
      begin
        xy:=(StartY+y)*ScreenWidth+(x+StartX)*2;
        pWord(pInteger(surface+$30)^+xy)^:=Color;
      end;
      Inc(x);
      if x>15 then
      begin
        x:=0;
        Inc(y);
      end;
      temp:=temp shl 1;
    end;
    Inc(i);
  end;
end;
procedure MakeChar24(StartY,StartX,Surface:integer;HZ:pAnsiChar;Color:word);stdcall;
var
  OffSet:integer;
  GetStr:array[0..71] of byte;
  temp,dis:byte;
  x,y,i,j,xy:integer;
  Q,W:word;
  ScreenWidth:integer;
begin
  ScreenWidth:=pInteger(Surface+$2c)^;
  GetQWCode(HZ,Q,W);
  OffSet:=(94*(Q-1)+(W-1))*72;
  F24.Position:=OffSet;
  F24.Read(GetStr,sizeof(GetStr));
  x:=0;
  y:=0;
  i:=0;
  while(i<=71) do
  begin
    temp:=getstr[i];
    for j:=0 to 7 do
    begin
      dis:=temp and 128;
      dis:=dis shr 7;
      if dis=1 then
      begin
        xy:=(StartY+y)*ScreenWidth+(x+StartX)*2;
        pWord(pInteger(surface+$30)^+xy)^:=Color;
      end;
      Inc(x);
      if x>23 then
      begin
        x:=0;
        Inc(y);
      end;
      temp:=temp shl 1;
    end;
    Inc(i);
  end;
end;

function GetEngCharWidth(Assic:byte;hfont:dword):integer;stdcall;
var
  temp:integer;
begin
  temp:=assic*$c+$3c+hfont;
  result:=pInteger(temp)^+pInteger(temp+4)^+pInteger(temp+8)^;
end;
function GetColor(ColorA:integer):word;stdcall;
begin
  if ColorA<256 then result:=ColorA+9
  else result:=ColorA-256;
end;
procedure SetFont(hfont:integer;var Width,Height:integer);stdcall;
begin
  if pInteger(hfont+4)^=1718053218 then
  begin
    Width:=Font24Width;
    Height:=Font24Height;
  end else
  if pInteger(hfont+4)^=2037279092 then
  begin
    Width:=FontTinyWidth;
    Height:=FontTinyHeight;
  end else
  begin
    Width:=Font12Width;
    Height:=Font12Height;
  end;
end;
//�õ�����һ��Ҫռ����
function GetStrRowCount(str:pAnsiChar;hfont,RowWidth:integer):integer;stdcall;
var
  i,Length,Row,FontWidth,FontHeight:integer;
begin
  if str[0]=#0 then
  begin
    result:=0;
    exit;
  end;
  SetFont(hfont,FontWidth,FontHeight);
  i:=0;
  Length:=0;
  Row:=1;
  while (str[i]<>#0) do
  begin
    if (str[i]='{') or (str[i]='}') then
    begin
      i:=i+1;
    end else
    if (byte(str[i])=$0a) then
    begin
      i:=i+1;
      Length:=0;
      if str[i]<>#0 then row:=row+1;
    end else
    if (byte(str[i]) > 160){and (Byte(str[i+1])>160)} then
    begin
      Length:=Length+FontWidth;
      i:=i+2;
      if Length>RowWidth then
      begin
        Length:=0;
        if str[i]<>#0 then row:=row+1;
      end;
    end else
    begin
      Length:=Length+GetEngCharWidth(byte(str[i]),hfont);
      i:=i+1;
      if Length>RowWidth then
      begin
        Length:=0;
        if str[i]<>#0 then row:=row+1;
      end;
    end;
  end;
  result:=Row;
end;
procedure DoMyDialog(hfont,MaxWidth:integer;s:pAnsiChar);stdcall;
begin
  DialogResult:=GetStrRowCount(s,hfont,MaxWidth);
end;
//���һ������,����CharLengthΪ�ַ�����
procedure MyTextOut(str:pAnsiChar;CharLength,ColorA,hfont,y,x:integer;Surface:integer); stdcall;
const 
  kDefaultColor = -1;

var
  FontWidth, FontHeight, i, cy, cx: integer;
  ColorB, ColorSel: word;
  Color: integer;

begin
  SetFont(hfont, FontWidth, FontHeight);
  i := 0;
  cy := y;
  cx := x;
  ColorB := GetColor(ColorA);
  ColorSel := 0;
  
  while (i < CharLength) and not (Str[i] in [#0, #10]) do begin
    if Str[i] > ' ' then begin
      ChineseGotoNextChar;
    end; // .if
  
    if Str[i] = '{' then begin
      ColorSel := 1;
    end // .if
    else if Str[i] = '}' then begin
      ColorSel := 0;
    end // .elseif
    else begin
      if (byte(str[i]) > 160) then begin
        Color := ChineseGetCharColor;
      
        if Color = kDefaultColor then begin
          Color := pWord(hfont+(colorB+colorSel)*2+$1058)^;
        end; // .if
      
        if FontWidth=Font12Width then MakeChar12(cy,cx,Surface,@str[i],Color);
        if FontWidth=FontTinyWidth then MakeChar10(cy,cx,Surface,@str[i],Color);
        if FontWidth=Font24Width then MakeChar24(cy,cx,Surface,@str[i],Color);
        cx:=cx+FontWidth;
        Inc(i);
      end
      else begin
        EngTextOut(hfont,byte(str[i]),Surface,cx,cy, ColorB + ColorSel);
        cx:=cx+GetEngCharWidth(byte(str[i]),hfont);
      end;
    end; // .else
    
    Inc(i);
  end; // .while
end;
procedure DoMyTextOut_New(str:pAnsiChar;Surface,x,y,Width,Height,ColorA,Mode,hfont,unknow:integer);stdcall;
var
  MaxRow,FontWidth,FontHeight,posStart,posEnd,l,i,row,startX,startY,space,spacerow,j:integer;
begin
  //�ȼ���һ���ܹ�Ҫ�õ�����
  MaxRow:=GetStrRowCount(str,hfont,Width);
  SetFont(hfont,FontWidth,FontHeight);
  //PosStart:=0;
  PosEnd:=0;
  Row:=-1;
  SpaceRow:=-1;
  Space:=-1;
  while Str[PosEnd]<>#0 do
  begin
    Row:=Row+1;
    PosStart:=PosEnd;
    i:=posEnd;
    l:=0;
    while str[i]<>#0 do
    begin
      if byte(str[i])=$0a then
      begin
        i:=i+1;
        break;
      end else
      if (str[i]='{') or (str[i]='}') then
      begin
        i:=i+1;
      end else
      if byte(str[i]) > 160 then
      begin
        Space:=i+2;
        SpaceRow:=Row;
        l:=l+FontWidth;
        i:=i+2;
        //����Ӧ���Ǵ���
        if l>width then
        begin
          //Ŀǰû�жԱ����Ž��д���
          //if byte(str[i])>160 True then
          begin
            i:=i-2;
            l:=l-FontWidth;
            break;
          end;
        end;
      end else
      begin
        if byte(str[i])=$20 then
        begin
          Space:=i+1;
          SpaceRow:=Row;
        end;
        l:=l+GetEngCharWidth(byte(str[i]),hfont);
        i:=i+1;
        if l>width then
        begin
          //Ӣ�ı����Ե���Ϊ��λ���������ʻ��У���SPACE��¼�ϸ��ո����λ�ã���SPACEROW��¼�ϸ��ո�������
          if (SpaceRow=Row)and (Space>-1) then
          begin
            for j:=Space to i-1 do
              l:=l-GetEngCharWidth(byte(str[j]),hfont);
            i:=Space;
            break;
          end else
          begin
            l:=l-GetEngCharWidth(byte(str[i]),hfont);
            i:=i-1;
            break;
          end;
        end;
      end;
    end;
    posEnd:=i;
    startX:=x;
    startY:=y+FontHeight*Row;
    case mode of
      0,4,8 :startX:=x;
      1,5,9 :startX:=x+((Width-l) div 2);
      2,6,10:startX:=x+Width-l;
    end;
    case mode of
      0,1,2,3:startY:=y+(FontHeight)*Row;
      4,5,6,7:begin
                  if height<MaxRow*(FontHeight) then
                  begin
                    if height<(FontHeight+FontHeight) then
                      StartY:=y+(FontHeight*Row)+(height-FontHeight)div 2
                    else startY:=y+(FontHeight)*Row;
                  end                else startY:=y+(FontHeight)*Row+(height-MaxRow*(FontHeight))div 2;
              end;
      8,9,10,11:begin
                  if height<MaxRow*(FontHeight) then
                  begin
                    if height<(FontHeight+FontHeight) then
                      StartY:=y+(FontHeight*Row)+(height-FontHeight)
                    else startY:=y+(FontHeight)*Row;
                  end
                  else startY:=y+(FontHeight)*Row+height-MaxRow*(FontHeight);
                end;
    end;
    //���������ʾ��Χ�����˳�
    //if StartX+l>x+Width then exit;
    if (StartY+FontHeight>y+Height)and (Row>0) then exit;
    if PosEnd-PosStart>0 then
      MyTextOut(@str[PosStart],PosEnd-PosStart,ColorA,hfont,StartY,StartX,Surface);
  end;
end;
end.
