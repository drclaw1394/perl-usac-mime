use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'uSAC::MIME',
    VERSION_FROM      => 'lib/uSAC/MIME.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/uSAC/MIME.pm', # retrieve abstract from module
    AUTHOR            => 'Ruben Westerberg <drclaw@mac.com>',
    LICENSE           => 'mit'
);
