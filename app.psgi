#!/usr/bin/env perl
use v5.12.0;
use strict;
use warnings;
use utf8;

use Plack::Request;
use Plack::Response;
use Text::Xslate;

use File::ShareDir 'dist_dir';

{
    my $dir = dist_dir('App-Uni');
    my $file = "$dir/UnicodeData.txt";
    (-f $file and -r $file)
        or die "Cannot find UnicodeData.txt in $dir";

    sub uni {
        my $regex = join(' ', @_);

        if (length $regex == 1) {
            $regex = sprintf('(?:%s|%04X)', $regex, ord $regex);
        }

        my @ret;
        open my $fh, '<:mmap', $file;
        for (<$fh>) {
            if (/$regex/i and my ($code, $name) = /(\w+);([^;]+)/) {
                push @ret, [$code, chr hex $code, $name]
                    if [$name, $code] ~~ /$regex/i;
            }
        }
        close $fh;

        return @ret;
    }
}

sub {
    my $env = shift;

    my $request = Plack::Request->new($env);

    my $q = $request->param("q");
    utf8::decode($q);

    my $characters = [ $q ? uni($q) : () ];

    my $response = Plack::Response->new(200);

    my $tx = Text::Xslate->new( path => "views" );
    my $body = $tx->render("index.tx", { q => $q, characters => $characters });

    utf8::encode($body);
    $response->body($body);

    return $response->finalize;
};
