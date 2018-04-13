#!/Users/cat/perl
use strict;
use warnings;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
require "./Tokenize.PL";

my $start;
my $dir_time;
my $word_out_time;
my $freq_dist_obj;
my $splitter = new Lingua::EN::Splitter;
my $proj_dir = "/Volumes/2TB/Final_project";
my $fanfic_list_dir = "$proj_dir/Fanfic lists";
my $fanfic_dir = "$proj_dir/Fanfic_all";
my $wordlist_dir = "$proj_dir/wordlists";
opendir(DH, $fanfic_list_dir) or die "opendir() failed: $!";
my @files = readdir(DH);
closedir(DH);

foreach my $id_name (@files) {
    # next if ($id_name =~ /^.+$/);
    if ($id_name eq "." or $id_name eq ".." or $id_name eq ".DS_Store"
        or $id_name eq "BBC Sherlock.txt") {
            print "skipping $id_name\n";
            next;
    }
    $freq_dist_obj = tokenize_from_idlist("$fanfic_list_dir/$id_name",
        $fanfic_dir, $splitter);
    $dir_time = time - $start;
    print "Run time to get $id_name: $dir_time\n";
    $start = time;
    $freq_dist_obj->out_to_txt("$wordlist_dir/perl_$id_name");  # TODO: change filename later
    $word_out_time = time - $start;
    print "Run time to write $id_name: $word_out_time\n";
}
