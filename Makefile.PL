use v5.14;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME             => 'perltris',
  VERSION_FROM     => 'lib/Meta.pm',
  ABSTRACT_FROM    => 'lib/Meta.pm',
  AUTHOR           => 'Evan Rose',
  LICENSE          => 'freebsd',
  MIN_PERL_VERSION => '5.02',
  EXE_FILES        => ['src/perltris'],
  PREREQ_PM        => {
    'strict'   => 0,
    'warnings' => 0,
    'Tk' => '804.034',
  },
  (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (META_MERGE => {
      'meta-spec' => { version => 2 },
      resources => {
          repository => {
              type => 'git',
              url  => 'https://github.com/evanandrewrose/perltris.git',
              web  => 'https://github.com/evanandrewrose/perltris',
          },
      }})
   : ()
  ),
);
