#!/Users/cat/perl
use strict;
use warnings;
use Path::Tiny qw( path );
use Lingua::EN::Tagger;
use File::Basename;

$| = 1;  # won't buffer STDOUT

my $proj_dir = "/Volumes/2TB/Final_project";
my $tag_dir = $proj_dir . "/Tag perl";
my $fanfic_dir = sprintf("%s/Fanfic_all",$proj_dir);
my $ending = '.txt';
my $tagger = new Lingua::EN::Tagger;
my $restart_id = "729897";
my $found = 0;

opendir(DH, $fanfic_dir) or die "opendir() failed: $!";
my @files = readdir(DH);
closedir(DH);
foreach my $name (@files) {

    my $basename = basename($name, $ending);
    print "$basename";
    if (!$restart_id or $basename == $restart_id) {
        $found = 1;
    }
    if (!$found) {
        print " skipped\n";
        next;
    }
    print "\n";

    if ($name =~ /$ending/) {  # TODO: fix problem that this modifies name
        my $text =  path("$fanfic_dir/$basename$ending")->slurp_utf8;  # TODO: fix this messiness
        my $tagged_text = $tagger->add_tags($text);
        # $tagged_text =~ s/(.{1,5})/$1\n/gs;
        my $newfile = sprintf("%s/%s_tagged%s", $tag_dir, $basename, $ending);
        # printf("name: %s - newfile: %s\n",$name,$newfile);
        open(FH, '>', $newfile) or die $!;
        print FH $tagged_text;
        close(FH);
    }
}
