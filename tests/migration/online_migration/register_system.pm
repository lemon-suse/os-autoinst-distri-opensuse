# SLE12 online migration tests
#
# Copyright 2016 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Package: SUSEConnect zypper yast2-registration
# Summary: sle12 online migration testsuite
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base "y2_module_consoletest";
use strict;
use warnings;
use testapi;
use migration;

sub run {
    select_console 'root-console';
    script_run 'zypper ar --refresh http://download.suse.de/ibs/Devel:/SCC:/suseconnect/SLE_15_SP3_Update/Devel:SCC:suseconnect.repo';
    # script_run 'zypper --non-interactive --gpg-auto-import-keys in suseconnect-ng-1.9.0-150300.92.1.x86_64 suseconnect-ruby-bindings-1.9.0-150300.92.1.x86_64 libsuseconnect-1.9.0-150300.92.1.x86_64';
    script_run 'zypper --non-interactive --gpg-auto-import-keys in suseconnect-ng-1.9.0-150300.92.1.aarch64 suseconnect-ruby-bindings-1.9.0-150300.92.1.aarch64 libsuseconnect-1.9.0-150300.92.1.aarch64';
    #script_run 'zypper --non-interactive --gpg-auto-import-keys in suseconnect-ruby-bindings';
    #script_run 'zypper --non-interactive --gpg-auto-import-keys in libsuseconnect';
    script_run 'rpm -qa suseconnect-ng';
    script_run 'rpm -qa suseconnect-ruby-bindings';
    script_run 'rpm -qa libsuseconnect';
    register_system_in_textmode;
}

sub test_flags {
    return {fatal => 1};
}

1;
