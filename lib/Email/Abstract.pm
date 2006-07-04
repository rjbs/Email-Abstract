package Email::Abstract;
use Carp;
use Email::Simple;
use 5.006;
use strict;
use warnings;
our $VERSION = '2.01';
use Module::Pluggable search_path => [ __PACKAGE__ ], require => 1;
my @plugins = __PACKAGE__->plugins(); # Requires them.
for my $func (qw(get_header get_body 
                 set_header set_body 
                 as_string)) {
    no strict 'refs';
    *$func  = sub { 
        my ($class, $thing, @args) = @_;
        $thing = Email::Simple->new($thing) unless ref $thing;
        my $target = ref $thing;
        $target =~ s/:://g;
        $class .= "::".$target;
        if ($class->can($func)) {
            $class->$func($thing, @args);
        } else {
            for my $class (@plugins) { 
                if ($class->can("target") and $thing->isa($class->target)) {
                    return $class->$func($thing, @args);
                }
            }
            croak "Don't know how to handle ".ref($thing);
        }
    };
}

sub cast {
    my ($class, $thing, $target) = @_;
    $thing = $class->as_string($thing) if ref $thing;
    $target =~ s/:://g;
    $class .= "::".$target;
    if ($class->can("construct")) {
        $class->construct($thing);
    } else {
        for my $class (@plugins) { 
            if ($class->can("target") and $thing->isa($class->target)) {
                return $class->construct($thing);
            }
        }
        croak "Don't know how to handle $class";
    }
}

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Email::Abstract - Unified interface to mail representations

=head1 SYNOPSIS

  my $message = Mail::Message->read($rfc822)
                || Email::Simple->new($rfc822)
                || Mail::Internet->new([split /\n/, $rfc822])
                || ...;

  my $subject = Email::Abstract->get_header($message, "Subject");
  Email::Abstract->set_header($message, "Subject", "My new subject");

  my $body = Email::Abstract->get_body($message);
  Email::Abstract->set_body($message, "Hello\nTest message\n");

  $rfc822 = Email::Abstract->as_string($message);

  my $mail_message = Email::Abstract->cast($message, "Mail::Message");

=head1 DESCRIPTION

C<Email::Abstract> provides module writers with the ability to write
representation-independent mail handling code. For instance, in the
cases of C<Mail::Thread> or C<Mail::ListDetector>, a key part of the
code involves reading the headers from a mail object. Where previously
one would either have to specify the mail class required, or to build a
new object from scratch, C<Email::Abstract> can be used to perform
certain simple operations on an object regardless of its underlying
representation.

C<Email::Abstract> currently supports C<Mail::Internet>,
C<MIME::Entity>, C<Mail::Message>, C<Email::Simple> and C<Email::MIME>.
Other representations are encouraged to create their own
C<Email::Abstract::*> class by copying C<Email::Abstract::EmailSimple>.
All modules installed under the C<Email::Abstract> hierarchy will be
automatically picked up and used.

=head1 METHODS

=head2 get_header($obj, $header)

This returns the value or list of values of the given header.

=head2 set_header($obj, $header, @lines)

This sets the C<$header> header to the given one or more values.

=head2 get_body($obj)

This returns the body as a string.

=head2 set_body($obj, $string)

This changes the body of the email to the given string.

=head2 as_string($obj)

This returns the whole email as a string.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>

Simon Cozens, <F<simon@cpan.org>>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Simon Cozens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 SEE ALSO

http://pep.kwiki.org

=cut
