#!/usr/bin/env perl
use ExtUtils::MakeMaker;
use version;

WriteMakefile(
    PREREQ_PM => {
        'Plack::Request' => 0.9974,
        'Text::Xslate'   => 0.1300,
        'File::ShareDir' => 1.03,
        'App::Uni'       => 8,
    }
);
