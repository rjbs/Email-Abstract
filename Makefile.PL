require 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my $have_mime_entity = eval { require MIME::Entity; 1; };
my $mime_entity_okay = eval { MIME::Entity->VERSION(5.501); 1 };

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
    (($have_mime_entity and ! $mime_entity_okay)
      ? ('MIME::Entity' => '5.501')
      : ()),
  },
);
