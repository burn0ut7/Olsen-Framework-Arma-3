#include "script_component.hpp"

private _ret = 0;
if((_this select 0) > ((_this select 1) * 0.5)) then
{
  _ret = _this select 1 / 2;
}
else
{
  /* _ret = _dis; */
  _ret = 0;
};
_ret
