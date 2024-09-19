## Copyright 2024 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Run interactive installation with Agama,
# using a web automation tool to test directly from the Live ISO.
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base "opensusebasetest";
use strict;
use warnings;
use testapi;

sub run {
    my $reboot_page = $testapi::distri->get_reboot_page();

    select_console('installation');
    $reboot_page->reboot();
}

1;
