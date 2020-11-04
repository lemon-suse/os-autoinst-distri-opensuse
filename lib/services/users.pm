# SUSE's openQA tests
#
# Copyright © 2020 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Package for users test
#
# Maintainer: Lemon Li <leli@suse.com>

package services::users;
use base "x11test";
use strict;
use warnings;
use testapi;
use utils;
use power_action_utils 'reboot_x11';
use version_utils;
use x11utils;
use main_common 'opensuse_welcome_applicable';
use opensusebasetest;

my $newpwd      = "suseTEST-987";
my $oldpwd      = "nots3cr3t";
my $newUser     = "test";
my $pwd4newUser = "helloWORLD-0";

sub lock_screen {
    assert_and_click "system-indicator";
    assert_and_click "lock-system";
    send_key_until_needlematch 'gnome-screenlock-password', 'esc', 5, 10;
    type_password "$newpwd\n";
    assert_screen "generic-desktop";
}

sub logout_and_login {
    handle_logout;
    send_key_until_needlematch 'displaymanager', 'esc', 9, 10;
    mouse_hide();
    wait_still_screen;
    assert_and_click "displaymanager-$username";
    assert_screen 'displaymanager-password-prompt', no_wait => 1;
    type_password "$newpwd\n";
    assert_screen 'generic-desktop', 120;
}

sub reboot_system {
    my ($self) = @_;
    reboot_x11;
    if (check_var('NOAUTOLOGIN', 1)) {
        $self->{await_reboot} = 1;
        $self->wait_boot(nologin => 1);
        assert_screen "displaymanager", 200;
        $self->{await_reboot} = 0;
        assert_and_click "displaymanager-$username";
        wait_still_screen;
        type_string "$newpwd\n";
    } else {
        $self->wait_boot();
    }
    assert_screen "generic-desktop";
}

sub switch_user {
    assert_and_click "system-indicator";
    assert_and_click "user-logout-sector";
    assert_and_click "switch-user";
}

sub change_pwd {
    my ($oldpassword, $newpassword) = @_;
    send_key "alt-p";
    wait_still_screen;
    send_key "ret";
    wait_still_screen;
    send_key "alt-p";
    wait_still_screen;
    type_password $oldpassword;
    wait_still_screen;
    send_key "alt-n";
    wait_still_screen;
    type_string $newpassword;
    wait_still_screen;
    send_key 'tab';
    wait_still_screen;
    type_string $newpassword;
    assert_screen "actived-change-password";
    send_key "alt-a";
    assert_screen "users-settings", 60;
}

sub add_user {
    assert_and_click "add-user";
    type_string $newUser;
    assert_screen("input-username-test");
    assert_and_click "set-password-option";
    send_key "alt-p";
    type_string $pwd4newUser;
    send_key 'tab';
    type_string $pwd4newUser;
    assert_screen "actived-add-user";
    send_key "alt-a";
    assert_screen "users-settings", 60;
    send_key "alt-f4";
}

sub auto_login_alter {
    my ($self) = @_;
    $self->unlock_user_settings;
    send_key "alt-u";
    send_key "alt-f4";
}

sub switch_users {
#swtich to new added user then switch back
    switch_user;
    wait_still_screen 5;
    send_key "esc";
    assert_and_click 'displaymanager-test';
    assert_screen "testUser-login-dm";
    type_string "$pwd4newUser\n";
    # Handle welcome screen, when needed
    handle_welcome_screen(timeout => 120) if (opensuse_welcome_applicable);
    assert_screen "generic-desktop", 120;
    switch_user;
    send_key "esc";
    assert_and_click "displaymanager-$username";
    assert_screen "originUser-login-dm";
    type_string "$newpwd\n";
    assert_screen "generic-desktop", 120;
}

# restore the password of bernhard to old password
sub restore_bernhard_passwd {
    select_console 'root-console';
    script_run 'passwd bernhard';
    type_string "$oldpwd\n";
    wait_still_screen;
    type_string "$oldpwd\n";
    wait_still_screen;
}

#restore password to original value
sub restore_passwd {
     x11_start_program('gnome-terminal');
     type_string "su\n";
     assert_screen "pwd4root-terminal";
     type_password "$password\n";
     assert_screen "root-gnome-terminal";
     type_string "passwd $username\n";
     assert_screen "pwd4user-terminal";
     type_password "$password\n";
     assert_screen "pwd4user-confirm-terminal";
     type_password "$password\n";
     assert_screen "password-changed-terminal";
}
# check users before and after migration
# stage is 'before' or 'after' system migration.
sub full_users_check {
    my ($self) = @_;
    my $own = shift;
    my $stage = shift;
    $stage //= '';

    turn_off_gnome_screensaver if check_var('DESKTOP', 'gnome');
    sleep 5;
    select_console 'x11', await_console => 0;
    sleep 5;
    ensure_unlocked_desktop;
    assert_screen "generic-desktop";
    if ($stage eq 'before') {
        #change pwd for current user and add new user for switch scenario
	x11test::unlock_user_settings;
        change_pwd $oldpwd, $newpwd;
        add_user;
        #verify changed password work well in the following scenario:
        lock_screen;
        turn_off_gnome_screensaver;
        logout_and_login;
        if (is_tumbleweed && !get_var('NOAUTOLOGIN')) {
            set_var('NOAUTOLOGIN', 1);
            auto_login_alter;
        }
	#restore_bernhard_passwd;
	reboot_system;
        switch_users;
        restore_passwd;

    }
    else {
        #swtich to new added user then switch back
        $own->reboot_system;
        switch_users;
        restore_passwd;
        send_key "alt-f4";
        send_key "ret";
    }
}

1;
