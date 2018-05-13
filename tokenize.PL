#!/Users/cat/perl
use strict;
use warnings;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;

sub tokenize_dir {
    my ($dirname, $splitter) = @_;
    my $freq_dist_obj = new FreqDist;  # TODO update definition
    opendir(DIR, $dirname) or warn "Could not open $dirname, $!\n";
    while (my $filename = readdir(DIR)) {
        if (-f $filename) {  # is this enough to avoid .DS_Store ?
            # print "processing {$filename}";
            my $current_freqdist = tokenize_file("$dirname/$filename", $splitter);
            $freq_dist_obj->update($current_freqdist);
        }
    }
    closedir(DIR);
    return $freq_dist_obj;
}

sub tokenize_file {
    my ($filename, $splitter, $case_sensitive) = @_;
    my $current_freqdist = new FreqDist();
    open(my $in, "<", $filename) or warn "Could not open tokenize $filename, $!\n";
    while(my $line = <$in>) {
        my $tokens = $splitter->words($line);
        foreach my $token (@$tokens) {
            if ($token eq "") {
                next;
            }
            if (!($case_sensitive)) {
                $token = lc $token;
            }
            $current_freqdist->add_token($token);
            # condition not needed; changed token def if $token =~ /^[a-zA-Z']+$/;  # add the token unless it contains a non-alpha character
        }
    }
    close $in;
    return $current_freqdist;
}

sub tokenize_from_idlist {
    my ($list_filename, $path, $splitter, $case_sensitive) = @_;
    open(my $in, "<$list_filename") or warn "Could not open list_filename, $!\n";
    my $freq_dist_obj = new FreqDist;  # TODO update definition
    while(my $line = <$in>) {
        chomp($line);
        my $filename = "$path/$line.txt";
        # print($filename, "\n");
        my $current_freqdist = tokenize_file($filename, $splitter, $case_sensitive);
        $freq_dist_obj->update($current_freqdist);
    }
    close $in;
    return $freq_dist_obj;
}

# TODO: modify to work with list of filenames
# sub find_prototypical {
#     my (%args) = @_;
#     my $comp_freqdist = $args{comp_freqdist} or die "No comparison freqdist provided";
#     my $source_dir = $args{source_dir} or ".";
#     my $idlist = $args{idlist} or die "No idlist provided";
#     my $outfilename = $args{outfilename} or "$source_dir/prototypical.txt";
#     my $n = $args{n} or 10;
#     my $extension = $args{extension} or "";
#     my $case_sensitive = $args{case_sensitive} or 0;
#     my $splitter = $args{splitter} or die "No splitter provided!";
#
#     my %file_data = {};
#
#     open(my $in, "<$idlist") or warn "Could not open $idlist, $!\n";
#     while(my $line = <$in>) {
#         chomp($line);
#         my $filename = "$source_dir/$line$extension";
#         my $current_freqdist = tokenize_file($filename, $splitter, $case_sensitive);
#         my $sum = 0;
#
#         my $this_hash = $comp_freqdist->keyword_analysis($current_freqdist, 0);
#         foreach my $value (values %{$this_hash}) {
#             $sum += $value{'keyness'};
#         }
#
#         $this_hash = $current_freqdist->keyword_analysis($comp_freqdist, 0);
#         foreach my $value (values %{$this_hash}) {
#             $sum += $value{'keyness'};
#         }
#
#         $file_data{$filename} = $sum;
#     }
#     close $in;
#
#     open(my $out, ">", $outfilename) or die "Couldn't open $outfilename, $!";
#     my $i = 0;
#     foreach my $key (sort { %file_data{$a} <=> %file_data{$b} } keys %file_data) {
#         last if ($i == $n);
#         printf $out "%s\t%f", $key, %file_data{$key};
#         $i += 1;
#     }
#     close $out;
# }

return 1;
