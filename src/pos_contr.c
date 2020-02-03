 /*
 * pos_contr.c
 * Created: 10/12/2018 11:53:18 PM
 *  Author: Govardhan
 */ 

#include "xil_types.h"
#include "pi_control.h"
#include "stfbk_control.h"

s16 pos_contr(s8 reset, s16 ref_val, s16 state1, s16 state2, s16 state3, s16 state4)
{
	s16 uu=0;
	
	if (reset > 0 )		
	{
		CpContrInit();
		uu = 0;
	}
	else
	{
        uu = CpContrCalc(ref_val, state1, state2, state3, state4); 
	}
	
	return uu ;
}