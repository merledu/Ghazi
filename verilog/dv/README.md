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
# DV Tests

Organized into two subdirectories:
  * caravel: contains tests for the mangement SoC, an example user project and Ghazi SoC, keeping in mind, the tests for example user project won't work anymore
  * wb_utests: contains unit tests for the wishbone components residing at the management SoC private bus

<pre>
├── caravel
│   ├── mgmt_soc
│   ├── ~~user_proj_example~~
│   ├── ghazi_top_dffram_csv
└── wb_utests
</pre>

