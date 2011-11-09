#!/usr/bin/perl -w

use strict;

if (!$ARGV[0]) {
	die <<USAGE;
Usage $0 <directory>
	directory: directory from which the contents of the first file will be tweeted
USAGE
	#exit;
}

my $srcdir = shift(@ARGV);

opendir(DIR, $srcdir)
	or die $!;

my @files = grep {
	/\.tweet$/ && -f "$srcdir/$_"
	} readdir(DIR);

closedir(DIR);

foreach my $file (@files) {
	print "$file\n";
}

exit;
