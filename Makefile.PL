use 5.006;
use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME              => 'Email::Abstract',
  VERSION_FROM      => 'lib/Email/Abstract.pm', # finds $VERSION
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    'Class::ISA'        => '0.20', # first release
    'Email::Simple'     => '1.91', # avoid undef body
    'Module::Pluggable' => '1.5',
    'Test::More'        => '0.47',
  },
);
