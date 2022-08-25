#include "..\..\..\core\script_macros.hpp"
#include "..\functions\FIREMIS\defs.hpp"

FNC_DIA_PolarSpottingFiremissionOpenDialog =
{
	createDialog "DIA_POLARSPOTTINGFIREMISSION";
	[PSFM_DIA_IDC_GUNSELECT,PSFM_DIA_IDC_SHELLSELECT] call EFUNC(FIREMIS,Dia_ArtLoadAvailableArtilleries);
};

FNC_DIA_PolarSpottingFiremissionSetArtillery =
{
	[PSFM_DIA_IDC_SHELLSELECT,_this] call EFUNC(FIREMIS,Dia_ArtSetArtillery);
};

FNC_DIA_PolarSpottingFiremissionCloseDialog =
{
	closeDialog PSFM_DIA_IDD_DISPLAY;

};

FNC_DIA_PolarSpottingFiremissionFire =
{
	private _guns = player getVariable [VAR_SART_OBSGUNS,[]];
	private	_usableGuns = [];
	{
		if(_x call EFUNC(FIREMIS,Dia_IsArtyAvailable)) then
		{
			_usableGuns pushBack _x;
		};
	}forEach _guns;
	private	_selectedUnit = objNull;
	 if((count _usableGuns) > 0) then { _selectedUnit = (_usableGuns select (lbCurSel PSFM_DIA_IDC_GUNSELECT));};
	private _selectedAmmo = lbCurSel PSFM_DIA_IDC_SHELLSELECT;
	private	_grid = 	ctrlText PSFM_DIA_IDC_GRID;
	private	_mils = (ctrlText PSFM_DIA_IDC_MILS) call BIS_fnc_parseNumber;
	private _distance =  (ctrlText PSFM_DIA_IDC_DISTANCE) call BIS_fnc_parseNumber;
	if(_selectedUnit isEqualTo objNull) then  {hint "No Arty selected/aviable";}
	else
	{
		private _round =  ((_selectedUnit call EFUNC(FIREMIS,Dia_GetArtyAmmo)) select _selectedAmmo) select 0;
		hint (([_selectedUnit,[_grid,true] call CBA_fnc_mapGridToPos,_mils,_distance,_selectedAmmo] call EFUNC(FIREMIS,GetPolarSpottingFiremissionText))
								+ "Requested by: " + (name player)
								+ "\nETA: " + str (round ((_selectedUnit call EFUNC(FIREMIS,Dia_GetArtyAimTime)) + ([_selectedUnit,[_grid,true] call CBA_fnc_mapGridToPos,_round] call EFUNC(FIREMIS,Dia_GetArtyEta)))) + " s");
		["CallPolarSpotting", [player,_selectedUnit,_grid,_mils,_distance,_selectedAmmo]] call CBA_fnc_serverEvent;
		[] call FNC_DIA_PolarSpottingFiremissionCloseDialog;

	};



};

FNC_DIA_Server_PolarSpottingFiremissionFire =
{
	private _requester  = _this select 0;
	private _selectedUnit = _this select 1;
	private _callGrid = _this select 2;
	private _mils = _this select 3;
	private _distance = _this select 4;
	private	_roundType = _this select 5;

	[_selectedUnit,_requester] call EFUNC(FIREMIS,Dia_SetArtyCaller);
	[_selectedUnit,[_callGrid,true] call CBA_fnc_mapGridToPos,_mils,_distance,_roundType] call EFUNC(FIREMIS,PolarSpottingFiremission);

};

if(isServer) then {["CallPolarSpotting", {_this call FNC_DIA_Server_PolarSpottingFiremissionFire;}] call CBA_fnc_addEventHandler;};
