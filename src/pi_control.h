/*
 * pi_control.h
 * Created: 10/12/2018 11:54:52 PM
 *  Author: Govardhan
 */ 

#ifndef PI_CONTROL_H_
#define PI_CONTROL_H_

/* ---- from MATLAB: ------- */
#define KP_FIX  878    // int 16.15 
#define KI_FIX 32      // int 16.15 

#define KP_SHIFT  15  //16.14
#define KI_SHIFT  15  //16.15
#define LIMIT_INT    98304000 // int 32.15 (3000.0)
#define LIMIT_PI_OUT 67076096 // int 32.15  // DAC Limitation = 2047*2^15
//#define LIMIT_PI_OUT 32768 // int 32.15 

/* ------------------------- */

typedef struct {
	s16 kp;
	s16 ki;
	s32 limit_out;
	s32 limit_int;
	s32 xi;
} PIObj_struct;

void UPiCtrlInit(s16 pgain, s16 igain, s32 limit_i, s32 limit_o);
s32 UPiCtrlC(s16 reff, s16 out_fbb);
s16 pos_contr(s8 reset, s16 ref_val, s16 state1, s16 state2, s16 state3, s16 state4);
void CpContrInit(void);
s16 CpContrCalc(s16 refval, s16 state_1, s16 state_2, s16 state_3, s16 state_4);

#endif /* PI_CONTROL_H_ */

