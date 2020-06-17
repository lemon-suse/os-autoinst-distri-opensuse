# SUSE's openQA tests
#
# Copyright © 2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
# Summary: Actions required after upgrade
#       Such as:
#       1) Change the HDDVERSION to UPGRADE_TARGET_VERSION
# Maintainer: Wei Gao <wegao@suse.com>

use base "opensusebasetest";
use strict;
use warnings;
use testapi;
#use utils 'get_x11_console_tty';
use utils;

sub run {
    # Reset HDDVERSION after upgrade
    set_var('HDDVERSION', get_var('UPGRADE_TARGET_VERSION', get_var('VERSION')));
    pkcon_quit unless check_var('DESKTOP', 'textmode');
}

1;
