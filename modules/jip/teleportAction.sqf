#include "script_component.hpp"

/* diag_log format ["INFO: In teleport action! this = %1", _this]; */

params ["", "", "_id", ["_target", leader player, [objnull]]];

if !((_target call EFUNC(FW,isAlive)) && {(!(INVEHICLE(_target)) || {((vehicle _target) call EFUNC(FW,getEmptyPositions)) isEqualTo []})}) then {

	private _rank = -1;
	private _count = 0;

    (units group player) select {
        _x call EFUNC(FW,isAlive) &&
		{_x isNotEqualTo player}
    } apply {
        _count = _count + 1;
        if ((rankId _x > _rank) && {!(INVEHICLE(_x)) || {((vehicle _x) call EFUNC(FW,getEmptyPositions) isEqualTo [])}}) then {
            _rank = rankId _x;
            _target = _x;
        };
    };

	if (_rank isEqualTo -1) then {
		_target = objNull;
		if (_count isEqualTo 0) then {
			player removeAction _id;
			cutText ["No one left in the squad", 'PLAIN DOWN'];
		} else {
			cutText ["Not possible to JIP teleport to anyone, please try again later", 'PLAIN DOWN'];
		};
	};
};

/* diag_log format ["INFO _target = %1", _target];
diag_log format ["INFO in vehicle? = %1", (INVEHICLE(_target))];
diag_log format ["INFO player = %1", player]; */

if !(_target isEqualTo objnull) then {
	if (INVEHICLE(_target)) then {
		player moveInAny (vehicle _target);
	} else {
		player setPosATL (getPosATL _target);
	};
	player removeAction _id;
} else {
	cutText ["Something went wrong, target doesn't exist.", 'PLAIN DOWN'];
};
