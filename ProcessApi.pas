unit ProcessApi;
(*
  Process management.
*)

(***)  interface  (***)

uses
  SysUtils,
  Windows,

  Concur,
  StrLib,
  Utils,
  WinUtils,

  GameExt;


(* Returns 32-character unique key for current game process. The ID will be unique between multiple game runs. *)
function GetCurrentProcessGuid: string;


(***) implementation (***)


var
  (* Global unique process GUID, generated on demand *)
  ProcessGuid: string;

  StaticCritSection: Concur.TCritSection;


function GetCurrentProcessGuid: string;
var
  ProcessGuidBuf: array [0..sizeof(GameExt.ProcessStartTime) - 1] of byte;

begin
  with StaticCritSection do begin
    Enter;

    if ProcessGuid = '' then begin
      FillChar(ProcessGuidBuf, sizeof(ProcessGuidBuf), #0);

      if not WinUtils.RtlGenRandom(@ProcessGuidBuf, sizeof(ProcessGuidBuf)) then begin
        Utils.CopyMem(sizeof(GameExt.ProcessStartTime), @GameExt.ProcessStartTime, @ProcessGuidBuf);
      end;

      ProcessGuid := StrLib.BinToHex(sizeof(ProcessGuidBuf), @ProcessGuidBuf);
    end;

    result := ProcessGuid;

    Leave;
  end;
end;

initialization
  StaticCritSection.Init;
finalization
  StaticCritSection.Delete;
end.
