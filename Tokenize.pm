#!/Users/cat/perl
use strict;
use warnings;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
package Tokenize;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub tokenize_dir {
    my ($self, $dirname, $splitter) = @_;
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
    my ($self, $filename, $splitter) = @_;
    my $current_freq_dist = new FreqDist();
    open(my $in, "<", $filename) or die "Could not open $filename, $!\n";
    while(my $line = <$in>) {
        my $tokens = $splitter->words($line);
        foreach my $token (@$tokens) {
            $current_freq_dist->add_token($token) if $token =~ /^[a-zA-Z']+$/;  # add the token unless it contains a non-alpha character
        }
    }
    close $in;
    return $current_freq_dist;
}

sub tokenize_from_idlist {
    my ($self, $list_filename, $path, $splitter) = @_;
    print $list_filename;
    open(my $in, "<", $list_filename) or die "Could not open list_filename, $!\n";
    my $freq_dist_obj = new FreqDist;  # TODO update definition
    while(my $line = <$in>) {
        my $id = $line.chomp();
        $id = $id.chomp();
        my $filename = $path . "/" . $id . ".txt";
        my $current_freq_dist = tokenize_file($filename, $splitter);
        $freq_dist_obj->update($current_freq_dist);
    }
    close $in;
    return $freq_dist_obj;
}

return 1;
