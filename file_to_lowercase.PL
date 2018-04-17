#!/Users/cat/perl
use strict;
use warnings;
use Path::Tiny qw( path );
$| = 1;  # won't buffer STDOUT

sub file_to_lc {
    my ($oldfilename, $newfilename) = @_;
    my $text = lc (path($oldfilename)->slurp_utf8);
    open(FH, '>', $newfilename) or die $!;
    print FH $text;
    close(FH);
    print "processed $oldfilename\n";
}

sub dir_to_lc {
    my ($old_dir, $new_dir) = @_;
    opendir(DH, $old_dir) or die "opendir() failed: $!";
    my @files = readdir(DH);
    closedir(DH);
    foreach my $name (@files) {
        if ($name =~ /.txt/) {
            file_to_lc("$old_dir/$name", "$new_dir/$name");
        }
    }
}

my $proj_dir = "/Volumes/2TB/Final_project";
my $fanfic_dir = "$proj_dir/Fanfic_all";
my $lower_dir = "$proj_dir/Fanfic_lower";
dir_to_lc($fanfic_dir, $lower_dir);
