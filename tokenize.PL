#!/Users/cat/perl
use strict;
use warnings;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
use Tokenize;

my $proj_dir = '/Volumes/2TB/Final_project';
my $splitter = new Lingua::EN::Splitter;

# @names = readdir($proj_dir . "/Fanfic lists") or die "Unable to read current dir:$!\n";
my $ending = /.txt/;
foreach my $name (readdir($proj_dir . "/Fanfic lists")) {
    if ($name =~ $ending) {
        my $start = time;
        my $freq_dist_obj = tokenize_from_idlist($proj_dir . "/Fanfic lists/" . $name, $splitter);
        my $dir_time = time - $start;
        print "Run time to get {$name} wordlist: {$dir_time}";
        $start = time;
        $freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/{$name}_perl.txt");
        my $word_out_time = time - $start;
        print "Run time to write out {$name} wordlist: {$word_out_time}";
    }
}
