#!/usr/bin/perl -w

use warnings;
use strict;
use File::Slurp;
use File::HomeDir;
use Net::Twitter::Lite;

if (!$ARGV[0]) {
	die <<USAGE;
Usage $0 <directory>
	directory: path to look for tweet files
USAGE
}

my $srcdir = shift(@ARGV);

opendir(DIR, $srcdir)
	or die "$! \"$srcdir\"";

# list files sorted by numbers just before the .tweet extension
my @files = 
	map { $_->[1] }
	sort { $a->[0] <=> $b->[0] } 
	map {/(\d*?)\.tweet/; [$1, $_] }
	grep { /\.tweet$/ && -f "$srcdir/$_" } 
	readdir(DIR);

closedir(DIR);

my $firstfile = shift(@files);
my $tweet = File::Slurp::read_file("$srcdir/$firstfile");

print "tweeting $firstfile:\n$tweet\n";


my $homedir = File::HomeDir->my_home;
my $consumer_key = File::Slurp::read_file($homedir."/.twitter/consumer_key");
my $consumer_secret = File::Slurp::read_file($homedir."/.twitter/consumer_secret");
my $access_token = File::Slurp::read_file($homedir."/.twitter/access_token");
my $access_token_secret = File::Slurp::read_file($homedir."/.twitter/access_token_secret");

my $twitter = Net::Twitter::Lite->new(
	consumer_key => $consumer_key,
	consumer_secret => $consumer_secret,
	access_token => $access_token,
	access_token_secret => $access_token_secret
);

eval {
	$twitter->update($tweet)
};
if ($@) {
	warn "Update failed: $@\n";
}
else {
	# move $firstfile somewhere else
}
