#!/Users/cat/perl
use strict;
use warnings;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
use Time::HiRes qw(time);
require "./Tokenize.PL";

my $start;
my $dir_time;
my $word_out_time;
my $freq_dist_obj;
my $splitter = new Lingua::EN::Splitter;
$splitter->set_non_word_regexp("[^a-zA-Z]+");
my $proj_dir = "/Volumes/2TB/Final_project";
my $fanfic_list_dir = "$proj_dir/Fanfic lists";
my $fanfic_dir = "$proj_dir/Fanfic_all";
my $wordlist_dir = "$proj_dir/wordlists";
opendir(DH, $fanfic_list_dir) or die "opendir() failed: $!";
my @files = readdir(DH);
closedir(DH);

foreach my $id_name (@files) {
    # next if ($id_name =~ /^.+$/);
    if ($id_name eq "." or $id_name eq ".." or $id_name eq ".DS_Store") {
        print "skipping $id_name\n";
        next;
    }
    $start = time;
    $freq_dist_obj = tokenize_from_idlist("$fanfic_list_dir/$id_name",
        $fanfic_dir, $splitter);
    $dir_time = time - $start;
    printf "%s\t%.6f\n", $id_name, $dir_time;
    my $modified_str = $id_name =~ s/\s/_/gr;
    $modified_str =~ s/_to_/ to /g;
    $modified_str =~ s/\.txt/_perl.txt/g;
    $freq_dist_obj->out_to_txt("$wordlist_dir/${modified_str}");  # TODO: change filename later
}
