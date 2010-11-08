require 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME              => 'Email::Abstract',
  VERSION_FROM      => 'lib/Email/Abstract.pm', # finds $VERSION
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM     => {
    'MRO::Compat',      => 0,      # minimum unknown
    'Email::Simple'     => '1.91', # avoid undef body
    'Module::Pluggable' => '1.5',
    'Test::More'        => '0.47',
    'Scalar::Util'      => 0,      # minimum unknown
  },
);
