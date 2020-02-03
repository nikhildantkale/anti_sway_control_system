/*
 * pi_control.c
 *
 * Created: 10/12/2018 11:55:18 PM
 *  Author: Govardhan
 */ 

#include "xil_types.h"
#include "pi_control.h"
#include "stfbk_control.h"

static PIObj_struct CpPhase;

void UPiCtrlInit(s16 pgain, s16 igain, s32 limit_i, s32 limit_o) 
{
	CpPhase.kp = pgain;
	CpPhase.ki = igain;
	CpPhase.limit_int = limit_i;
	CpPhase.limit_out = limit_o;
	CpPhase.xi = 0;
}

s32 UPiCtrlC(s16 reff, s16 out_fbb)
{
	s32 u_ctr;
	s16 ctr_e;
    
	ctr_e = reff - out_fbb ;		// Calculate the error

    u_ctr = CpPhase.kp * ctr_e + ( CpPhase.xi >> (KI_SHIFT - KP_SHIFT));	// calculate the output
	
    /*
    if (u_ctr > CpPhase.limit_out )         // limit on PI output
	{ 
        u_ctr = CpPhase.limit_out;
    }
    else if (u_ctr < -CpPhase.limit_out )
    {
        u_ctr = -CpPhase.limit_out;
    }
    */

    CpPhase.xi += (CpPhase.ki * ctr_e) ;     // integral steps calculation
    
    if ( CpPhase.xi > CpPhase.limit_int )    // Limit on integrator
       CpPhase.xi = CpPhase.limit_int;
    else if ( CpPhase.xi < -CpPhase.limit_int ) 
       CpPhase.xi = -CpPhase.limit_int;

	return u_ctr;
}

