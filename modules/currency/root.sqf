#include "script_component.hpp"

#ifdef description_XEH_PreInit
	class COMPONENT {
		clientInit = "'' call compile preprocessFileLineNumbers 'modules\currency\preInitClient.sqf'";
	};
#endif

#ifdef description_external_functions
	#include "functions\CfgFunctions.hpp"
#endif

#ifdef description
	class CfgCurrency {
		#include "CfgCurrency.hpp"
	};
#endif

#undef COMPONENT
