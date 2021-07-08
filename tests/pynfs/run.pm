# SUSE's openQA tests
#
# Copyright © 2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
# Summary: Run tests
# Maintainer: Yong Sun <yosun@suse.com>
package run;

use 5.018;
use strict;
use warnings;
use base 'opensusebasetest';
use File::Basename;
use testapi;
use utils;
use power_action_utils 'power_action';

sub server_test_all {
    my $self   = shift;
    my $folder = get_required_var('PYNFS');

    assert_script_run("cd ./$folder");
    script_run('./testserver.py -v --rundeps --hidepass --outfile result-raw.txt --maketree localhost:/exportdir all', 3600);
}

sub run {
    my $self = shift;
    $self->select_serial_terminal;

    script_run('cd ~/pynfs');
    server_test_all;
}

1;

=head1 Configuration

=head2 Example configuration for SLE:

BOOT_HDD_IMAGE=1
DESKTOP=textmode
HDD_1=SLES-%VERSION%-%ARCH%-%BUILD%@%MACHINE%-minimal_with_sdk%BUILD_SDK%_installed.qcow2
PYNFS=nfs4.0
UEFI_PFLASH_VARS=SLES-%VERSION%-%ARCH%-%BUILD%@%MACHINE%-minimal_with_sdk%BUILD_SDK%_installed-uefi-vars.qcow2
START_AFTER_TEST=create_hdd_minimal_base+sdk

=head2 PYNFS_GIT_URL

Overrides the official pynfs repository URL.

=head2 PYNFS_RELEASE

This can be set to a release tag, commit hash, branch name or whatever else Git
will accept.

If not set, then the default clone action will be performed, which probably
means the latest master branch will be used.

=cut
