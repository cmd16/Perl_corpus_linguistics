#!/Users/cat/perl
use strict;
use warnings;
use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
use Parse::CSV;
my $csv = Parse::CSV->new(
    file => "/Volumes/2TB/Final_project/CSV/Doctor_Who_works.csv",
    csv_attr => {
        sep_char => ", ",
        quote_char => '"'
    },
    names => 1,
);
# my $file = "/Volumes/2TB/Final_project/CSV/Doctor_Who_works.csv";
my $fanfic_dir = "/Volumes/2TB/Final_project/Fanfic_all";
my @stats = ('work_id', 'title', 'rating', 'category', 'fandom', 'relationship', 'character', 'additional tags', 'language',
         'published', 'status', 'status date', 'words', 'chapters', 'comments', 'kudos', 'bookmarks', 'hits', 'body');
my %titles; my %ratings; my %categories; my %fandoms; my %relationships; my %characters; my %tags; my %published;
my %statuses; my %status_dates; my %word_counts; my %chapter_counts; my %comment_counts; my %kudos_counts; my %bookmark_counts;
my %hit_counts;
# open(my $data, '<', $file) or die "Could not open '$file' $!\n";
while (my %fields = $csv->fetch) {
  #chomp $line;
      my $other_file = $fanfic_dir . "/" . $fields{'work_id'} . ".txt";
      if (not(-f $other_file)) {
          print "$other_file not found."
      }
      else {
          $titles{$fields{'title'}} += 1; $ratings{$fields{'rating'}} += 1;
          foreach my $category (split(", ", $fields{'category'})) {
              $categories{$category} += 1;
          }
          $fandoms{$fields{'fandom'}} += 1;
          foreach my $relationship (split(", ", $fields{'relationship'})) {
              $relationships{$relationship} += 1;
          }
          foreach my $character (split(", ", $fields{'character'})) {
              $characters{$character} += 1;
          }
          foreach my $tag (split(", ", $fields{'additional tags'})) {
              $tags{$tag} += 1;
          }
          $published{$fields{'published'}} += 1; $statuses{$fields{'status'}} += 1;
          $status_dates{$fields{'status date'}} += 1;
          $word_counts{$fields{'words'}} += 1;  # change later to round to nearest 100
          $chapter_counts{$fields{'chapters'}} += 1; $comment_counts{$fields{'comments'}} += 1;
          $kudos_counts{$fields{'kudos'}} += 1; $bookmark_counts{$fields{'bookmarks'}} += 1;
          $hit_counts{$fields{'hits'}} += 1;
      }
}


open(my $out, ">", "Doctor_Who_results.txt") or die "Couldn't open file, $!";
print $out "title" . "\n";
=begin comment
foreach my $title (%titles) { print $out $title . ": " . $titles{$title} . "\n"; }
print $out "rating" . "\n";
foreach my $rating (%ratings) { print $out $rating . ": " . $ratings{$rating} . "\n"; }
print $out "category" . "\n";
foreach my $category (%categories) { print $out $category . ": " . $categories{$category} . "\n"; }
print $out "fandom" . "\n";
foreach my $fandom (%fandoms) { print $out $fandom . ": " . $fandoms{$fandom} . "\n"; }
print $out "relationship" . "\n";
foreach my $relationship (%relationships) { print $out $relationship . ": " . $relationships{$relationship} . "\n"; }
print $out "character" . "\n";
foreach my $character (%characters) { print $out $character . ": " . $characters{$character} . "\n"; }
print $out "tag" . "\n";
foreach my $tag (%tags) { print $out $tag . ": " . $tags{$tag} . "\n"; }
print $out "publish" . "\n";
foreach my $publish (%published) { print $out $publish . ": " . $published{$publish} . "\n"; }
print $out "status" . "\n";
foreach my $status (%statuses) { print $out $status . ": " . $statuses{$status} . "\n"; }
print $out "status date" . "\n";
foreach my $status_date (%status_dates) { print $out $status_date . ": " . $status_dates{$status_date} . "\n"; }
print $out "word count" . "\n";
foreach my $word_count (%word_counts) { print $out $word_count . ": " . $word_counts{$word_count} . "\n"; }
print $out "chapter count" . "\n";
foreach my $chapter_count (%chapter_counts) { print $out $chapter_count . ": " . $chapter_counts{$chapter_count} . "\n"; }
print $out "comment count" . "\n";
foreach my $comment_count (%comment_counts) { print $out $comment_count . ": " . $comment_counts{$comment_count} . "\n"; }
print $out "kudos count" . "\n";
foreach my $kudos_count (%kudos_counts) { print $out $kudos_count . ": " . $kudos_counts{$kudos_count} . "\n"; }
print $out "bookmark count" . "\n";
foreach my $bookmark_count (%bookmark_counts) { print $out $bookmark_count . ": " . $bookmark_counts{$bookmark_count} . "\n"; }
print $out "hit count" . "\n";
foreach my $hit_count (%hit_counts) { print $out $hit_count . ": " . $hit_counts{$hit_count} . "\n"; }
=end comment
=cut
