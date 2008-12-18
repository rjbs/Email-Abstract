use strict;
use warnings;
package Email::Abstract::Adapter::Mail::Message;
use base 'Email::Abstract::Adapter';

sub target {"Mail::Message" }

sub construct {
    require Mail::Message;
    my ($class, $rfc822) = @_;
    Mail::Message->read($rfc822);
}

sub get_header { 
    my ($class, $obj, $header) = @_; 
    $obj->head->get($header);
}

sub get_body   { 
    my ($class, $obj) = @_; 
    $obj->decoded->string;
}

sub set_header { 
    my ($class, $obj, $header, @data) = @_; 
    $obj->head->delete($header);
    $obj->head->add($header, $_) for @data;
}

sub set_body   {
    my ($class, $obj, $body) = @_; 
    $obj->body(Mail::Message::Body->new(data => $body));
}

sub as_string { 
    my ($class, $obj) = @_; 
    $obj->string;
}

sub stream_to {
  my ($class, $obj, $fh) = @_;
  $obj->print($fh);
}

1;

=head1 NAME

Email::Abstract::Wrapper::Mail::Message - adapter for Mail::Message

=head1 DESCRIPTION

This module wraps the Mail::Message mail handling library with an
abstract interface, to be used with L<Email::Abstract>

=head1 SEE ALSO

L<Email::Abstract>, L<Mail::Message>.

=cut

