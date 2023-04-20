## Copyright 2023 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: First installation using D-Installer current CLI (only for development purpose)
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base 'y2_installbase';
use strict;
use warnings;

use testapi;
use utils;
use power_action_utils qw(power_action);

my $timer = 0;
my $check_time = 15;
my $maxtime = 600;


sub verify_timeout_and_check_screen {
    my ($timer, $needles) = @_;
    if ($timer > $maxtime) {
        #Try to assert_screen to explicitly show mismatching needles
        assert_screen $needles;
        #Die explicitly in case of infinite loop when we match some needle
        die "timeout hit on during automatic installation";
    }
    return check_screen $needles, $check_time;
}


sub run {
    $testapi::password = 'linux';

    my @needles = 'tty6-selected';
    check_screen(@needles, 0);
    until (match_has_tag(@needles))
    {
        verify_timeout_and_check_screen(($timer += $check_time), \@needles);
    }
}

1;
