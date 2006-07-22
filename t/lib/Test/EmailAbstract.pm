use strict;
use warnings;

package Test::EmailAbstract;
use Test::More;

sub _call {
  my ($wrapped, $object, $method, @args) = @_;

  if ($wrapped) {
    return $object->$method(@args);
  } else {
    return Email::Abstract->$method($object, @args);
  }
}

sub _test_object {
    my ($wrapped, $class, $obj, $readonly) = @_;

    like(
      _call($wrapped, $obj, 'get_header', 'Subject'),
      qr/Re: Defect in XBD lround/,
      "Subject OK with $class"
    );

    like(
      _call($wrapped, $obj, 'get_body'),
      qr/Fred Tydeman/,
      "Body OK with $class"
    );

    eval {
      _call($wrapped, $obj, set_header =>
        "Subject",
        "New Subject"
      );
    };

    if ($readonly) {
      like($@, qr/can't alter string/, "can't alter an unwrapped string");
    } else {
      ok(!$@, "no exception on altering object via Email::Abstract");
    }

    eval {
      _call($wrapped, $obj, set_body =>
        "A completely new body"
      );
    };

    if ($readonly) {
      like($@, qr/can't alter string/, "can't alter an unwrapped string");
    } else {
      ok(!$@, "no exception on altering object via Email::Abstract");
    }

    if ($readonly) {
      pass("(no test; can't check altering unalterable alteration)");
    } else {
      like(
        _call($wrapped, $obj, 'as_string'),
        qr/Subject: New Subject.*completely new body$/ms, 
        "set subject and body, restringified ok with $class"
      );
    }
}

sub class_ok   { _test_object(0, @_); }
sub wrapped_ok { _test_object(1, @_); }


1;
