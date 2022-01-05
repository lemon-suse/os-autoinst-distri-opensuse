# SUSE's openQA tests
#
# Copyright 2022 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Package for docker service tests
#
# Maintainer: Lemon Li <leli@suse.com>

package services::dockerd;
use base 'opensusebasetest';
use testapi;
use utils;
use strict;
use warnings;


use Mojo::Base 'containers::basetest';
use containers::common;
use containers::utils;
use containers::container_images;

my $service_type = 'Systemd';

sub create_docker {
    my $sleep_time = 90 * get_var('TIMEOUT_SCALE', 1);
    my $dir = "/root/DockerTest";

    #my $engine = $self->containers_factory('docker');
    test_seccomp();
}

# check apache service before and after migration
# stage is 'before' or 'after' system migration.
sub full_dockerd_check {
#    my (%hash) = @_;
#    my ($stage, $type) = ($hash{stage}, $hash{service_type});
#    $service_type = $type;
    my ($self) = @_;
    opensusebasetest::select_serial_terminal;
    diag 'after select_serial_terminal';
    my $sleep_time = 90 * get_var('TIMEOUT_SCALE', 1);
    my $dir = "/root/DockerTest";

    my $engine = containers::basetest::containers_factory('docker');
    test_seccomp();

    # Test the connectivity of Docker containers
    $engine->check_containers_connectivity();

    # Run basic runtime tests
    basic_container_tests(runtime => $engine->runtime);
    # Build an image from Dockerfile and run it
    build_and_run_image(runtime => $engine, dockerfile => 'Dockerfile.python3', base => registry_url('python', '3'));

    # Clean container
    $engine->cleanup_system_host();
}

1;
