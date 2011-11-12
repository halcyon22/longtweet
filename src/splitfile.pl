#!/usr/bin/perl -w

use warnings;
use strict;
use File::Path;
use File::Slurp;

if (!$ARGV[0]) {
	die <<USAGE;
Usage $0 <filename>
	filename: file to split into .tweet files
USAGE
}

my $filename = shift(@ARGV);
$filename =~ /^(.+)\..*$/;
my $prefix = $1 or die "Couldn't parse $filename\n";
my $outfiletmpl = $prefix."___NUM__.tweet";

print "filename=$filename\n";

open(INPUT, $filename) or die "Couldn't open $filename: $!\n";

my $characters = "";
my $outfilecount = 0;
while (<INPUT>) {
	my $line = $_;
	chomp($line);

	print "$line\n";

	my @words = split(/\s+/, $line);

	while (@words and length($characters) < 140) {
		my $prev = $characters;
		my $word = shift(@words);

		$characters .= "$word ";

		print "$characters >>".length($characters)."\n";

		if (length($characters) >= 140) {
			$characters = $prev;
			unshift(@words, $word);

			$outfilecount = tofile($characters, $outfiletmpl, $outfilecount);

			$characters = "";
		}
	}

	print "after\n";

	if ($characters) {
		$outfilecount = tofile($characters, $outfiletmpl, $outfilecount);
	}

	$characters = "";
}

close(INPUT);

sub tofile {
	my ($content, $tmpl, $count) = @_;
	$tmpl =~ s/__NUM__/$count/;

	print "Writing $tmpl\n$content\n";

	write_file($tmpl, "$content\n\n\n")
		or die "Couldn't write $tmpl: $!\n";

	return ++$count;
}

