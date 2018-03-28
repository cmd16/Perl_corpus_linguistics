#!/Users/cat/perl
use strict;
use warnings;
use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;

my $proj_dirname = '/Volumes/2TB/Final_project/Fanfic_all';
my $splitter = new Lingua::EN::Splitter;

sub tokenize_dir {
    my ($dirname, $splitter) = @_;
    my $freq_dist_obj = new FreqDist;  # TODO update definition
    opendir(DIR, $dirname) or die "Could not open $dirname, $!\n";
    while (my $filename = readdir(DIR)) {
        if (-f $filename) {
            print "processing {$filename}";
            my $current_freq_dist = tokenize_file($dirname . "/" . $filename, $splitter);
            $freq_dist_obj->update($current_freq_dist);
        }
    }
    closedir(DIR);
    return $freq_dist_obj;
}

sub tokenize_file {
    my ($filename, $splitter) = @_;
    my $current_freq_dist = new FreqDist();
    open(my $in, "<", $filename) or die "Could not open $filename, $!\n";
    while(my $line = <$in>) {
        my $tokens = $splitter->words($line);
        foreach my $token (@$tokens) {
            $current_freq_dist->add_token($token) unless $token =~ /^[a-zA-Z]+$/;  # add the token unless it contains a non-alpha character
        }
    }
    close $in;
    return $current_freq_dist;
}

sub tokenize_from_list {
    my ($list_filename, $path, $splitter) = @_;
    open(my $in, "<", $list_filename) or die "Could not open $list_filename, $!\n";
    my $freq_dist_obj = new FreqDist;  # TODO update definition
    while(my $line = <$in>) {
        my $id = $line.chomp();
        my $filename = $path . "/" . $id . ".txt";
        my $current_freq_dist = tokenize_file($filename, $splitter);
        $freq_dist_obj->update($current_freq_dist);
    }
    close $in;
    return $freq_dist_obj;
}

my $proj_dir = "/Volumes/2TB/Final_project";
my $start = time;
my $freq_dist_obj = tokenize_from_list($proj_dir . "/Fanfic lists/Doctor Who drabbles.txt", $splitter);
my $dir_time = time - $start;
print "Run time to get Doctor Who drabbles wordlist: {$dir_time}";
$start = time;
$freq_dist_obj->out_to_txt("/Volumes/2TB/Final_project/wordlists/Doctor Who drabbles perl.txt");
my $word_out_time = time - $start;
print "Run time to write out Doctor Who drabbles wordlist: {$word_out_time}";

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
