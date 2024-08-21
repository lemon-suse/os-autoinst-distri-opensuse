## Copyright 2024 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Perform Agama interactive dummy test.
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base Yam::agama::agama_base;
use strict;
use warnings;

use testapi;

sub run {
    select_console('root-console', await_console => 1, timeout =>300);
    script_run('for i in $(seq 60); do curl -s -o /dev/null http://localhost && exit 0; echo -n .; sleep 1; done');
}

1;
