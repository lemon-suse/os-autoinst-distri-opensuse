# SUSE's openQA tests
#
# Copyright 2018 SUSE LLC
# SPDX-License-Identifier: FSFAP
#
# Summary: Record the disk usage before migration
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base "opensusebasetest";
use strict;
use warnings;
use testapi;
use migration 'record_disk_info';

sub run {
    select_console 'root-console';

    #lemon
    assert_script_run "systemctl disable kdump";
    assert_script_run "systemctl mask kdump";

    # The disk space usage info would be helpful to debug upgrade failure
    # with disk exhausted error
    record_disk_info;
}

1;
