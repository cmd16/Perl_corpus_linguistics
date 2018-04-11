use strict;
use warnings;
use Path::Tiny qw( path );
# use lib '/Users/cat/perl5/lib/perl5';
use Lingua::EN::Tagger;
use File::Basename;

$| = 1;  # won't buffer STDOUT

my $proj_dir = "/Volumes/2TB/Final_project";
my $fanfic_dir = $proj_dir . "/Fanfic_all";
my $tag_dir = $proj_dir . "/Tag perl";
my $ending = '.txt';
my $tagger = new Lingua::EN::Tagger;

my $readdir = sprintf("%s/Fanfic_all",$proj_dir);
# printf("readdir: %s\n",$readdir);
# if(-d $readdir) { print "exists!\n"; }

foreach my $name (<$readdir/*>) {
    print "name: $name\n";

    my $basename = basename($name, $ending);
    print "basename: $basename\n";

    if ($name =~ /$ending/) {
#        my $current_name = $proj_dir . "/Fanfic lists/$name";
        my $text =  path($name)->slurp_utf8;
        my $tagged_text = $tagger->add_tags($text);
        my $newfile = sprintf("%s/%s_tagged%s",$tag_dir,$basename,$ending);
        # printf("name: %s - newfile: %s\n",$name,$newfile);
        open(FH, '>', $newfile) or die $!;
        print FH $tagged_text;
        close(FH);
    }
}
