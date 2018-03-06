#!/Users/cat/perl
use File::Copy;
use strict;
use warnings;

my $directory = "/Volumes/2TB/Final_Project/Fanfiction/Doctor Who/Doctor Who works";
my $fanfic_dir = "/Volumes/2TB/Final_Project/Fanfic_all";
opendir (DIR, $directory) or die $!;
while (my $file = readdir(DIR)) {
  my $from = $directory . "/" . "$file";
  my $to = $fanfic_dir . "/" . "$file";
  move($from, $fanfic_dir . $file) or die "The move operation failed: $!";
}
