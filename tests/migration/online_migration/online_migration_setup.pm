# SLE12 online migration tests
#
# Copyright 2016 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Online migration setup
# Maintainer: yutao <yuwang@suse.com>

use base "consoletest";
use strict;
use warnings;
use utils;
use version_utils qw(is_desktop_installed is_sles4sap);
use testapi;
use migration;

sub run {
    my ($self) = @_;

    # Do not attempt to log into the desktop of a system installed with SLES4SAP
    # being prepared for upgrade, as it does not have an unprivileged user to test
    # with other than the SAP Administrator
    #
    # If source system is minimal installation then boot to textmode
    # we don't care about source system start time because our SUT is upgraded one
    $self->wait_boot(textmode => !is_desktop_installed, bootloader_time => 400, ready_time => 600, nologin => is_sles4sap);
    $self->setup_migration();

    select_console 'root-console';
    my $str = assert_script_run("blkid | grep 'TYPE=\"swap\"' | awk '{printf \$2}'");
    diag "str=$str";
    my $uuidstr = assert_script_run('echo ${str#"UUID="}');
    diag "uuidstr=$uuidstr";
    assert_script_run('sed -i "s/\(resume=*\)[^ ]*/noresume/g" /etc/default/grub');
    assert_script_run("cat /etc/default/grub");
    assert_script_run("grub2-mkconfig -o /boot/grub2/grub.cfg");
}

sub test_flags {
    return {fatal => 1};
}

sub post_fail_hook {
    my ($self) = @_;

    # Show the console log if stuck on the plymouth splash screen
    wait_screen_change {
        send_key 'esc';
    };

    # Try to login to tty console
    select_console 'root-console' unless (match_has_tag('emergency-shell') or match_has_tag('emergency-mode'));

    # Save logs if succeed to access a console
    $self->SUPER::post_fail_hook;
}

1;
