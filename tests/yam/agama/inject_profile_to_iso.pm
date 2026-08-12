## Copyright 2024 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Injecting an installation profile into a copy of the ISO image for production testing.
# integration test from GitHub.
# Maintainer: QE Installation and Migration (QE Iam) <none@suse.de>

use Mojo::Base 'Yam::Agama::patch_agama_base';
use testapi qw(assert_script_run autoinst_url data_url get_required_var get_var select_console set_var upload_asset script_run);
use utils;

sub run {
    my $test_iso = 'test.iso';
    my $regcode = get_var('SCC_REGCODE');
    select_console 'install-shell';
    assert_script_run("curl -f -L -o $test_iso http://download.suse.de/install/SLES-16.1-LATEST/SLES-16.1-Online-x86_64-012-RC2.install.iso", timeout => 600);
    assert_script_run('curl -f -o /tmp/data.jsonnet ' . autoinst_url("/data/yam/agama/auto/autoinst_oemdrv.jsonnet"));
    assert_script_run('jsonnet /tmp/data.jsonnet -o /tmp/data.json ');
    assert_script_run("jq --arg code \"$regcode\" '.product.registrationCode = \$code' /tmp/data.json > /tmp/data.json.tmp && mv /tmp/data.json.tmp /tmp/data.json");
    assert_script_run('cat /tmp/data.json');

    zypper_call("ar -f -G https://download.suse.de/ibs/SUSE:/SLFO:/Products:/SLES:/" . get_var('VERSION') . ":/TEST/product/repo/SLES-" . get_var('VERSION') . "-" . get_var('ARCH') . "/?ssl_verify=no install");
    zypper_call("in --no-recommends -y xorriso");

    #assert_script_run(
        #'xorriso -dev test.iso -map /tmp/data.json /autoinst.json',
	#     "xorriso -abort_on WARNING -indev test.iso -outdev agama-auto.iso -boot_image any replay -map /tmp/data.json /autoinst.json",
	#timeout => 600
	# );
    assert_script_run(
        'xorriso -abort_on FAILURE -return_with SORRY 0 -indev test.iso -outdev agama-auto.iso -boot_image any replay -map /tmp/data.json /autoinst.json',
        timeout => 600
    );

    #assert_script_run(
    #    "xorriso -dev /dev/sr0 -outdev $test_iso -map /tmp/data.json /autoinst.json",
    #    timeout => 600
    #);
    #assert_script_run(
    #    "xorriso -indev /dev/sr0 -outdev /tmp/$test_iso -map /tmp/data.json /autoinst.json",
    #    timeout => 600
    #);

    # Sync and upload the modified test.iso
    assert_script_run('mv /agama-auto.iso /test.iso');
    script_run('sync');
    script_run('la /');

    upload_asset('/test.iso', 1);
    set_var('ISO', 'test.iso');
}

1;
