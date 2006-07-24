package Email::Abstract;
use Carp;
use Email::Simple;
use 5.006;
use strict;
use warnings;
our $VERSION = '2.12';
use Module::Pluggable search_path => [ __PACKAGE__ ], require => 1;

my @plugins = __PACKAGE__->plugins(); # Requires them.
my %adapter_for = map { $_->target => $_ } @plugins;

sub object {
    my ($self) = @_;
    return unless ref $self;
    return $$self;
}

sub new {
    my ($class, $foreign) = @_;

    $class = ref($class) || $class;

    $foreign = Email::Simple->new($foreign) unless ref $foreign;

    if (
      $adapter_for{ref $foreign} or grep { $foreign->isa($_) } keys %adapter_for
    ) {
      return bless \$foreign => $class;
    }

    croak "Don't know how to handle " . ref $foreign;
}

sub __class_for {
    my ($self, $foreign, $method) = @_;

    my $f_class = ref($foreign) || $foreign;

    return $adapter_for{ $f_class } if exists $adapter_for{ $f_class };

    require Class::ISA;
    for my $base (Class::ISA::super_path($f_class)) {
        return $adapter_for{ $base } if exists $adapter_for{ $base }
    }

    croak "Don't know how to handle " . $f_class;
}

sub _obj_and_args {
  my $self = shift;

  return @_ unless my $thing = $self->object;
  return ($thing, @_);
}

for my $func (qw(get_header get_body set_header set_body as_string)) {
    no strict 'refs';
    *$func  = sub { 
        my $self = shift;
        my ($thing, @args) = $self->_obj_and_args(@_);

        unless (ref $thing) {
            croak "can't alter string in place" if substr($func, 0, 3) eq 'set';
            $thing = Email::Simple->new($thing)
        }

        my $class = $self->__class_for($thing, $func);
        return $class->$func($thing, @args);
    };
}

sub cast {
    my $self = shift;
    my ($from, $to) = $self->_obj_and_args(@_);

    croak "Don't know how to construct $to objects"
      unless $adapter_for{ $to } and $adapter_for{ $to }->can('construct');

    my $from_string = ref($from) ? $self->as_string($from) : $from;

    return $adapter_for{ $to }->construct($from_string);
}

# Preloaded methods go here.

1;
__END__

=head1 NAME

Email::Abstract - unified interface to mail representations

=head1 SYNOPSIS

  my $message = Mail::Message->read($rfc822)
             || Email::Simple->new($rfc822)
             || Mail::Internet->new([split /\n/, $rfc822])
             || ...
             || $rfc822;

  my $email = Email::Abstract->new($message);

  my $subject = $email->get_header("Subject");
  $email->set_header(Subject => "My new subject");

  my $body = $email->get_body;
  $email->set_body("Hello\nTest message\n");

  $rfc822 = $email->as_string;

  my $mail_message = $email->cast("Mail::Message");

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

All of these methods may be called either as object methods or as class
methods.  When called as class methods, the email object (of any class
supported by Email::Abstract) must be prepended to the list of arguments.

=head2 new

  my $email = Email::Abstract->new($message);

Given a message, either as a string or as an object for which an adapter is
installed, this method will return a Email::Abstract object wrapping the
message.

If the message is given as a string, it will be used to construct an object,
which will then be wrapped.

=head2 get_header

  my $header  = $email->get_header($header_name);
  my $header  = Email::Abstract->get_header($message, $header_name);

  my @headers = $email->get_header($header_name);
  my @headers = Email::Abstract->get_header($message, $header_name);

This returns the value or list of values of the given header.

=head2 set_header

  $email->set_header($header => @lines);
  Email::Abstract->set_header($message, $header => @lines);

This sets the C<$header> header to the given one or more values.

=head2 get_body

  my $body = $email->get_body;

  my $body = Email::Abstract->get_body($message);

This returns the body as a string.

=head2 set_body

  $email->set_body($string);

  Email::Abstract->set_body($message, $string);

This changes the body of the email to the given string.

=head2 as_string

  my $string = $email->as_string;

  my $string = Email::Abstract->as_string($message);

This returns the whole email as a string.

=head2 cast

  my $mime_entity = $email->cast('MIME::Entity');
  my $mime_entity = Email::Abstract->cast($message, 'MIME::Entity');

This method will convert a message from one message class to another.  It will
throw an exception if no adapter for the target class is known, or if the
adapter does not provide a C<construct> method.

=head2 object

  my $message = $email->object;

This method returns the message object wrapped by Email::Abstract.  If called
as a class method, it returns false.

Note that, because strings are converted to message objects before wrapping,
this method will return an object when the Email::Abstract was constructed from
a string. 

=head1 PERL EMAIL PROJECT

This module is maintained by the Perl Email Project

  L<http://emailproject.perl.org/wiki/Email::Abstract>

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>

Simon Cozens, <F<simon@cpan.org>>

Ricardo SIGNES, <F<rjbs@cpan.org>>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Simon Cozens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
