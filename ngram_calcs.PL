#!/Users/cat/perl
use strict;
use warnings;
# use Lingua::EN::Ngram;
use IPC::System::Simple qw(system capture);
use File::Basename;

my $proj_dir = "/Volumes/2TB/Final_project";
my $fanfic_dir = "$proj_dir/Fanfic_all";
my $fanfic_list_dir = "$proj_dir/Fanfic lists";
my $bigram_dir = "$proj_dir/Bigrams";

sub count_bigrams_from_idlist {
    my ($list_filename, $fanfic_dir, $dest_dir)  = @_;
    open(my $in, "<$list_filename") or die "Could not open list_filename, $!\n";
    my $short_filename = basename($list_filename, ".txt");
    print("$short_filename\n");
    my @filenames = ();
    while(my $line = <$in>) {
        chomp($line);
        my $filename = "$fanfic_dir/$line.txt";
        push(@filenames, $filename);
    }
    close $in;
    system($^X, "/Users/cat/perl5/bin/huge-count.pl", "--token=valid_tokens.txt",
    "--tokenlist", $dest_dir, @filenames);
    rename("$dest_dir/huge-count.pl", "$dest_dir/${short_filename}_count.txt");
}

opendir(DH, $fanfic_list_dir) or die "opendir($fanfic_list_dir) failed: $!";
my @idfiles = readdir(DH);
closedir(DH);
foreach my $idfilename (@idfiles) {
    chomp($idfilename);
    if ($idfilename =~ /.txt/) {
        count_bigrams_from_idlist("$fanfic_list_dir/$idfilename", $fanfic_dir,
        $bigram_dir);
    }
}

# system($^X, "/Users/cat/perl5/bin/huge-count.pl", "--token=valid_tokens.txt",
# "--tokenlist", "/Users/cat/CS214/bigrams", "/Users/cat/CS214/source_files");

# Run a command, wait until it finishes, and make sure it works.
# Output from this program goes directly to STDOUT, and it can take input
# from your STDIN if required.
# system($^X, "/Users/cat/perl5/bin/count.pl", "--token=valid_tokens.txt", "lab01_java_bigrams.cnt", $filename);
#
# # statistic.pl -score 6.00 -frequency 5 ll.pm holmes1.ll h.cnt
# system($^X, "/Users/cat/perl5/bin/statistic.pl", "--score=6.63", "ll.pm", "lab01_java_bigrams.ll", "/Users/cat/Perl_scripts/214_Final_project/lab01_java_bigrams.cnt");
