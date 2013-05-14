#!/usr/bin/env perl
# use v5.12.0;
use strict;
use warnings;
use utf8;
use charnames ':full';

use Plack::Request;
use Plack::Response;
use Text::Xslate;

my $str = require 'unicore/Name.pl';
open my $fh, '+<', \$str or die "Cannot open unicore data: $!$/";

sub uni {
    my $regex = join ' ', @_;
    utf8::decode($regex);

    my @ret;

    if (length $regex == 1 and ord($regex) >= 128) {
        push @ret, [ord($regex), $regex, charnames::viacode(ord $regex)];
        return @ret;
    }

    seek($fh,0,0);

    while (<$fh>) {
        chomp;
        (/$regex/i and /(.+)\t([^;]+)/) or next;

        my ($code, $name) = ($1, $2);
        ($name =~ /$regex/i or $code =~ /$regex/i) or next;

        next if $code =~ / /; # if we want to avoid named sequences
        $code =~ s/^0(....)/$1/;
        my $chr = join q{}, map {; chr hex } split /\s+/, $code;
        push @ret, [$code, $chr, $name];
    }

    return @ret;
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

