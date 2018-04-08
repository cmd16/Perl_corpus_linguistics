use strict;
use warnings;
use diagnostics;
use Path::Tiny qw( path );
# use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Tagger;

my $proj_dir = "/Volumes/2TB/Final_project";
my $fanfic_dir = $proj_dir . "/Fanfic_all";
my $tag_dir = $proj_dir . "/Tag perl";
my $ending = /.txt/;
my $tagger = new Lingua::EN::Tagger;

foreach $name (readdir($proj_dir . "/Fanfic lists")) {
    if $name =~ $ending {
        my $current_name = $proj_dir . "/Fanfic lists/$name";
        my $text = path($current_name)->slurp_utf8;
        my $tagged_text = $tagger->add_tags($text);
        write_file($tag_dir . $name/$ending/"_tagged.txt"/g, $tagged_text) ;
    }
}
