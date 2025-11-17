#!perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Business::NAB',
    VERSION_FROM     => 'lib/Business/NAB.pm',
    AUTHOR           => 'Lee Johnson <leejo@cpan.org>',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => '5.32.0',
    PREREQ_PM => {
        'Carp'                         => 0,
        'DateTime'                     => 0,
        'DateTime::Format::DateParse'  => 0.05,
        'Exporter::Easy'               => 0.18,
        'File::Temp'                   => 0,
        'List::Util'                   => 0,
        'Module::Load'                 => 0.34,
        'Moose'                        => 2.2012,
        'Moose::Role'                  => 2.2012,
        'Moose::Util::TypeConstraints' => 2.2012,
        'Text::CSV_XS'                 => 0,
        'Types::Standard'              => 2.006000,
        'XML::LibXML'                  => 0,
    },
    BUILD_REQUIRES => {
        'Test::File::Contents' => 0,
        'Test::Most'       => 0.31,
        'Test::Warnings'   => 0.030,
    },
    META_MERGE => {
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            homepage   => 'https://metacpan.org/module/Business::NAB',
            bugtracker => 'https://github.com/payprop/business-nab/issues',
            repository => 'https://github.com/payprop/business-nab'
        },
    },
    test => {
        RECURSIVE_TEST_FILES => 1,
    },
);
