#include "script_component.hpp"

/* LOG_1("CAPZONE_MARKERCOLLECTION = %1", GVAR(CAPZONE_MARKERCOLLECTION)); */

private _return = "NONE";

GVAR(CAPZONE_MARKERCOLLECTION) apply {
  if((_this == _x select 1) && {_x select 2}) then {
    _return = _x select 0;

    if(_return == "GUER") then {
      _return = "RESISTANCE";
    };
  };
};

_return
