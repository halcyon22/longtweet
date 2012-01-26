#!/usr/bin/perl -w

# no tweet will span lines;
# the input should be one line per paragraph

use warnings;
use strict;
use File::Path;
use File::Slurp;
use Digest::MD5 qw(md5);

use constant MAXLEN => 140;
use constant MINLEN => 70;
use constant DISTANCE_FROM_PREVIOUS => 144;

if (!$ARGV[0]) {
	die <<USAGE;
Usage $0 <filename>
	filename: file to split into .tweet files
USAGE
}

my $filename = shift(@ARGV);
$filename =~ /^(.+)\..*$/;
my $prefix = $1 
	or die "Couldn't parse $filename\n";
my $outfiletmpl = $prefix."___NUM__.tweet";
my $checksums = {};

open(INPUT, $filename) 
	or die "Couldn't open $filename: $!\n";

my $characters = "";
my $outfilecount = 0;
while (<INPUT>) {
	my $line = $_;
	chomp($line);

	my @words = split(/\s+/, $line);

	while (@words and length($characters) < MAXLEN) {
		my $prev = $characters;
		my $word = shift(@words);

		$characters .= "$word ";

		if (length($characters) >= MAXLEN) {
			$characters = $prev;
			unshift(@words, $word);

			# next tweet will be too short; even out the last two
			if (length(join(' ', @words)) < MINLEN) {

				$characters .= join(' ', @words);
				my $length = length($characters);
				@words = split(/\s+/, $characters);

				$characters = "";
				while (length($characters) <= ($length / 2)) {
					$characters .= shift(@words)." ";
				}

				# next to last tweet for this paragraph
				$outfilecount = tofile($characters, $outfiletmpl, $outfilecount, $checksums);
				$characters = "";

				while (@words) {
					$characters .= shift(@words)." ";
				}
			}

			# last tweet for this paragraph
			$outfilecount = tofile($characters, $outfiletmpl, $outfilecount, $checksums);
			$characters = ""; 
		}
	}

	if ($characters) {
		$outfilecount = tofile($characters, $outfiletmpl, $outfilecount, $checksums);
	}

	$characters = "";
}

close(INPUT);

sub tofile {
	my ($content, $tmpl, $count, $checksums) = @_;
	my $filename = $tmpl;
	$filename =~ s/__NUM__/$count/;

	#print "Writing $filename\n$content\n";

	write_file($filename, "$content\n\n\n")
		or die "Couldn't write $filename: $!\n";

	compareChecksum($filename, $checksums);

	return ++$count;
}

sub compareChecksum {
	my ($filename, $checksums) = @_;

        open(FILE, $filename)
                or die "Couldn't open $filename: $!\n";
        binmode(FILE);

        my $ctx = Digest::MD5->new;
        $ctx->addfile(*FILE);
        my $digest = $ctx->hexdigest();

        if (exists $checksums->{$digest}
			and checkDistance($filename, $checksums, $digest)) {
                print "$filename is a duplicate of ".$checksums->{$digest}." and within ".DISTANCE_FROM_PREVIOUS." tweets.\n";
        }

        $checksums->{$digest} = $filename;
}

sub checkDistance {
	my ($filename, $checksums, $digest) = @_;

	my $prev = $checksums->{$digest};
	$prev = getTweetNum($prev);

	my $curr = getTweetNum($filename);

	return ($curr - $prev) >= DISTANCE_FROM_PREVIOUS;
}

sub getTweetNum {
	my ($filename) = @_;

	$filename =~ /(\d+)\.tweet/;
	$filename = $1 or die "Couldn't parse $filename\n";

	return $filename;
}
