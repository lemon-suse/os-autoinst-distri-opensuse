# SUSE's openQA tests
#
# Copyright 2022 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Package: podman
# Summary: Test podman pods functionality
# - Use data/containers/hello-kubic.yaml to run pods
# - Confirm 3 pods are spawned
# - Clean up pods using hello-kubic.yaml
# Maintainer: Richard Brown <rbrown@suse.com>

#use base "y2_module_consoletest";
use Mojo::Base 'containers::basetest';
use testapi;
use serial_terminal 'select_serial_terminal';
use version_utils qw(is_sle is_opensuse);

use strict;
use warnings;
use utils;
use network_utils 'iface';
use YuiRestClient;


sub run {
    my ($self, $args) = @_;
    my $instance = YuiRestClient::init_logger->get_instance();
    select_console 'root-console';
    my $iface = iface();
    my %setting = (device => $iface, zone => 'public');
    my $port = 39095;
    my $myport = $port;

    systemctl 'stop firewalld';
    sleep 60;
    systemctl 'is_active firewalld', expect_false => 1;

    set_var('YUI_REST_API', '1');
    #set_var('YUI_HTTP_PORT', $myport);
    set_var('YUI_PORT', $myport);
    set_var('YUI_HTTP_REMOTE', '1');
    set_var('YUI_REUSE_PORT', '1');
    record_info('Prep', 'Get kube yaml');
    assert_script_run('podman search yast-mgmt-ncurses');
    script_run("YUI_HTTP_PORT=$myport YUI_HTTP_REMOTE=1 YUI_REUSE_PORT=1 podman container runlabel run registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/yast-mgmt-ncurses-test-api firewall; echo yast-mgmt-ncurses-\$? > /dev/$serialdev", 0 );
    #script_run("podman container runlabel run registry.opensuse.org/suse/alp/workloads/tumbleweed_containerfiles/suse/alp/workloads/yast-mgmt-ncurses-test-api firewall; echo yast-mgmt-ncurses-\$? > /dev/$serialdev", 0 );
    sleep 180;

    select_serial_terminal;
    my $app = YuiRestClient::get_app(timeout => 60, interval => 1);
    my $port = $app->get_port();
    record_info('SERVER', "Used host for libyui: " . $app->get_host());
    record_info('PORT', "Used port for libyui: " . $port);
    set_var('YUI_PARAMS', YuiRestClient::get_yui_params_string($port));

    my $ou = script_output("ss -nlpt");
    diag "ss=$ou";

    my $out = script_output("curl 'http://localhost:39095/v1/widgets?id=%22Y2Firewall%3A%3AWidgets%3A%3AOverviewTree%22'");
    diag "myout=$out";
    #select_serial_terminal;
    # my $out = script_output("curl 'http://localhost:9999/v1/widgets'");
    #diag "myout=$out"; 
    #wait_still_screen 120;
    $testapi::distri->get_firewall()->select_interfaces_page();
    save_screenshot;
    $testapi::distri->get_firewall()->set_interface_zone($setting{device}, $setting{zone});
    save_screenshot;
    $testapi::distri->get_firewall()->accept_change();
    assert_screen 'generic-desktop';
    select_console 'root-console';
    systemctl 'restart firewalld', timeout => 200 if (script_run(("grep 'FlushAllOnReload.*no' /etc/firewalld/firewalld.conf") == 0));
    validate_script_output("firewall-cmd --list-interfaces --zone=$setting{zone}", sub { m/$setting{device}/ }, proceed_on_failure => 1);
    select_console 'x11', await_console => 0;

    #    my $nlpt = script_output("ss -nlpt");
    #diag "mynlpt=$nlpt";
    #my $out = script_output("curl 'http://localhost:9999/v1/widgets'");
    #diag "myout=$out";

    #$podman->cleanup_system_host();
}

1;
