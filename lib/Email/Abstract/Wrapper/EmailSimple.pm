use strict;
use warnings;
package Email::Abstract::Adapter::Email::Simple;
use base 'Email::Abstract::Adapter';

sub target { "Email::Simple" }

sub construct {
    require Email::Simple;
    my ($class, $rfc822) = @_;
    Email::Simple->new($rfc822);
}

sub get_header { 
    my ($class, $obj, $header) = @_; 
    $obj->header($header); 
}

sub get_body { 
    my ($class, $obj) = @_; 
    $obj->body();
}

sub set_header { 
    my ($class, $obj, $header, @data) = @_; 
    $obj->header_set($header, @data); 
}

sub set_body   {
    my ($class, $obj, $body) = @_; 
    $obj->body_set($body); 
}

sub as_string { 
    my ($class, $obj) = @_; 
    $obj->as_string();
}

sub stream_to {
  my ($class, $obj, $fh) = @_;

  if (eval { $obj->can('stream_to') }) {
    $obj->stream_to($fh);
  } else {
    $fh->print($obj->as_string);
  }
}

1;

=head1 NAME

Email::Abstract::Adapter::Email::Simple - adapter for Email::Simple

=head1 DESCRIPTION

This module wraps the Email::Simple mail handling library with an
abstract interface, to be used with L<Email::Abstract>

=head1 SEE ALSO

L<Email::Abstract>, L<Email::Simple>.

=cut

