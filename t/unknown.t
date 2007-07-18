use strict;

use Test::More;

plan tests => 2;

use_ok("Email::Abstract");

my $object = bless [] => "Totally::Unknown";

my $abs = eval { Email::Abstract->new($object); };

like($@, qr/handle/, "exception on unknown object type");
