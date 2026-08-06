## Copyright 2024 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Validate feature restrict network access to the installer.
# integration test from GitHub.
# Maintainer: QE Installation and Migration (QE Iam) <none@suse.de>

use Mojo::Base 'Yam::Agama::patch_agama_base';
use testapi qw(assert_script_run get_required_var select_console);

sub run {
    select_console 'install-shell';

    if (is_s390x()) {
	validate_script_output("curl -Is https://download.suse.de", sub { m/HTTP/2 200/ }, proceed_on_failure => 1);
    }
    else {
        script_run("ss -tuln | grep :80");
	script_run("ss -tuln | grep :443");
    }
}

1;
