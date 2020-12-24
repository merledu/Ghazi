<!---
# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
-->
# Mega-Project Ghazi SoC Tests

The directory includes tests for Ghazi SoC mega-project: 

1) Test 1: 

	* Configures the user space lower 8 IO pins as outputs
	* Runs an example counter program on the Ghazi SoC.
	* Observes the counter value through the configured pins in the testbench

In addition to this, each test has the following config written for management SoC in common to allow Ghazi SoC itself to be programmed** on each each reset:
* mprj_io[5] and mprj_io[37] are configured as user area input and managment area output respectively
* LA probes [47:32] are configured as outputs to set the CLKS PER BIT value of the progamming UART receiver
* Reset is asserted and then deasserted using LA probe [0] from the management SoC
* The mprj_io[37] pin is set high indicating that the IO pads have been configured and testbench programming UART transmitter can start sending out the instructions

** The hex files for the programs to be run on Ghazi SoC are stored in the hex directory
