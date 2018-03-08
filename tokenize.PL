#!/Users/cat/perl
use strict;
use warnings;
use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;

my $dirname = '/Volumes/2TB/Final_project/Fanfic_all';
my $splitter = new Lingua::EN::Splitter;
my $freq_dist_obj = FreqDist->new();  # TODO update definition
my $current_freq_dist = FreqDist->new();  # TODO update definition

opendir(DIR, $dirname) or die "Could not open $dirname\n";
while ($filename = readdir(DIR)) {
    if (-f $filename) {
        open(my $in, "<", $dirname . "/" . $filename);
        while($line = <$in>) {
            my $tokens = $splitter->words($line);
            foreach my $token (@$tokens) {
                $current_freq_dist->add_token($token);
            }
        }
        close $in;
        $freq_dist_obj->update($current_freq_dist);
    }
}
closedir(DIR);
$freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/Results/all_wordlist.txt");
