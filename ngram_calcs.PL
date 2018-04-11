#!/Users/cat/perl
use strict;
use warnings;
use Lingua::EN::Ngram;
use IPC::System::Simple qw(system capture);

my $dirname = "/Users/cat/CS214";
# my $ngram = Lingua::EN::Ngram->new( file => $dirname . "/lab01_java.txt" );
my $corpus = Lingua::EN::Ngram->new;

my $filename = $dirname . "/lab01_java.txt";
# Run a command, wait until it finishes, and make sure it works.
# Output from this program goes directly to STDOUT, and it can take input
# from your STDIN if required.
system($^X, "/Users/cat/perl5/bin/count.pl", "--token=valid_tokens.txt", "lab01_java_bigrams.cnt", $filename);

# statistic.pl -score 6.00 -frequency 5 ll.pm holmes1.ll h.cnt
system($^X, "/Users/cat/perl5/bin/statistic.pl", "--score=6.63", "ll.pm", "lab01_java_bigrams.ll", "/Users/cat/Perl_scripts/214_Final_project/lab01_java_bigrams.cnt");
