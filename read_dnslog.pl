#vim:ts=4
#!/usr/bin/env perl 
#===============================================================================
#         FILE: read_dnslog.pl
#        USAGE: ./read_dnslog.pl  
#  DESCRIPTION: Read, parse, and show dns queries from dnsmasq log file
# REQUIREMENTS: File::Slurp List::MoreUtils List::Compare
#       AUTHOR: 163140@autistici.org
#      VERSION: 0.0
#      CREATED: 27.07.2016 20:44:02
#     REVISION: 0
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.020;
use File::Slurp;
use List::MoreUtils qw(uniq);
use List::Compare;

# patterns of whitelisted sites that i don't want to see in output.
my @white =	qw(
	github, debian, steam
);

my $log = read_file($ARGV[0]);
my $blocked_ads += () = $log =~ /to 127.0.0.1/g;
my $cached += () = $log =~ /cached/g;
my $total_dns += () = $log =~ /query/g;

$log =~ s/\w+?\s\d+\s\d+:\d+.*:\s//g;
my @log = grep /reply/, split /\n/, $log;
@log = map {/reply\sw?w?w?\.?(.*?)\sis\s.*/} @log;
@log = uniq @log;
my $comparator = List::Compare->new('-u', \@log, \@white);
@log = $comparator -> get_unique;
@log = map {(join(".", reverse /([^\.]+?)\./g) . "\t" . $_) unless $_~~@white} @log;

for (sort @log) {
		s/.*\t//;
		say
};
say "Cached queries: $cached, Blocked: $blocked_ads, Total: $total_dns";
