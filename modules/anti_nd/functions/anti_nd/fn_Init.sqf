#include "script_component.hpp"

[{(!isNull ACE_player)}, {
    // stop grenade throw
    [
        [false, false, false],
        [true, false, false],
        [true, true, false],
        [true, true, true],
        [false, true, false],
        [false, true, true],
        [false, false, true],
        [true, false, true]
    ] apply {
        private _modifiersKey = _x;
        [ActionKeys "throw" select 0, _modifiersKey, {
            true
        }] call CBA_fnc_addKeyHandler;
    };
    private _firedEH = ACE_player addEventHandler ["FiredMan", {
        params ["_unit", "", "", "", "", "_magazine", "_projectile", ""];
        private _cantFire = _unit getVariable [QGVAR(Active), false];
        if (_cantFire) exitWith {
            deleteVehicle _projectile;
            if (_magazine call BIS_fnc_isThrowable) then {
                player addMagazine _magazine;
            } else {
                private _curWeapon = currentWeapon player;
                player setAmmo [_curWeapon, (player ammo _curWeapon) + 1];
            };
            private _weapon = currentWeapon ACE_player;
            private _picture = getText (configFile >> "CfgWeapons" >> _weapon >> "picture");
            ["Anti ND Active", _picture] call ace_common_fnc_displayTextPicture;
            true
        };
        false
    }];
    private _actionVehEH = [vehicle ACE_player, "DefaultAction", {true}, {
        private _cantFire = (_this select 1) getVariable [QGVAR(Active), false];
        if (_cantFire) exitWith {
            private _safedWeapons = vehicle ACE_player getVariable ["ace_safemode_safedWeapons", [""]];
            private _weapon = currentWeapon vehicle ACE_player;
            if !(_weapon in _safedWeapons) then {
                [vehicle ACE_player, _weapon, currentMuzzle vehicle ACE_player] call ace_safemode_fnc_lockSafety;
            };
            private _picture = getText (configFile >> "CfgWeapons" >> _weapon >> "picture");
            ["Anti ND Active", _picture] call ace_common_fnc_displayTextPicture;
            true
        };
        false
    }] call ace_common_fnc_addActionEventHandler;
    (vehicle ACE_player) setVariable [QGVAR(actionVehEH), _actionVehEH];
    private _vehPlayerEH = ["vehicle", {
        params ["_unit", "_newVehicle", "_oldVehicle"];
        if (_newVehicle getVariable [QGVAR(actionVehEH), -1] isEqualTo -1) then {
            private _actionVehEH = [vehicle ACE_player, "DefaultAction", {true}, {
                private _cantFire = (_this select 1) getVariable [QGVAR(Active), false];
                if (_cantFire) exitWith {
                    private _safedWeapons = vehicle ACE_player getVariable ["ace_safemode_safedWeapons", [""]];
                    private _weapon = currentWeapon vehicle ACE_player;
                    if !(_weapon in _safedWeapons) then {
                        [vehicle ACE_player, _weapon, currentMuzzle vehicle ACE_player] call ace_safemode_fnc_lockSafety;
                    };
                    private _picture = getText (configFile >> "CfgWeapons" >> _weapon >> "picture");
                    ["Anti ND Active", _picture] call ace_common_fnc_displayTextPicture;
                    true
                };
                false
            }] call ace_common_fnc_addActionEventHandler;
            _newVehicle setVariable [QGVAR(actionVehEH), _actionVehEH];
        };
    }, true] call CBA_fnc_addPlayerEventHandler;
    // Turrent event handler currently causing an issue with reloading removing mags from the vehicle
    /* private _turretEH = ["turretWeapon", {
        params ["_unit", "_newWeapon", "_oldWeapon"];
        private _safedWeapons = _unit getVariable ["ace_safemode_safedWeapons", []];
        private _turret = vehicle ACE_player unitTurret ACE_player;
        private _magazine = vehicle ACE_player currentMagazineTurret _turret;
        vehicle ACE_player setAmmo [_newWeapon, 0];
        if !(GETVAR(vehicle ACE_player,magAdded,false)) then {
            vehicle ACE_player addMagazineTurret [_magazine, _turret, 1000];
            vehicle ACE_player setVariable [QGVAR(magAdded), true, true];
        };
        if !(_newWeapon in _safedWeapons) then {
            [vehicle ACE_player, _newWeapon, currentMuzzle vehicle ACE_player] call ace_safemode_fnc_lockSafety;
        };
    }, true] call CBA_fnc_addPlayerEventHandler; */
    ACE_player setVariable ["ace_common_effect_blockThrow", 1];
    ACE_player setvariable ["ace_explosives_PlantingExplosive", true];
    SETPLVAR(EHid, _firedEH);
    SETPLVAR(Active, true);
    GVAR(Time) = switch (side ACE_player) do {
        case blufor: {GVAR(BLUFOR_Time)};
        case opfor: {GVAR(OPFOR_Time)};
        case independent: {GVAR(INDFOR_Time)};
        case civilian: {GVAR(CIV_Time)};
        default {GVAR(BLUFOR_Time)};
    };
    GVAR(Distance) = switch (side ACE_player) do {
        case blufor: {GVAR(BLUFOR_Distance)};
        case opfor: {GVAR(OPFOR_Distance)};
        case independent: {GVAR(INDFOR_Distance)};
        case civilian: {GVAR(CIV_Distance)};
        default {GVAR(BLUFOR_Distance)};
    };
    [{
        ((GETMVAR(Time,30)) <= 0 || {CBA_missionTime >= GETMVAR(Time,30)})
        || {(GETMVAR(Distance,200)) <= 0 || {((EGETMVAR(FW,SpawnPos,getpos (vehicle ACE_player))) distance (vehicle ACE_player)) >= GETMVAR(Distance,200)}}
    },{
        LOG_1("Removing anti_nd event handlers for player = %1",ACE_player);
        params ["_firedEH", "_vehPlayerEH", "_actionVehEH"];
        player removeEventHandler ["FiredMan", _firedEH];
        [ACE_player, "DefaultAction", _actionVehEH] call ace_common_fnc_removeActionEventHandler;
        ACE_player setVariable ["ace_common_effect_blockThrow", 0];
        ACE_player setvariable ["ace_explosives_PlantingExplosive", false];
        ["vehicle", _vehPlayerEH] call CBA_fnc_removeEventHandler;
        /* ["turretWeapon", _turretEH] call CBA_fnc_removeEventHandler; */
        SETPLVAR(EHid, "DISABLED");
        SETPLVAR(Active, false);
    }, [_firedEH, _vehPlayerEH, _actionVehEH]] call CBA_fnc_waitUntilAndExecute;
}] call CBA_fnc_waitUntilAndExecute;
