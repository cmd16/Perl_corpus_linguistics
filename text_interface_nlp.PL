use strict;
use warnings;
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
use Time::HiRes qw(time);
use Path::Tiny qw(path);
require "./Tokenize.PL";

my $show_full_pathname = 1;
my $global_default_extension = ".txt";
my $global_save_intermediate = 0;
my $global_save_intermediate_dir = "";

my $global_regex = "[^a-zA-Z]+";
my $global_case_sensitive = 0;
my $global_stop_words = ();

my $tool_wordlist_case = 0;  # in this case means (match whatever global is)
my $tool_wordlist_regex_checkval = 0;  # match whatever global is
my $tool_wordlist_regex = "";
my $tool_wordlist_corpus_checkval = 0;  # raw files (1 means wordlists)
my $tool_wordlist_wordlists = ();

my $tool_concordance_case = 0;  # same as global settings
my $tool_concordance_win_length = 7;

my $tool_ngram_case = 0;
my $tool_ngram_regex_checkval = 1;
my $tool_ngram_regex_filename = "";
my $tool_ngram_nontoken_checkval = 0;
my $tool_ngram_nontoken_filename = "";
my $tool_ngram_nontokens = ();
my $tool_ngram_stop_checkval = 0;
my $tool_ngram_stop_filename = "";
my $tool_ngram_stopwords = ();
my $tool_ngram_freq_checkval = 0;
my $tool_ngram_freq = 1;
my $tool_ngram_ufreq_checkval = 0;
my $tool_ngram_ufreq = 1;
my $tool_ngram_newline_checkval = 1;
my $tool_ngram_precision = 6;
my $tool_ngram_measure_2 = "MI::ll.pm";
my $tool_ngram_measure_3 = "MI::ll.pm";
my $tool_ngram_measure_4 = "MI::ll.pm";

my $tool_keyword_p = 0.01;
my $tool_keyword_reference_checkval = 0;

my $wordlist_types = 0;
my $wordlist_tokens = 0;
my $wordlist_search_num = 0;
my $wordlist_freqdist = new FreqDist;

my @filenames = ();

my $splitter = new Lingua::EN::Splitter;
$splitter->set_non_word_regexp("$global_regex");  # todo: modify to use definition

