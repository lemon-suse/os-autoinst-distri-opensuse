# SUSE's openQA tests
#
# Copyright 2024 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Handles common actions when entering passphrase.
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

package Yam::Agama::Pom::EnterPassphraseBasePage;
use strict;
use warnings;
use testapi;

sub new {
    my ($class, $args) = @_;
    return bless {}, $class;
}

sub enter {
    my ($self) = @_;
    #type_password();
    type_password($testapi::password, max_interval => 100, wait_screen_change => 2, timeout => 60, secret => 0);
    send_key "ret";
}

1;
