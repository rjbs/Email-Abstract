use 5.006;
use warnings;
use strict;
package Email::Abstract;
# ABSTRACT: unified interface to mail representations

use Carp;
use Email::Simple;
use MRO::Compat;

use Module::Pluggable 1.5
  search_path => [__PACKAGE__],
  except      => 'Email::Abstract::Plugin',
  require     => 1;

use Scalar::Util ();

my @plugins = __PACKAGE__->plugins(); # Requires them.
my %adapter_for =
  map  { $_->target => $_ }
  grep {
    my $avail = eval { $_->is_available };
    $@ ? ($@ =~ /Can't locate object method "is_available"/) : $avail;
  }
  @plugins;

sub object {
  my ($self) = @_;
  return unless ref $self;
  return $self->[0];
}

sub new {
  my ($class, $foreign) = @_;

  return $foreign if eval { $foreign->isa($class) };

  $foreign = Email::Simple->new($foreign)
    unless Scalar::Util::blessed($foreign);

  my $adapter = $class->__class_for($foreign); # dies if none available
  return bless [ $foreign, $adapter ] => $class;
}

sub __class_for {
  my ($self, $foreign, $method, $skip_super) = @_;
  $method ||= 'handle';

  my $f_class = ref $foreign;
     $f_class = $foreign unless $f_class;

  return $f_class if ref $foreign and $f_class->isa($self);

  return $adapter_for{$f_class} if $adapter_for{$f_class};

  if (not $skip_super) {
    my @bases = @{ mro::get_linear_isa($f_class) };
    shift @bases;
    for my $base (@bases) {
      return $adapter_for{$base} if $adapter_for{$base};
    }
  }

  Carp::croak "Don't know how to $method $f_class";
}

sub _adapter_obj_and_args {
  my $self = shift;

  if (my $thing = $self->object) {
    return ($self->[1], $thing, @_);
  } else {
    my $thing   = shift;
    my $adapter = $self->__class_for(
      Scalar::Util::blessed($thing) ? $thing : 'Email::Simple'
    );
    return ($adapter, $thing, @_);
  }
}

for my $func (qw(get_header get_body set_header set_body as_string)) {
  no strict 'refs';
  *$func = sub {
    my $self = shift;
    my ($adapter, $thing, @args) = $self->_adapter_obj_and_args(@_);

    # In the event of Email::Abstract->get_body($email_abstract), convert
    # it into an object method call.
    $thing = $thing->object if eval { $thing->isa($self) };

    # I suppose we could work around this by leaving @_ intact and assigning to
    # it.  That seems ... not good. -- rjbs, 2007-07-18
    unless (Scalar::Util::blessed($thing)) {
      Carp::croak "can't alter string in place" if substr($func, 0, 3) eq 'set';
      $thing = Email::Simple->new(
        ref $thing ? \do{my$str=$$thing} : $thing
      );
    }

    return $adapter->$func($thing, @args);
  };
}

sub cast {
  my $self = shift;
  my ($from_adapter, $from, $to) = $self->_adapter_obj_and_args(@_);

  my $adapter = $self->__class_for($to, 'construct', 1);

  my $from_string = ref($from) ? $from_adapter->as_string($from) : $from;

  return $adapter->construct($from_string);
}

1;
__END__

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

  $rfc822 = $email->as_string;

  my $mail_message = $email->cast("Mail::Message");

=head1 DESCRIPTION

C<Email::Abstract> provides module writers with the ability to write
simple, representation-independent mail handling code. For instance, in the
cases of C<Mail::Thread> or C<Mail::ListDetector>, a key part of the code
involves reading the headers from a mail object. Where previously one would
either have to specify the mail class required, or to build a new object from
scratch, C<Email::Abstract> can be used to perform certain simple operations on
an object regardless of its underlying representation.

C<Email::Abstract> currently supports C<Mail::Internet>, C<MIME::Entity>,
C<Mail::Message>, C<Email::Simple>, C<Email::MIME>, and C<Courriel>.  Other
representations are encouraged to create their own C<Email::Abstract::*> class
by copying C<Email::Abstract::EmailSimple>.  All modules installed under the
C<Email::Abstract> hierarchy will be automatically picked up and used.

=head1 METHODS

All of these methods may be called either as object methods or as class
methods.  When called as class methods, the email object (of any class
supported by Email::Abstract) must be prepended to the list of arguments, like
so:

  my $return = Email::Abstract->method($message, @args);

This is provided primarily for backwards compatibility.

=head2 new

  my $email = Email::Abstract->new($message);

Given a message, either as a string or as an object for which an adapter is
installed, this method will return a Email::Abstract object wrapping the
message.

If the message is given as a string, it will be used to construct an object,
which will then be wrapped.

=head2 get_header

  my $header  = $email->get_header($header_name);

  my @headers = $email->get_header($header_name);

This returns the values for the given header.  In scalar context, it returns
the first value.

=head2 set_header

  $email->set_header($header => @values);

This sets the C<$header> header to the given one or more values.

=head2 get_body

  my $body = $email->get_body;

This returns the body as a string.

=head2 set_body

  $email->set_body($string);

This changes the body of the email to the given string.

B<WARNING!>  You probably don't want to call this method, despite what you may
think.  Email message bodies are complicated, and rely on things like content
type, encoding, and various MIME requirements.  If you call C<set_body> on a
message more complicated than a single-part seven-bit plain-text message, you
are likely to break something.  If you need to do this sort of thing, you
should probably use a specific message class from end to end.

This method is left in place for backwards compatibility.

=head2 as_string

  my $string = $email->as_string;

This returns the whole email as a decoded string.

=head2 cast

  my $mime_entity = $email->cast('MIME::Entity');

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

=cut
