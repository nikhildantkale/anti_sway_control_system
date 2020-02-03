/*
 * stfbk_control.c
 *
 * Created: 10/12/2018 11:53:18 PM
 *  Author: Govardhan
 */ 

#include "xil_types.h"
#include "pi_control.h"
#include "stfbk_control.h"

void CpContrInit(void);
s16 CpContrCalc(s16 refval, s16 state_1, s16 state_2, s16 state_3, s16 state_4);

static s16 x[N_STATES];										// State vector
s16 KD[N_STATES] ={ -7232,-14577, 23956, 389 };		// State_feedback vector 16.12

void CpContrInit(void)
{
	s8 k;
	
	UPiCtrlInit(KP_FIX, KI_FIX, LIMIT_INT, LIMIT_PI_OUT);	// Initialize the PI controller 
	
	for(k=0; k<N_STATES; k++)		// Reset the states 
	{
		x[k]=0;
	}
}

s16 CpContrCalc(s16 refval, s16 state_1, s16 state_2, s16 state_3, s16 state_4)
{
	s32 u_pi=0;
	s32 u_sfb=0;
	s8 k;
	
	x[0] = state_1;
	x[1] = state_2;
	x[2] = state_3;
	x[3] = state_4;
		
	u_pi = UPiCtrlC(refval, state_4);		// PI_controller calculation output in format 32.KP_SHIFT;	
    u_pi >>= KP_SHIFT-KD_SHIFT;             // its necessary to make the fractional digits same int_32.12
    
	for (k = 0; k < N_STATES; k++)			// Statefeedback_calculation ; 
    {	u_sfb += (KD[k] * x[k]); }							
	
//     u_sfb = (KD[0] * x[0]);
//     u_sfb = (KD[1] * x[1]) + u_sfb;
//     u_sfb = (KD[2] * x[2]) + u_sfb;
//     u_sfb = (KD[3] * x[3]) + u_sfb;
//     
	u_sfb = u_pi - u_sfb;
	
    /*
	if (u_sfb > LIMIT_POS )			    // Check if the force is within the range
	{
		u_sfb = LIMIT_POS;
	}
	else if (u_sfb < LIMIT_NEG )			
	{
		u_sfb = LIMIT_NEG;
	}	
    */
	if (u_sfb > 903299 )			    // Check if the force is within the range
	{
		u_sfb = 903299;
	}
	else if (u_sfb < -903299 )			
	{
		u_sfb = -903299;
	}	
			
	u_sfb >>= 12;	// Shift the result to make it 32 bit integer from 32.12
											
	return (s16)u_sfb;  
}