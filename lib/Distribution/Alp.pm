# SUSE's openQA tests
#
# Copyright 2023 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: The class represents Alp distribution and provides access to
# its features.

# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

package Distribution::Alp;
use strict;
use warnings FATAL => 'all';
use parent 'susedistribution';
use YaST::Firewall::FirewallController;

sub get_firewall {
    return YaST::Firewall::FirewallController->new();
}

1;
