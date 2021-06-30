# SUSE's openQA tests
#
# Copyright © 2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: Introduces business actions for Navigation on installation
# Maintainer: QE YaST <qa-sle-yast@suse.de>

package Installation::Navigation::NavigationController;
use strict;
use warnings;
use YuiRestClient;
use Installation::Navigation::NavigationBar;

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    return $self->init();
}

sub init {
    my ($self) = @_;
    $self->{NavigationBar} = Installation::Navigation::NavigationBar->new({app => YuiRestClient::get_app()});
    return $self;
}

sub get_navigation_bar {
    my ($self) = @_;
    return $self->{NavigationBar};
}

sub proceed_next_screen {
    my ($self) = @_;
    $self->get_navigation_bar()->press_next();
}

1;
