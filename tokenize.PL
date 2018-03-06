#!/Users/cat/perl
use strict;
use warnings;
use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Segmenter::TextTiling qw(segments);

$dirname = '/Volumes/2TB/Final_project/Fanfic_all';

opendir(DIR, $dirname) or die "Could not open $dirname\n";
while ($filename = readdir(DIR)) {
  print "$filename\n";
}
closedir(DIR);
