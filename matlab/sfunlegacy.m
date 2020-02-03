 % create legacy mex function for cart control
def = legacy_code('initialize');
def.SourceFiles = {'pos_contr.c','stfbk_control.c', 'pi_control.c'};
def.HeaderFiles = {'stfbk_control.h', 'xil_types.h', 'pi_control.h'};
def.SFunctionName = 'ex_sfun_pos_contr';
%s32 CpContr(s8 reset, s32 ref_val, s32 state1, s32 state2, s32 state3, s32 state4);
def.OutputFcnSpec = 'int16 y1 = pos_contr(int8 u1, int16 u2, int16 u3, int16 u4, int16 u5, int16 u6)';
legacy_code('sfcn_cmex_generate', def)
legacy_code('compile', def)
%legacy_code('slblock_generate', def)
disp('That`s all folks.')
