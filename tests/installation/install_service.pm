
# Copyright (C) 2019 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

# Summary: Installs and checks a service for migration scenarios
# Maintainer: Joachim Rauch <jrauch@suse.com>

use strict;
use warnings;
use base 'installbasetest';
use testapi;
use utils 'systemctl', 'zypper_call';
use service_check;
use version_utils qw(is_hyperv is_sle is_sles4sap);
use main_common 'is_desktop';

sub run {

    select_console 'root-console';

    install_services($default_services)
      if is_sle
      && !is_desktop
      && !is_sles4sap
      && !is_hyperv
      && !get_var('MEDIA_UPGRADE')
      && !get_var('ZDUP')
      && !get_var('INSTALLONLY');

    if ($srv_check_results{'before_migration'} eq 'FAIL') {
        record_info("Summary", "failed", result => 'fail');
        die "Service check before migration failed!";
    }
}

sub test_flags {
    return {fatal => 0};
}

sub post_fail_hook {
    eval {
        select_console('root-virtio-terminal1') if (get_var('VIRTIO_CONSOLE_NUM', 1) > 1);
        upload_file('/tmp/tcpdump' . 'vnctest' . '.pcap', 'tcpdump' . 'vnctest' . '.pcap');
    };
}

1;
