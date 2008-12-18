use strict;
use warnings;

package Email::Abstract::Adapter::Email::MIME;
use base 'Email::Abstract::Adapter::Email::Simple';

sub target { "Email::MIME" }

sub construct {
    require Email::MIME;
    my ($class, $rfc822) = @_;
    Email::MIME->new($rfc822);
}

1;

=head1 NAME

Email::Abstract::Adapter::Email::MIME - adapter for Email::MIME

=head1 DESCRIPTION

This module wraps the Email::MIME mail handling library with an
abstract interface, to be used with L<Email::Abstract>

=head1 SEE ALSO

L<Email::Abstract>, L<Email::MIME>.

=cut

