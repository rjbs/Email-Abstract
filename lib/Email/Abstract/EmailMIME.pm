use strict;
use warnings;
package Email::Abstract::EmailMIME;
# ABSTRACT: Email::Abstract wrapper for Email::MIME

use Email::Abstract::EmailSimple;
BEGIN { @Email::Abstract::EmailMIME::ISA = 'Email::Abstract::EmailSimple' };

sub target { "Email::MIME" }

sub construct {
    require Email::MIME;
    my ($class, $rfc822) = @_;
    Email::MIME->new($rfc822);
}

sub get_body {
    my ($class, $obj) = @_;

    # Return the same thing you'd get from Email::Simple.
    #
    # Ugh.  -- rjbs, 2014-12-27
    return $obj->body_raw;
}

1;

=head1 DESCRIPTION

This module wraps the Email::MIME mail handling library with an
abstract interface, to be used with L<Email::Abstract>

=head1 SEE ALSO

L<Email::Abstract>, L<Email::MIME>.

=cut

