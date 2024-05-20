# SUSE's openQA tests
#
# Copyright 2024 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Validate that a RAID multi-disk is directly formatted with an
# encrypted home (md is not partitioned).
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use strict;
use warnings;
use base "opensusebasetest";
use testapi;
use Mojo::JSON qw(decode_json);
use scheduler 'get_test_suite_data';

sub run {
    select_console 'root-console';

    my $test_data = get_test_suite_data();
    my $test_data_name = $test_data->{mds}[1]{name};
    my $test_data_crypt = $test_data->{mds}[1]{crypt_method};
    my $test_data_type = 'encrypt' if $test_data_crypt;
    my $test_data_mount = $test_data->{mds}[1]{mount};
    my @expect = @{$test_data_name . $test_data_crypt . $test_data_type};

    my $lsblk_output = decode_json(script_output("lsblk -M -J /dev/md1"));
    my $dev_name = $lsblk_output->{blockdevices}[0]{name};
    my @dev_children = $lsblk_output->{blockdevices}[0]{children};
    my $dev_children_name = $dev_children[0]{name};
    my $dev_children_type = $dev_children[0]{type};
    my $dev_children_mountpoint = $dev_children[0]{mountpoints}[0];
    my @actual = @{$dev_name . $dev_children_name . $dev_children_type . $dev_children_mountpoint};
    assert_matches($_, @actual, "Partition not found") for (@expect);
    # unless (($dev_name =~ 'md1') && ($dev_children_name =~ 'cr_home') && ($dev_child_mountpoint =~ 'home')) {
    #    die "RAID partitioning layout not as expected";
    #}
}

1;
