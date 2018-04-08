#!/Users/cat/perl
use strict;
use warnings;
use Lingua::EN::Ngram;
use Lingua::EN::Segmenter::TextTiling qw(segments);
use Path::Tiny qw( path );
use IPC::System::Simple qw(system capture);

my $splitter = new Lingua::EN::Splitter;
# $ngram = Lingua::EN::Ngram->new( file => './etc/walden.txt' );
my $dirname = "/Users/cat/CS214";
# my $ngram = Lingua::EN::Ngram->new( file => $dirname . "/lab01_java.txt" );
my $corpus = Lingua::EN::Ngram->new;

my $filename = $dirname . "/lab01_java.txt";
# Run a command, wait until it finishes, and make sure it works.
# Output from this program goes directly to STDOUT, and it can take input
# from your STDIN if required.
# system($^X, "/Users/cat/perl5/bin/count.pl", "lab01_java_bigrams.txt", $filename, "valid_tokens.txt");

# statistic.pl -score 6.00 -frequency 5 ll.pm holmes1.ll h.cnt
system($^X, "/Users/cat/perl5/bin/statistic.pl", "ll.pm", "lab01_jav_bigrams.ll",
    "/Users/cat/Perl_scripts/214_Final_project/lab01_java_bigrams.cnt");

# my $text = path($filename)->slurp_utf8;
# my @tokens = $splitter->words($text);
# my @words;
# foreach my $token (@tokens) {
#     push(@words, $token) unless $token =~ /^[a-zA-Z']+$/;  # add the token unless it contains a non-alpha character
# }
# # delete @tokens;  # free up memory space
# my $intersections = $corpus->intersection( corpus => @words, length => 3 );
# foreach ( sort { $$intersections{ $b } <=> $$intersections{ $a }} keys %$intersections ) {
#     print $$intersections{ $_ }, "\t$_\n";
# }
# # $trigrams = $ngram->ngram( 3 );
# #     foreach my $trigram ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {
# #         print $$trigrams{ $trigram }, "\t$trigram\n";
# # }