sub set_global_settings {
    print("Show full pathname? (1/0). Currently $show_full_pathname: ");
    my $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$show_full_pathname = int($input)};

    print("Default extension to use with openDir. Currently $global_default_extension: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$global_default_extension = $input};

    print("Global regex to define nontoken (simplest way is [^nontoken]+). Currently $global_regex: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$global_regex = $input};

    print("Global case sensitive (1/0). Currently $global_case_sensitive: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$global_case_sensitive = int($input)};

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
    if ($input ne  "") {$tool_wordlist_case = int($input)};

    print("Use global regex for nontoken definition (currently $global_regex) (0) or write your own (1).
    Currently $tool_wordlist_regex_checkval: ");
    $input = <STDIN>;
    chomp($input);
    # TODO: why isn't this working?
    if ($input ne  "") {$tool_wordlist_regex_checkval = $input};

    if ($tool_wordlist_regex_checkval eq "1") {
        print("Set wordlist regex for nontoken (simplest way is [^token]+). Currently $tool_wordlist_regex: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_wordlist_regex = $input};
    }

    print("Load wordlist from text files (0) or wordlist files (1). Currently $tool_wordlist_corpus_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_wordlist_corpus_checkval = $input};
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

sub set_tool_settings_concordance {
    print("Case sensitive: same as global (currently $global_case_sensitive) (0), sensitive (1), or insensitive (2). Currently $tool_concordance_case: ");
    my $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_concordance_case = $input};

    print("Window (how many tokens to display before and after query). Currently $tool_concordance_win_length: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_concordance_win_length = $input};
    print("\n");
}

sub view_tool_settings_concordance {
    print("Case sensitive: $tool_concordance_case\n");
    print("Window (how many tokens to display before and after query): $tool_concordance_win_length\n");
}

sub set_tool_settings_ngram {
    print("Case sensitive: same as global (currently $global_case_sensitive) (0), sensitive (1), or insensitive (2). Currently $tool_ngram_case: ");
    my $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_case = $input};

    print("Use global regex for token definition (currently $global_regex) (1/0). Currently $tool_ngram_regex_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_regex_checkval = $input};

    if (! $tool_ngram_regex_checkval) {
        print("Filename containing token regexes for ngrams. Currently $tool_ngram_regex_filename: ");
        $input = <STDIN>;
        chomp($input);
        if (! $input eq  "") {$tool_ngram_regex_filename = $input};
    }

    print("Use file for nontokens (1/0). Currently $tool_ngram_nontoken_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_nontoken_checkval = $input};

    #TODO: not working
    if (! $tool_ngram_nontoken_checkval) {
        print("Filename containing nontoken regexes for ngrams (currently $tool_ngram_nontoken_filename): ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_nontoken_filename = $input};
    }

    print("Use file for stopwords (1/0). Currently $tool_ngram_stop_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_stop_checkval = $input};

    #TODO: not working
    if (! $tool_ngram_stop_checkval) {
        print("Filename containing stopword regexes for ngrams. Currently $tool_ngram_stop_filename: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_stop_filename = $input};
    }

    print("Set minimum frequency (1/0). Currently $tool_ngram_freq_checkval: ");
    $input = <STDIN>;
    chomp($input);
    # TODO: why isn't this working?
    if ($input ne  "") {$tool_ngram_freq_checkval = $input};

    #TODO: not working
    if (! $tool_ngram_freq_checkval) {
        print("Minimum frequency. Currently $tool_ngram_freq: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_freq = $input};
    }

    print("Set maximum frequency (1/0). Currently $tool_ngram_ufreq_checkval: ");
    $input = <STDIN>;
    chomp($input);
    # TODO: why isn't this working?
    if ($input ne  "") {$tool_ngram_ufreq_checkval = $input};

    #TODO: not working
    if (! $tool_ngram_ufreq_checkval) {
        print("Maximum frequency. Currently $tool_ngram_ufreq: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_ufreq = $input};
    }

    print("Count ngrams across newline tokens (1/0). Currently $tool_ngram_newline_checkval: ");
    $input = <STDIN>;
    chomp($input);
    # TODO: why isn't this working?
    if ($input ne  "") {$tool_ngram_newline_checkval = $input};

    print("Number of digits to round results to. Currently $tool_ngram_precision: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_newline_checkval = $input};

    print("Measure to use for bigrams.
    CHI::phi.pm, CHI::tscore.pm, CHI::x2,
    dice::dice.pm, dice::jaccard.pm,
    Fisher::left.pm, Fisher::right.pm, Fisher::twotailed.pm,
    Log likelihood (MI::ll.pm), Pointwise Mutual Information (MM::pmi.pm),
    Poisson Stirling (MI::ps.pm), True Mutual Information (MI::tmi.pm),
    odds.pm
    Currently $tool_ngram_measure_2: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_measure_2 = $input};

    print("Measure to use for trigrams.
    Log likelihood (MI::ll.pm), Pointwise Mutual Information (MM::pmi.pm),
    Poisson Stirling (MI::ps.pm), True Mutual Information (MI::tmi.pm),
    Currently $tool_ngram_measure_3: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_measure_3 = $input};

    print("\n");
}

sub view_tool_settings_ngram {
    print("Case sensitive: $tool_ngram_case\n");

    print("Use global regex for token definition (1/0): $tool_ngram_regex_checkval\n");
    if ($tool_ngram_regex_checkval) {
        print("Filename containing token regexes for ngrams: $tool_ngram_regex_filename\n");
    }

    print("Use file for nontokens (1/0): $tool_ngram_nontoken_checkval\n");
    if (! $tool_ngram_nontoken_checkval) {
        print("Filename containing nontoken regexes for ngrams: $tool_ngram_nontoken_filename\n");
    }

    print("Use file for stopwords (1/0): $tool_ngram_stop_checkval\n");
    if (! $tool_ngram_stop_checkval) {
        print("Filename containing stopword regexes for ngrams: $tool_ngram_stop_filename\n");
    }

    print("Set minimum frequency (1/0): $tool_ngram_freq_checkval\n");

    if (! $tool_ngram_freq_checkval) {
        print("Minimum frequency: $tool_ngram_freq\n");
    }

    print("Set maximum frequency (1/0): $tool_ngram_ufreq_checkval\n");
    if (! $tool_ngram_ufreq_checkval) {
        print("Maximum frequency: $tool_ngram_ufreq\n");
    }

    print("Count ngrams across newline tokens (1/0): $tool_ngram_newline_checkval\n");

    print("Number of digits to round results to: $tool_ngram_precision\n");

    print("Measure to use for bigrams: $tool_ngram_measure_2\n");

    print("Measure to use for trigrams: $tool_ngram_measure_3\n");
}

sub set_tool_settings_keyword {
    print("P value for keyword analysis
    p = 0.05 (exclude keywords with log likelihood < 3.84),
    p = 0.01 (exclude keywords with log likelihood < 6.63),
    p = 0.001 (exclude keywords with log likelihood < 10.83,
    p = 0.0001 (exclude keywords with log likelihood < 15.13,
    p = 0 (include all keywords)
    Currently $tool_keyword_p: ");
    my $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_keyword_p = $input};  # TODO: figure out if this is real

    print("Use text files (0) or wordlists (1). Currently $tool_keyword_reference_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_keyword_reference_checkval = $input};
}

sub view_tool_settings_keyword {
    print("P value for keyword analysis: $tool_keyword_p\n");
    print("Use text files (0) or wordlists (1): $tool_keyword_reference_checkval\n");
}

sub run_wordlist {
    print("
        1: Get wordlist
        2: Search wordlist
        0: Exit
        ");
    my $selection = <STDIN>;
    chomp($selection);
    if ($selection eq "1") {
        $wordlist_freqdist->clear_hash();  # clear out the FreqDist
        if ($tool_wordlist_corpus_checkval eq "0") {  # use regular files
            if ($tool_wordlist_regex_checkval eq "1") {
                print("using local regex $tool_wordlist_regex\n");
                $splitter->set_non_word_regexp("$tool_wordlist_regex");
            }
            elsif ($tool_wordlist_regex_checkval eq "0") {
                print("using global regex $global_regex\n");
                $splitter->set_non_word_regexp("$global_regex");
            }
            foreach my $filename (@filenames) {
                $wordlist_freqdist->update(tokenize_file($filename, $splitter));  # TODO: add case sensitive
            }
        }
        else {
            foreach my $filename (@filenames) {
                my $current_freq_dist = new FreqDist();
                $current_freq_dist->open_from_txt($filename);
                $wordlist_freqdist->update($current_freq_dist);
            }
        }
        print("Name of file to save in: ");
        my $save_name = <STDIN>;
        chomp($save_name);
        $wordlist_freqdist->out_to_txt($save_name);

        print("Display results (1/0): ");
        my $answer = <STDIN>;
        chomp($answer);
        if ($answer eq "1") {
            open(my $in, "<", $save_name) or warn "Could not open $save_name, $!\n";
            while(my $line = <$in>) {
                print($line);
            }
            close $in;
        }
    }
    elsif ($selection eq "2") {  # TODO: get search to work
        print("Regex (0) or text (1): ");
        my $reg_or_txt = <STDIN>;
        chomp($reg_or_txt);

        print("Query: ");
        my $query = <STDIN>;
        chomp($query);

        if ($reg_or_txt eq "1") {
            $query = quotemeta($query);  # escape special characters
        }

        print("Exact match (0) or partial match (1): ");
        my $exact_or_partial = <STDIN>;
        chomp($exact_or_partial);

        foreach my $token ($wordlist_freqdist->get_keys()) {
            if (search_token($token, $query, $exact_or_partial)) {
                printf("%d\t%s\n", $wordlist_freqdist->get_count($token), $token);
            }
        }
    }
}

sub search_token {
    my ($token, $query, $exact_or_partial) = @_;
    if ($exact_or_partial eq "1") {  # not exact
        if ($token =~ /$query/) {
            return 1;
        }
    }
    elsif ($token =~ /^$query$/) {  # anchor at beginning and end
        return 1;
    }
    return 0;
}

sub run_concordance {
    print("Regex (0) or text (1): ");
    my $reg_or_txt = <STDIN>;
    chomp($reg_or_txt);

    print("Enter the tokens separated by spaces: ");
    my $query = <STDIN>;
    chomp($query);

    if ($reg_or_txt eq "1") {
        $query = quotemeta($query);  # escape special characters
    }

    my @queries = split(" ", $query);

    if ($tool_wordlist_regex_checkval eq "1") {
        print("using local regex $tool_wordlist_regex\n");
        $splitter->set_non_word_regexp("$tool_wordlist_regex");
    }
    elsif ($tool_wordlist_regex_checkval eq "0") {
        print("using global regex $global_regex\n");
        $splitter->set_non_word_regexp("$global_regex");
    }

    print("Exact match (0) or partial match (1): ");
    my $exact_or_partial = <STDIN>;
    chomp($exact_or_partial);

    foreach my $filename (@filenames) {
        my $text = path("$filename")->slurp_utf8;
        my @words = $splitter->words($text);
        for my $i (0..$#words) {
            my $match = 1;
            for my $x (0..$#queries) {
                my $idx = $i+$x;
                my $token = $words[$idx];
                if (! search_token($token, $query, $exact_or_partial)) {
                    print("$token not a match");
                    $match = 0;
                    last;
                }
            }
            if ($match) {
                print(@words[$i-$tool_concordance_win_length..$i+$tool_concordance_win_length]);
                print("\t$filename\n");
            }
        }
    }
}

sub main {
    my $choice = -1;
    my $seleciton = -1;
    while ($choice ne "0") {
        print("
    Main menu
    1: Global settings
    2: Tool settings
    3: Open files
    4: Remove files
    5: View filenames
    6: Wordlist
    7: Concordance
    8: Ngrams
    9: Keyword
    0: Exit
    ");
        my $choice = <STDIN>;
        chomp($choice);
        if ($choice eq "1") {
            set_global_settings();
            view_global_settings();
        }
        elsif ($choice eq "2") {
            print("
        1: Wordlist settings
        2: Concordance settings
        3: Ngram settings
        4: Keyword settings
        0: Exit
        ");
            my $selection = <STDIN>;
            chomp($selection);
            if ($selection eq "1") {
                set_tool_settings_wordlist();
                view_tool_settings_wordlist();
            }
            elsif ($selection eq "2") {
                set_tool_settings_concordance();
                view_tool_settings_concordance();
            }
            elsif ($selection eq "3") {
                set_tool_settings_ngram();
                view_tool_settings_ngram();
            }
            elsif ($selection eq "4") {
                set_tool_settings_keyword();
                view_tool_settings_keyword();
            }
        }
        elsif ($choice eq "3") {
            print("
        1: Open file
        2: Open directory
        3: Open file containing filenames
        ");
            my $selection = <STDIN>;
            chomp($selection);
            if ($selection eq "1") {
                print("filename: ");
                my $filename = <STDIN>;
                chomp($filename);
                if (-f $filename) {
                    push(@filenames, $filename);
                }
                else {
                    warn("$filename could not be found.");
                }
            }
            elsif ($selection eq "2") {
                print("directory name: ");
                my $dirname = <STDIN>;
                chomp($dirname);
                if (-d $dirname) {
                    opendir(DIR, $dirname) or die "Could not open $dirname, $!\n";
                    while (my $filename = readdir(DIR)) {
                        $filename = "$dirname/$filename";
                        if (-f $filename) {
                            if ($filename =~ /$global_default_extension$/)  {
                                push(@filenames, $filename);
                            }
                            else {
                                warn("Skipping $filename because it doesn't match the extension");
                            }
                        }
                        else {
                            warn("$filename could not be found.");
                        }
                    }
                }
                else {
                    warn("$dirname could not be found.");
                }
            }
            elsif ($selection eq "3") {
                print("filename: ");
                my $main_filename = <STDIN>;
                chomp($main_filename);

                print("prefix (e.g., path to files): ");
                my $prefix = <STDIN>;
                chomp($prefix);

                print("suffix (e.g., extension): ");
                my $suffix = <STDIN>;
                chomp($suffix);

                if (-f $main_filename) {
                    open(my $in, "<$main_filename") or warn "Could not open $main_filename, $!\n";
                    my $freq_dist_obj = new FreqDist;  # TODO update definition
                    while(my $line = <$in>) {
                        chomp($line);
                        if ($line eq "") {next;}
                        my $filename = "$prefix$line$suffix";
                        if (-f $filename) {
                            push(@filenames, $filename);
                        }
                        else {
                            warn "$filename could not be found.";
                        }
                    }
                    close $in;
                }
                else {
                    warn "$main_filename could not be found.";
                }
            }
        }
        elsif ($choice eq "4") {
            if ($#filenames < 1) {
                print("No files to remove.\n");
                next;
            }
            for my $i (0 .. $#filenames) {
                my $filename = $filenames[$i];
                print("$i $filename\n");
            }
            print("Index of file to delete: ");
            my $del_idx = <STDIN>;
            chomp($del_idx);
            $del_idx = int($del_idx);
            splice(@filenames, $del_idx, 1);
        }
        elsif ($choice eq "5") {
            for my $filename (@filenames) {
                print("$filename\n");
            }
        }
        elsif ($choice eq "6") {
            run_wordlist();
        }
        elsif ($choice eq "7") {
            run_concordance();
        }
    }
}

main();
