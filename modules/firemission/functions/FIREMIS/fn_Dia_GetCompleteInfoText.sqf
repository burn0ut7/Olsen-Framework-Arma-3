#include "script_component.hpp"

private _unit = _this;
private _rounds = _unit call FUNC(Dia_GetArtyFiremissionRoundsRequired);
/* private _callerName = _unit call FUNC(Dia_GetArtyCallerText); */
private _fireMissionText =_unit getVariable [VAR_SART_ARTFMTEXT,"Error"];
private _ret = _fireMissionText +"Rounds fired: " + (str (_rounds select 0)) + "/" + (str (_rounds select 1)) + "\nRequested by: " + (_unit call FUNC(Dia_GetArtyCallerText));
_ret;
