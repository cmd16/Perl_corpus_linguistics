#!/Users/cat/perl
use strict;
use warnings;
use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Tokenizer::Offsets qw/token_offsets get_tokens/;
use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Segmenter::TextTiling qw(segments);
my @sentence_array;
my $splitter = new Lingua::EN::Splitter;
my %segmenter_hash;
#open(my $in, "<", "/Users/cat/Intro to Corpus Linguistics on cpu/Six_debate_files_and_JVB_spreadsheet/First debate Clinton.txt") or die "Couldn't open file, $!";
open(my $in, "<", "48.txt") or die "Couldn't open file", $!;
my %word_hash;
while(my $line = <$in>) {
    my $tokens = get_tokens($line);
    foreach my $token (@$tokens) {
        $word_hash{$token} += 1;
    }
    my $words = $splitter->words($line);
    foreach my $word (@$words) {
        $segmenter_hash{$word} += 1;
    }
}
close $in;
keys %word_hash; # reset the internal iterator so a prior each() doesn't affect the loop
while(my($token, $freq) = each %word_hash) {
    #print $token . ": " . $freq . "\n";
}
keys %segmenter_hash; # reset the internal iterator so a prior each() doesn't affect the loop
while(my($word, $freq) = each %segmenter_hash) {
    print $word . ": " . $freq . "\n";
}
# @words = $splitter->words($text);
=begin comment
foreach my $sentence (@sentence_array) { print $sentence . "\n"; }
my $sentences = get_sentences("Sentence one is done. Another one! Sentences are long, but fun.");     ## Get the sentences.
foreach my $sentence (@$sentences) {
    print $sentence . "\n";
}
=end comment
=cut
