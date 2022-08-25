#include "script_component.hpp"

params[
  ["_unit", objNull, [objNull]],
  ["_target", objNull, ["", objNull, []]],
  ["_roundClassName", "", [""]]
];

[{
  _this params ["_unit", "_target", "_roundClassName"];

  private	_dis = 1000;
  GVAR(tempAcc) = (_unit getVariable [VAR_SART_ARTSPOTACCURACY,MEANSPOTTINGACCURACY]) + 1;
  private _minSpottedDistance = 100;
  private	_fireRate = _unit call FUNC(ArtGetFireRate);

  while{(_dis >_minSpottedDistance && SPOTTINGROUNDSREQUIRED)} do
  {
      private _randomPos = [[[_target, GVAR(tempAcc)]],[]] call BIS_fnc_randomPos;

      private _targetPos = if (_target isEqualType "" && {markerShape _target isNotEqualTo ""}) then {
          getMarkerPos _target
      } else {
          _target
      };

      _dis = _randomPos distance2D _targetPos;
      private _eta = [_unit,_randomPos, _roundClassName] call FUNC(Dia_GetArtyEta);
      _unit commandArtilleryFire [_randomPos, _roundClassName, 1];

      private _waitTime = (_fireRate * (_unit getVariable [VAR_SART_ARTFIRERATE,MEANFIRERATE])) max _eta;
      [{
        GVAR(tempAcc) = [_dis, GVAR(tempAcc)] call FUNC(GetNewAccuracy);
      }, [_unit, _target, _roundClassName], (_waitTime max ((_unit getVariable [VAR_SART_ARTAIMSPEED,MEANAIMTIME]) + 1))] call CBA_fnc_waitAndExecute;
  };
}, [_unit, _target, _roundClassName], (_unit call FUNC(Dia_GetArtyAimTime))] call CBA_fnc_waitAndExecute;
