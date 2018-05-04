use strict;
use warnings;
my $show_full_pathname = 1;
my $global_default_extension = ".txt";
my $global_save_intermediate = 0;
my $global_save_intermediate_dir = "";

my $global_regex = "[a-zA-Z]+";
my $global_case_sensitive = 0;
my $global_stop_words = ();

my $tool_wordlist_case = 0;  # in this case means (match whatever global is)
my $tool_wordlist_regex_checkval = 1;  # match whatever global is
my $tool_wordlist_regex = "";
my $tool_wordlist_corpus_checkval = 0;  # raw files
my $tool_wordlist_wordlists = ();

sub set_global_settings {
    print("Show full pathname (currently $show_full_pathname)? 1/0: ");
    my $input = <STDIN>;
    chomp($input);
    if (! $input eq  "") {$show_full_pathname = int($input)};
    print("Default extension to use with openDir (currently $global_default_extension): ");
    $input = <STDIN>;
    chomp($input);
    if (! $input eq  "") {$global_default_extension = $input};

    print("Global regex to define token (must be in form []+) (currently $global_regex): ");
    $input = <STDIN>;
    chomp($input);
    if (! $input eq  "") {$global_regex = $input};
    print("Global case sensitive (currently $global_case_sensitive)? 1/0: ");
    $input = <STDIN>;
    chomp($input);
    if (! $input eq  "") {$global_case_sensitive = int($input)};

    # print("Global stop words (currently $global_stop_words)");
    # # TODO: implement add stop words
    print("\n");
}

sub view_global_settings {
    print("Show full pathname: $show_full_pathname\n");
    print("Default extension to use with openDir: $global_default_extension\n");
    print("Global regex to define token: $global_regex\n");
    print("Global case sensitive: $global_case_sensitive\n");
}

sub set_tool_settings_wordlist {
    print("Case sensitive: same as global (currently $global_case_sensitive) (0), sensitive (1), or insensitive (2). Currently $tool_wordlist_case: ");
    my $input = <STDIN>;
    chomp($input);
    if (! $input eq  "") {$tool_wordlist_case = int($input)};
    print("Use global regex for token definition (currently $global_regex) (1/0). Currently $tool_wordlist_regex_checkval: ");
    $input = <STDIN>;
    chomp($input);
    # TODO: why isn't this working?
    if (! $input eq  "") {$tool_wordlist_regex_checkval = int($input);};
    if (! $tool_wordlist_regex_checkval) {
        print("Set wordlist regex for token definition (must be in form []+) (currently $tool_wordlist_regex): ");
        $input = <STDIN>;
        chomp($input);
        if (! $input eq  "") {$tool_wordlist_regex = $input};
    }
    print("Load wordlist from text files (0) or wordlist files (1). Currently ($tool_wordlist_corpus_checkval): ");
    $input = <STDIN>;
    chomp($input);
    if (! $input eq  "") {$tool_wordlist_corpus_checkval = int($input)};
    print("\n");
}

sub view_tool_settings_wordlist {
    print("Case sensitive: $tool_wordlist_case\n");
    print("Use global regex: $tool_wordlist_regex_checkval\n");
    if (! $tool_wordlist_regex_checkval) {
        print("Wordlist regex: $tool_wordlist_regex\n");
    }
    print("Wordlist from text files (0) or wordlist files (1): $tool_wordlist_corpus_checkval\n");
}

set_tool_settings_wordlist();
view_tool_settings_wordlist();
