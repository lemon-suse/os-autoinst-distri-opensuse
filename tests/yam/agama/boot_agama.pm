## Copyright 2024 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Boot to agama adding bootloader kernel parameters and expecting web ui up and running.
# At the moment redirecting to legacy handling for remote architectures booting.
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base "installbasetest";
use strict;
use warnings;

use testapi;
use Utils::Architectures;
use Utils::Backends;

use Mojo::Util 'trim';
use File::Basename;
use Utils::Logging 'save_and_upload_log';

BEGIN {
    unshift @INC, dirname(__FILE__) . '/../../installation';
}
use bootloader_s390;
use bootloader_zkvm;
use bootloader_pvm;

sub run {
    my $self = shift;

    # For now using legacy code to handle remote architectures
    if (is_s390x()) {
        if (is_backend_s390x()) {
            record_info('bootloader_s390x');
            $self->bootloader_s390::run();
        } elsif (is_svirt) {
            record_info('bootloader_zkvm');
            $self->bootloader_zkvm::run();
        }
        return;
    }
    elsif (is_pvm_hmc()) {
        $self->bootloader_pvm::boot_pvm();
        return;
    }

    my $grub_menu = $testapi::distri->get_grub_menu_agama();
    my $grub_entry_edition = $testapi::distri->get_grub_entry_edition();
    my $agama_up_an_running = $testapi::distri->get_agama_up_an_running();

    # prepare kernel parameters
    if (my $agama_auto = get_var('AGAMA_AUTO')) {
        my $path = data_url($agama_auto);
        set_var('EXTRABOOTPARAMS', get_var('EXTRABOOTPARAMS', '') . " agama.auto=\"$path\"");
    }
    my @params = split ' ', trim(get_var('EXTRABOOTPARAMS', ''));

    $grub_menu->expect_is_shown();
    $grub_menu->edit_current_entry();
    $grub_entry_edition->move_cursor_to_end_of_kernel_line();
    $grub_entry_edition->type(\@params);
    $grub_entry_edition->boot();
    $agama_up_an_running->expect_is_shown();
}

sub post_fail_hook {
    upload_agama_logs();
}

sub upload_agama_logs {
    select_console 'root-console';
    save_and_upload_log('agama config show > /tmp/agama-config.json', "/tmp/agama-confi[?4mn", {timeout => 60});
    script_run("agama logs store -d /tmp/agama-logs", {timeout => 60});
    upload_logs("/tmp/agama-logs.tar.gz", failok => 1);
    save_and_upload_log('journalctl -b > /tmp/journal.log', "/tmp/journal.log", {timeout => 60});
}

1;
