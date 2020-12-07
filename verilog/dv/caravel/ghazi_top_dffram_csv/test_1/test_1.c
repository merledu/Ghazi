#include "../../defs.h"

void main()
{
  // reg_mprj_io_0 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_1 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_2 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_3 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_4 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  // reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
 
  reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;

  reg_mprj_xfer = 1;
  while(reg_mprj_xfer == 1);
	
  reg_la1_ena = 0x00000000;
  reg_la1_data = 0x0000015C;
  
  reg_la0_ena = 0x00000000;
  reg_la0_data = 0x00000001;
  reg_la0_data = 0x00000000;
  reg_mprj_datah = 0x20;

}
