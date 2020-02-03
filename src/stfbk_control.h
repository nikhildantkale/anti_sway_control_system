/*
 * statefeedbk_control.h
 * Created: 10/12/2018 11:54:18 PM
 *  Author: Govardhan
 */ 


#ifndef STFBK_CONTROL_H_
#define STFBK_CONTROL_H_

/* ---- from MATLAB: ------- */
#define N_STATES 4
#define KD_SHIFT 12  		 // int 16.12
#define LIMIT_POS  8544256 // int 32.12       // DAC Limitation = 2086*2^12
#define LIMIT_NEG  -8228864 // int 32.12      // DAC Limitation = -2009*2^12

//#define LIMIT_POS  4096 // int 32.12
//#define LIMIT_NEG  -4096 // int 32.12

#endif /* STFBK_CONTROL_H_ */