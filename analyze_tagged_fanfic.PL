#!/Users/cat/perl
require "./analyze_tagged_text.PL";

my $proj_dir = "/Volumes/2TB/Final_project";
my $tag_dir = "$proj_dir/Tag\ perl";
# print "main tagdir: $tag_dir";
my $fanfic_list_dir = "$proj_dir/Fanfic lists";
my $tag_wordlist_dir = "$proj_dir/Tag wordlists";

opendir(DH, $fanfic_list_dir) or die "opendir() failed: $!";
my @files = readdir(DH);
closedir(DH);

foreach my $idlist_name (@files) {
    # next if ($id_name =~ /^.+$/);
    if ($idlist_name eq "." or $idlist_name eq ".." or $idlist_name eq ".DS_Store") {
        print "skipping $idlist_name\n";
        next;
    }
    print "$idlist_name\n";
    my $full_name = "$fanfic_list_dir/$idlist_name";
    my $current_tag_dict = { %$tags_names };
    scalar keys $current_tag_dict;
    foreach my $tag ($current_tag_dict) {
        $current_tag_dict{$tag} = new FreqDist;
    }
    parse_tags_from_idlist($full_name, $tag_dir, $current_tag_dict, undef);
    tag_dict_to_files($current_tag_dict, "$tag_wordlist_dir/$idlist_name");
    my $current_comb_dict = combine_tags($tag_dict, $simple_tags);
    tag_dict_to_files($current_comb_dict, "$tag_wordlist_dir/$idlist_name");
}
