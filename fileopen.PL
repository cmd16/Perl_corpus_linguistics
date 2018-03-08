#!/usr/bin/perl
# learned some from https://alvinalexander.com/blog/post/perl/how-process-every-word-text-file-perl
use warnings;
use strict;

#my $test_str = "This is a test sample. testing one, 2, 3. Don't do it? Ok! run-away. email\@domain.com. \"quotation stuff\" then 'apostrophe stuff'. http:://www.website.com. Comma, ok. Sentence w\\ semicolon; there - check it out: sample.";
#my $loopvar;
#for $loopvar (split(/[\W|\d]*[\s+'][\W|\d|\.]*/, $test_str))
#{
#  print $loopvar . " ";
#}
my $test_str2;
my $loopvar2;
$test_str2 = "\"Knock knock,\" you say, tapping on the door that most decidedly does not reply. It hasn't in the past, which is about the same as bouncing your jokes off your brother's skull because after about the tenth one he usually doesn't reply either. So you joke at the door, because the door is decidedly less likely to start throwing things after the fifteenth joke.\n\nWho's there, you imagine the door saying, to which you reply, \"Dozen.\"\n\n\nDozen who?\n\n\n\"Dozen anyone want to let me in?\" you ask, snickering. The door, predictably, does not reply. Apparently your interest in imagining its responses only extends to the end of the joke. That's fine, though; you're not accustomed to an audience that does more than roll their eyesockets at you.";
for $loopvar2 (split(/[\W|\d]*[\s+'][\W|\d|\.]*/, $test_str2))
{
  print $loopvar2 . " ";
}
# open(my $in, "<", "/Users/cat/Intro to Corpus Linguistics on cpu/Six_debate_files_and_JVB_spreadsheet/First debate Clinton.txt") or die "Couldn't open file, $!";
# open(my $in, "<", "/Volumes/2TB/Final_Project/Fanfiction/Undertale/Undertale works/4864907.txt") or die "Couldn't open file, $!";
open(my $in, "<", "test_fic.txt") or die "Couldn't open file, $!";
my $word;


while(<$in>) {
  for $word (split(/[\W|\d]*[\s+'][\W|\d|\.]*/))
  {
    # do whatever you need to here. in my case
    # i'm just printing each "word" on a new line.
    # print $word . " ";
  }
}
close $in;
# print @words[0];
