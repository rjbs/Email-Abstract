#!perl -T
use strict;

use Test::More;

use lib 't/lib';
use Test::EmailAbstract;

my @classes
  = qw(Email::MIME Email::Simple MIME::Entity Mail::Internet Mail::Message);

plan tests => 2
            + (@classes + 2) * Test::EmailAbstract->tests_per_obj
            + 1;

use_ok("Email::Abstract");

my $message = do { local $/; <DATA>; };

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
    eval "require $class";
    skip "$class can't be loaded", $tester->tests_per_obj if $@;

    my $obj = Email::Abstract->cast($message, $class);

    my $email_abs = Email::Abstract->new($obj);

    $tester->wrapped_ok($class, $email_abs, 0);
  }
}

{
  my $email_abs = Email::Abstract->new($message);
  $tester->wrapped_ok('plaintext', $email_abs, 0);
}

{
  # Ensure that we can use Email::Abstract->header($abstract, 'foo')
  my $email_abs = Email::Abstract->new($message);
  $tester->class_ok('plaintext (via class)', $email_abs, 0);

  my $email_abs_new = Email::Abstract->new($email_abs);
  ok(
    $email_abs == $email_abs_new,
    "trying to wrap a wrapper returns the wrapper; it doesn't re-wrap",
  );
}

__DATA__
Received: from mailman.opengroup.org ([192.153.166.9])
	by deep-dark-truthful-mirror.pad with smtp (Exim 3.36 #1 (Debian))
	id 18Buh5-0006Zr-00
	for <posix@simon-cozens.org>; Wed, 13 Nov 2002 10:24:23 +0000
Received: (qmail 1679 invoked by uid 503); 13 Nov 2002 10:10:49 -0000
Resent-Date: 13 Nov 2002 10:10:49 -0000
Date: Wed, 13 Nov 2002 10:06:51 GMT
From: Andrew Josey <ajosey@rdg.opengroup.org>
Message-Id: <1021113100650.ZM12997@skye.rdg.opengroup.org>
In-Reply-To: Joanna Farley's message as of Nov 13,  9:56am.
References: <200211120937.JAA28130@xoneweb.opengroup.org> 
	<1021112125524.ZM7503@skye.rdg.opengroup.org> 
	<3DD221BB.13116D47@sun.com>
X-Mailer: Z-Mail (5.0.0 30July97)
To: austin-group-l@opengroup.org
Subject: Re: Defect in XBD lround
MIME-Version: 1.0
Resent-Message-ID: <gZGK1B.A.uY.iUi09@mailman>
Resent-To: austin-group-l@opengroup.org
Resent-From: austin-group-l@opengroup.org
X-Mailing-List: austin-group-l:archive/latest/4823
X-Loop: austin-group-l@opengroup.org
Precedence: list
X-Spam-Status: No, hits=-1.6 required=5.0
Resent-Sender: austin-group-l-request@opengroup.org
Content-Type: text/plain; charset=us-ascii

Joanna, All

Thanks. I got the following response from Fred Tydeman.

On Nov 13,  9:56am in "Re: Defect in XBD lr", Joanna Farley wrote:
> Sun's expert in this area after some discussions with a colleague
> outside of Sun concluded that for lround, to align with both C99 and SUS
> changes of the following form were necessary:
> this line of text is really long and no one need worry about it but why was such a long text chosen to begin with i mean really??

-----
Andrew Josey                                The Open Group  
Austin Group Chair                          Apex Plaza,Forbury Road,
Email: a.josey@opengroup.org                Reading,Berks.RG1 1AX,England
Tel:   +44 118 9508311 ext 2250             Fax: +44 118 9500110
