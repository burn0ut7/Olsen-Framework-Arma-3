/*
 * Author: StatusRed
 *
 * Provided with a side, this function will determine who the Command Officer should be
 *
 * Arguments:
 * 0: side <side>
 *
 * Return Value:
 * Commanding Officer <unit>
 *
 * Public: Yes
 */

#include "script_component.hpp"

params [
  ["_side", blufor, [blufor]]
];

private _units = playableUnits select {
  ((side _x) isEqualTo _side) &&
  {_x call FUNC(isAlive)}
};

if (_units isEqualTo []) exitWith {
  objNull
};

private _manualOverride = switch (_side) do {
  case blufor: {GVAR(CoC_ManualOverride_Blufor)};
  case opfor: {GVAR(CoC_ManualOverride_Opfor)};
  case independent: {GVAR(CoC_ManualOverride_Indfor)};
  case civilian: {GVAR(CoC_ManualOverride_Civfor)};
};

private _coVar = switch (_side) do {
  case blufor: {QGVAR(CO_Blufor)};
  case opfor: {QGVAR(CO_Opfor)};
  case independent: {QGVAR(CO_Indfor)};
  case civilian: {QGVAR(CO_Civfor)};
};

private _oldCO = missionNamespace getVariable [_coVar, objNull];

private _co = objNull;

private _filteredManualOverride = _manualOverride select {
  !(isNull _x) &&
  {_x call FUNC(isAlive)}
};

if (_filteredManualOverride isEqualTo []) then { // Default behaviour
  private _rankValues = createHashMapFromArray [
    ["PRIVATE", 1], ["CORPORAL", 2], ["SERGEANT", 3],
    ["LIEUTENANT", 4], ["CAPTAIN", 5], ["MAJOR", 6],
    ["COLONEL", 7]
  ];

  private _highestRankSeen = 0;

  _units apply {
    private _rank = _rankValues get (rank _x);

    if (_rank > _highestRankSeen) then {
      _co = _x;
      _highestRankSeen = _rank;
    };
  };

} else { // Override behaviour
  _filteredManualOverride apply {
    if (_x in _units) then {
      _co = _x;
      break;
    } else {
      continue;
    };
  };
};

if (_oldCO isNotEqualTo _co) then { // If the CO has changed
  TRACE_3("Triggering %1 event to %2 old CO = %3!", QGVAR(CoC_Changed), _co, _oldCO);
  missionNamespace setVariable [_coVar, _co, true];
  if (GETMVAR(CoC_Changed_Message,true)) then {
      [QGVAR(CoC_Changed), [_oldCo], _co] call CBA_fnc_targetEvent;
  };
};

_co
