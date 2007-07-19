#!perl -T
use strict;

use Test::More;

use lib 't/lib';
use Test::EmailAbstract;

my @classes
  = qw(Email::MIME Email::Simple MIME::Entity Mail::Internet Mail::Message);

plan tests => 2
            + (@classes * 2 + 1) * Test::EmailAbstract->tests_per_object
            + (@classes + 2) * Test::EmailAbstract->tests_per_class
            + 1;

use_ok("Email::Abstract");

open FILE, '<t/example.msg';
my $message = do { local $/; <FILE>; };
close FILE;

# Let's be generous and start with real CRLF, no matter what stupid thing the
# VCS or archive tools have done to the message.
$message =~ s/\x0a\x0d|\x0d\x0a|\x0d|\x0a/\x0d\x0a/g;

my $tester = Test::EmailAbstract->new($message);

is(
  substr($message, -2, 2),
  "\x0d\x0a",
  "the message ends in a CRLF",
);

for my $class (@classes) {
  SKIP: {
    $tester->load($class);

    {
      my $obj = Email::Abstract->cast($message, $class);
      my $email_abs = Email::Abstract->new($obj);
      $tester->object_ok($class, $email_abs, 0);
    }

    {
      my $simple = Email::Simple->new($message);
      my $obj = Email::Abstract->cast($simple, $class);
      my $email_abs = Email::Abstract->new($obj);
      $tester->object_ok($class, $email_abs, 0);
    }

    {
      my $obj = Email::Abstract->cast($message, $class);
      $tester->class_ok($class, $obj, 0);
    }
  }
}

{
  my $email_abs = Email::Abstract->new($message);
  $tester->object_ok('plaintext',        $email_abs, 0);
  $tester->class_ok('plaintext (class)', $message,   1);
}

{
  my $email_abs = Email::Abstract->new($message);
  $tester->class_ok('Email::Abstract', $email_abs,   0);
}

{
  # Ensure that we can use Email::Abstract->header($abstract, 'foo')
  my $email_abs = Email::Abstract->new($message);

  my $email_abs_new = Email::Abstract->new($email_abs);
  ok(
    $email_abs == $email_abs_new,
    "trying to wrap a wrapper returns the wrapper; it doesn't re-wrap",
  );
}
