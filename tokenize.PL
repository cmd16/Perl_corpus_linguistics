#!/Users/cat/perl
use strict;
use warnings;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);  # Note: Splitter.pm has been modified to not change case
use FreqDist;
use Keyword;
use Data::Dumper;

sub tokenize_dir {
    my ($dirname, $splitter) = @_;
    my $freq_dist_obj = FreqDist->new();  # TODO update definition
    opendir(DIR, $dirname) || warn "Could not open $dirname, $!\n";
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
    # if (! $case_sensitive) {
    #     print("lc\n");
    # }
    # else {
    #     print("original\n");
    # }
    my $current_freqdist = FreqDist->new();
    open(my $in, "<", $filename) || warn "Could not open tokenize $filename, $!\n";
    while(my $line = <$in>) {
        my $tokens = $splitter->words($line);
        foreach my $token (@$tokens) {
            if ($token eq "") {
                next;
            }
            if (! $case_sensitive) {
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
    open(my $in, "<$list_filename") || warn "Could not open list_filename, $!\n";
    my $freq_dist_obj = FreqDist->new();  # TODO update definition
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
sub find_prototypical {
    my (%args) = @_;
    my $comp_freqdist = $args{comp_freqdist} // die "No comparison freqdist provided";
    my $source_dir = $args{source_dir} // ".";
    my $idlist = $args{idlist} // die "No idlist provided";
    my $outfilename = $args{outfilename} // "$source_dir/prototypical.txt";
    my $n = $args{n} // 0;  # 0 means get everything
    my $extension = $args{extension} // "";
    my $case_sensitive = $args{case_sensitive} // 0;
    my $splitter = $args{splitter} // die "No splitter provided!";
    my $use_wordlist = $args{use_wordlist} // 0;
    my $verbose = $args{verbose} // 0;

    my %file_data = {};

    my $keyword_obj = Keyword->new(freqdist1 => $comp_freqdist);

    open(my $in, "<$idlist") || warn "Could not open $idlist, $!\n";
    while(my $line = <$in>) {
        chomp($line);
        if ($verbose) {
            print("$line wordlist ");
        }
        my $filename = "$source_dir/$line$extension";

        my $current_freqdist = FreqDist->new();
        if ($use_wordlist) {
            $current_freqdist->open_from_txt($filename);
        }
        else {
            $current_freqdist = tokenize_file($filename, $splitter, $case_sensitive);
        }

        my $sum = 0;

        if ($verbose) {
            print("keywords\n");
        }
        $keyword_obj->set_freqdist2($current_freqdist);
        $keyword_obj->keyword_analysis(0);  # p value of 0

        foreach my $token ($keyword_obj->get_tokens()) {
            $sum += $keyword_obj->get_token_keyness($token);
        }

        $keyword_obj->swap_freqdists();
        $keyword_obj->keyword_analysis(0);  # p value of 0

        foreach my $token ($keyword_obj->get_tokens()) {
            $sum += $keyword_obj->get_token_keyness($token);
        }

        $file_data{$filename} = $sum;
    }
    close $in;

    my $out;
    my $success = open($out, ">", $outfilename);
    if (! $success) {
        warn "Couldn't open $outfilename, $!\n";
        return -1;
    }

    my $i = 0;
    if ($n == 0 or $n >= keys %file_data) {
        $n = keys %file_data;  # TODO: see if this works
    }

    if ($verbose) {
        print("sort and print results\n");
        # print(Dumper(\%file_data));
    }

    foreach my $key (keys %file_data) {
        if (! defined $file_data{$key}) {
            print("$key\n");
            delete $file_data{$key};
        }
        # print "$key\n";
        # printf "%s\t%f\n", $key, $file_data{$key};
    }

    foreach my $key (sort { $file_data{$a} <=> $file_data{$b} } keys %file_data) {
        last if ($i == $n);
        printf $out "%s\t%f\n", $key, $file_data{$key};
        $i += 1;
    }
    close $out;
}

return 1;
