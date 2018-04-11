#!/Users/cat/perl
use strict;
use warnings;
# use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
require "./Tokenize.PL";

my $splitter = new Lingua::EN::Splitter;
my $proj_dir = "/Volumes/2TB/Final_project";

my $start = time;
my $freq_dist_obj = tokenize_from_idlist($proj_dir . "/Fanfic lists/Doctor Who 1-100.txt",
    $proj_dir . "/Fanfic_all", $splitter);
my $dir_time = time - $start;
print "Run time to get Doctor Who 1-100 wordlist: {$dir_time}";
$start = time;
$freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/Doctor_Who_1-100_perl.txt");
my $word_out_time = time - $start;
print "Run time to write out Doctor Who 1-100 wordlist: {$word_out_time}";

$start = time;
$freq_dist_obj = tokenize_from_idlist($proj_dir . "/Fanfic lists/Les Mis 100001-500000.txt",
    $proj_dir . "/Fanfic_all", $splitter);
$dir_time = time - $start;
print "Run time to get Les Mis 100001-500000 wordlist: {$dir_time}";
$start = time;
$freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/Les_Mis_100001-500000_perl.txt");
$word_out_time = time - $start;
print "Run time to write out Les Mis 100001-500000 wordlist: {$word_out_time}";

$start = time;
$freq_dist_obj = tokenize_from_idlist($proj_dir . "/Fanfic lists/Undertale Gen.txt",
    $proj_dir . "/Fanfic_all", $splitter);
$dir_time = time - $start;
print "Run time to get Undertale Gen wordlist: {$dir_time}";
$start = time;
$freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/Undertale_Gen_perl.txt");
$word_out_time = time - $start;
print "Run time to write out Undertale Gen wordlist: {$word_out_time}";

# $start = time;
# $freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/fanfic_all_perl.txt");
# my $word_out_time = time - $start;
# print "Run time to write out wordlist: {$word_out_time}";

# my $dir_time = time - $start;
# my $freq_dist_obj = tokenize_dir($proj_dirname, $splitter);
# print "Run time to get wordlist: {$dir_time}";
# $start = time;
# $freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/fanfic_all_perl.txt");
# my $word_out_time = time - $start;
# print "Run time to write out wordlist: {$word_out_time}";
