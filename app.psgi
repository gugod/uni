#!/usr/bin/env perl
use v5.36;
use utf8;
use charnames ':full';

use App::Uni;
use Plack::Request;
use Plack::Response;
use Text::Xslate;

sub uni ($query) {
    my $chars = App::Uni::chars_by_name([$query], { match_codepoints => 1 });
    return map { charinfo($_) } @$chars;
}

sub charinfo ($char) {
    my $code = ord($char);
    my $name = charnames::viacode($code);
    return [$code, $char, $name];
}

sub {
    my $env = shift;

    my $request = Plack::Request->new($env);

    my $q = $request->param("q");
    utf8::decode($q) if defined $q;

    my $characters = [ $q ? uni($q) : () ];

    my $response = Plack::Response->new(200);

    my $tx = Text::Xslate->new( path => "views" );
    my $body = $tx->render("index.tx", { q => $q, characters => $characters });

    utf8::encode($body);
    $response->body($body);

    return $response->finalize;
};

