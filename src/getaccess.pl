#!/usr/bin/perl
#
# Based on the Net::Twitter::Lite OAuth desktop app example
#
use warnings;
use strict;

use File::Slurp;
use File::HomeDir;
use Net::Twitter::Lite;
use File::Spec;
use Data::Dumper;

# register an app to get a consumer key and consumer secret
my $homedir = File::HomeDir->my_home;
my $consumer_key = File::Slurp::read_file("$homedir/.twitter/consumer_keys");
my $consumer_secret = File::Slurp::read_file("$homedir/.twitter/consumer_secrets");

my $nt = Net::Twitter::Lite->new(
    consumer_key    => $consumer_key,
    consumer_secret => $consumer_secret
);

my $auth_url = $nt->get_authorization_url;
print "Authorize this application at: $auth_url\nThen, enter the PIN# provided to continue: ";

my $pin = <STDIN>;
chomp $pin;

# request_access_token stores the tokens in $nt AND returns them
my ($access_token, $access_token_secret, undef, undef) = $nt->request_access_token(verifier => $pin);

print "To use with tweetfirst.pl, store the following in $homedir/.twitter/\n";
print "access_token: $access_token\naccess_token_secret: $access_token_secret\n";
