use strict;
use warnings;
package Email::Abstract::Adapter;

our $VERSION = '3.000';

=head1 NAME

Email::Abstract::Adapter - a base class for Email::Abstract email adapters

=head1 METHODS

=head2 is_available

This method returns true if the adapter should be considered available for
registration.  Adapters that return false from this method will not be
registered when Email::Abstract is loaded.

=cut

sub is_available { 1 }

sub stream_to { $_[1]->print($_[0]->as_string) }

1;
