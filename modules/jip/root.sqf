#include "script_component.hpp"

#ifdef description_XEH_PreInit
	class COMPONENT {
		clientInit = "'' call compile preprocessFileLineNumbers 'modules\jip\preInitClient.sqf'";
		serverInit = "'' call compile preprocessFileLineNumbers 'modules\jip\preInitServer.sqf'";
	};
#endif

#ifdef description_XEH_PostInit
	class COMPONENT {
		clientInit = "'' call compile preprocessFileLineNumbers 'modules\jip\postInitClient.sqf'";
	};
#endif

#ifdef description_external_functions
	#include "functions\CfgFunctions.hpp"
#endif

#undef COMPONENT
