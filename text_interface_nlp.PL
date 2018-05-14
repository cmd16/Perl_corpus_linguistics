use strict;
use warnings;
use Lingua::EN::Segmenter::TextTiling qw(segments);
use FreqDist;
use Keyword;
use Time::HiRes qw(time);
use Path::Tiny qw(path);
use File::Basename;
require "./Tokenize.PL";

my $show_full_pathname = "1";
my $global_default_extension = ".txt";
my $global_save_intermediate = "0";
my $global_save_intermediate_dir = "";

my $global_regex = "[^a-zA-Z]+";
my $global_case_sensitive = "0";  # case insensitive
my $global_stop_words = ();

my $tool_wordlist_case = "0";  # in this case means (match whatever global is)
my $tool_wordlist_regex_checkval = "0";  # match whatever global is
my $tool_wordlist_regex = "";
my $tool_wordlist_corpus_checkval = "0";  # raw files (1 means wordlists)
my $tool_wordlist_wordlists = ();

my $tool_concordance_case = "0";  # same as global settings
my $tool_concordance_win_length = "7";

my $tool_ngram_case = "0";
my $tool_ngram_regex_filename = "valid_tokens.txt";
my $tool_ngram_nontoken_checkval = "0";
my $tool_ngram_nontoken_filename = "";
my $tool_ngram_stop_checkval = "0";
my $tool_ngram_stop_filename = "";
my $tool_ngram_freq_checkval = "0";
my $tool_ngram_freq = "1";
my $tool_ngram_ufreq_checkval = "0";
my $tool_ngram_ufreq = "1";
my $tool_ngram_newline_checkval = "1";
my $tool_ngram_precision = "6";
my $tool_ngram_measure_2 = "ll.pm";
my $tool_ngram_measure_3 = "ll.pm";
my $tool_ngram_measure_4 = "ll.pm";
my $tool_ngram_script_dir = "/Users/cat/perl5/bin";

my $tool_keyword_p = 0.01;
my $tool_keyword_reference_checkval = "0";  # text files
my @tool_keyword_files = ();
my $tool_keyword_save_freqdist = "0";
my $keyword_outfilename = "";

my $wordlist_types = "0";
my $wordlist_tokens = "0";
my $wordlist_search_num = "0";
my $wordlist_freqdist = new FreqDist;
my $keyword_freqdist = new FreqDist;
my $keyword_obj = new Keyword;

my @filenames = ();

my $splitter = new Lingua::EN::Splitter;
$splitter->set_non_word_regexp("$global_regex");

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

    print("Filename containing token regexes for ngrams. Currently $tool_ngram_regex_filename: ");
    $input = <STDIN>;
    chomp($input);
    if (-f $input) {
        $tool_ngram_regex_filename = $input;
    }
    else {
        warn("$input could not be found.");
    }

    print("Use file for nontokens (1/0). Currently $tool_ngram_nontoken_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_nontoken_checkval = $input};

    if ($tool_ngram_nontoken_checkval eq "1") {
        print("Filename containing nontoken regexes for ngrams (currently $tool_ngram_nontoken_filename): ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_nontoken_filename = $input};
    }

    print("Use file for stopwords (1/0). Currently $tool_ngram_stop_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_stop_checkval = $input};

    if ($tool_ngram_stop_checkval eq "1") {
        print("Filename containing stopword regexes for ngrams. Currently $tool_ngram_stop_filename: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_stop_filename = $input};
    }

    print("Set minimum frequency (1/0). Currently $tool_ngram_freq_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_freq_checkval = $input};

    if ($tool_ngram_freq_checkval eq "1") {
        print("Minimum frequency. Currently $tool_ngram_freq: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_freq = $input};
    }

    print("Set maximum frequency (1/0). Currently $tool_ngram_ufreq_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_ufreq_checkval = $input};

    if ($tool_ngram_ufreq_checkval eq "1") {
        print("Maximum frequency. Currently $tool_ngram_ufreq: ");
        $input = <STDIN>;
        chomp($input);
        if ($input ne  "") {$tool_ngram_ufreq = $input};
    }

    print("Count ngrams across newline tokens (1/0). Currently $tool_ngram_newline_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_newline_checkval = $input};

    print("Number of digits to round results to. Currently $tool_ngram_precision: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_newline_checkval = $input};

    print("Measure to use for bigrams.
    Chi phi (phi.pm), tscore.pm, Chi squared (x2.pm),
    dice.pm, jaccard.pm,
    fisherLeft.pm, fisherRight.pm, fisherTwotailed.pm,
    Log likelihood (ll.pm), Pointwise Mutual Information (pmi.pm),
    Poisson Stirling (ps.pm), True Mutual Information (tmi.pm),
    odds.pm
    Currently $tool_ngram_measure_2: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_measure_2 = $input};

    print("Measure to use for trigrams.
    Log likelihood (ll.pm), Pointwise Mutual Information (pmi.pm),
    Poisson Stirling (ps.pm), True Mutual Information (tmi.pm),
    Currently $tool_ngram_measure_3: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_ngram_measure_3 = $input};

    print("Path to count.pl and statistic.pl. Currently $tool_ngram_script_dir: ");
    $input = <STDIN>;
    chomp($input);
    if (-f "$input/count.pl" and -f "$input/statistic.pl") {
        $tool_ngram_script_dir = $input;
    }
    else {
        warn("count.pl and/or statistic.pl couldn't be found in $tool_ngram_script_dir");
    }

    print("\n");
}

sub view_tool_settings_ngram {
    print("Case sensitive: $tool_ngram_case\n");

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

    print("Path to count.pl and statistic.pl: $tool_ngram_script_dir\n");
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

    # convert input to float. This is a bit messy. TODO: refactor
    if ($input eq  "0.05" or $input eq ".05") {
        $tool_keyword_p = 0.05;
    }
    elsif ($input eq "0.01" or $input eq ".01") {
        $tool_keyword_p = 0.01;
    }
    elsif ($input eq "0.001" or $input eq ".001") {
        $tool_keyword_p = 0.001;
    }
    elsif ($input eq "0.0001" or $input eq ".0001") {
        $tool_keyword_p = 0.0001;
    }
    elsif ($input eq "0") {
        $tool_keyword_p = 0;
    }

    print("Use text files (0) or wordlists (1). Currently $tool_keyword_reference_checkval: ");
    $input = <STDIN>;
    chomp($input);
    if ($input ne  "") {$tool_keyword_reference_checkval = $input};

    print("Keyword files are @tool_keyword_files. 1 to add files, 2 to add directory, 3 to remove files\n");
    $input = <STDIN>;
    chomp($input);

    if ($input eq "1") {
        print("Filenames separated by spaces: ");
        my $names = <STDIN>;
        chomp($names);
        foreach my $filename (split(" ", $names)) {
            if (-f $filename) {
                push(@tool_keyword_files, $filename);
            }
            else {
                warn("$filename could not be found.");
            }
        }
    }
    elsif ($input eq "2") {
        print("Directory: ");
        my $dirname = <STDIN>;
        chomp($dirname);
        if (-d $dirname) {
            opendir(DIR, $dirname) or warn "Could not open $dirname, $!\n";
            while (my $filename = readdir(DIR)) {
                $filename = "$dirname/$filename";
                if (-f $filename) {
                    if ($filename =~ /$global_default_extension$/)  {
                        push(@tool_keyword_files, $filename);
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
    elsif ($input eq "3") {
        for my $i (0..$#tool_keyword_files) {
            my $filename = $tool_keyword_files[$i];
            print("$i\t$filename\n");
        }
        print("Indexes of files to remove separated by spaces or 'all' to remove all: ");
        my $input = <STDIN>;
        chomp($input);
        if ($input eq "all") {
            @tool_keyword_files = ();
        }
        else {
            my @indexes = split(" ", $input);
            foreach my $del_idx (@indexes) {
                $del_idx = int($del_idx);
                splice(@tool_keyword_files, $del_idx, 1);
            }
        }
    }

    print("Save keyword FreqDist to a file after creating it (1/0). Currently $tool_keyword_save_freqdist: ");
    $input = <STDIN>;
    chomp($input);

    if ($input eq "1") {
        print("Filename to store keyword FreqDist in. Currently $keyword_outfilename: ");
        $input = <STDIN>;
        chomp($input);

        if ($input ne "") {$keyword_outfilename = $input;}
    }
}

sub view_tool_settings_keyword {
    print("P value for keyword analysis: $tool_keyword_p\n");
    print("Use text files (0) or wordlists (1): $tool_keyword_reference_checkval\n");
    print("Keyword files: @tool_keyword_files\n");
    print("Save keyword FreqDist to a file after creating it (1/0): $tool_keyword_save_freqdist\n");
    print("Filename to store keyword FreqDist in: $keyword_outfilename\n");
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

    my @queries;

    @queries = split(" ", $query);

    if ($reg_or_txt eq "1") {
        foreach $query (@queries) {
            $query = quotemeta($query);  # modify item in place
        }
    }

    print("$query\n");
    foreach my $item (@queries) {
        print("$item ");
    }
    print("\n");

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
        my @words = @{$splitter->words($text)};  # dereference the array
        for my $i (0..$#words) {
            my $match = 1;
            for my $x (0..$#queries) {
                my $query = $queries[$x];
                my $idx = $i+$x;
                my $token = $words[$idx];
                if (search_token($token, $query, $exact_or_partial) != 1) {
                    # print("$token doesn't match $query\n");
                    $match = 0;
                    last;
                }
            }
            if ($match) {
                for my $y ($i-$tool_concordance_win_length..$i+$tool_concordance_win_length) {
                    print($words[$y]);
                    print(" ");
                }
                print("\t$filename\n");
            }
        }
    }
}

sub run_ngrams {
    print("Destination directory (must be empty): ");
    my $dest = <STDIN>;
    chomp($dest);
    if (! -d $dest) {
        warn("$dest could not be found.");
        return -1;
    }

    opendir(DH, $dest) or warn "opendir() failed: $!";
    my @to_delete = readdir(DH);
    closedir(DH);
    my $num_to_delete = @to_delete;

    if ($num_to_delete > 1) {  # if there are files to delete (checking length). "." is always included
        warn("Directory supplied ($dest) is not empty. Type '1' to continue anyway (deleting the files)");
        my $input = <STDIN>;
        chomp($input);

        if ($input eq "1") {
            foreach my $file ( @to_delete ) {
                next if $file eq ".";
                unlink "$dest/$file" or warn "Could not unlink $file: $!";
            }
        }
        else {
            return -2;  # user error
        }
    }

    print("N (how many tokens in an ngram): ");
    my $n = <STDIN>;
    chomp($n);

    print("Filename to store results in: ");
    my $result_name = <STDIN>;
    chomp($result_name);

    if (($tool_ngram_case eq "0" and $global_case_sensitive eq "0")
    or $tool_ngram_case eq "2") {
        print("Creating lowercase files to be case insensitive\n");
        foreach my $filename (@filenames) {
            my $basename = basename($filename);
            open(my $in, "<", $filename) or warn("Couldn't open $filename, $!");
            open(my $out, ">", "$dest/${basename}_lower.txt") or warn("Couldn't open $dest/${basename}_lower.txt, $!");
            while(my $line = <$in>) {
                print $out lc($line);
            }
            close $in;
            close $out;
        }
    }
    else {
        print("Copying files for analysis");
        foreach my $filename (@filenames) {
            copy($filename, $dest) or warn("Failed to copy $filename to $dest");
        }
    }

    my @args = ($^X, "$tool_ngram_script_dir/count.pl", "--ngram=$n", "--token=$tool_ngram_regex_filename");

    if ($tool_ngram_nontoken_checkval eq "1") {push(@args, "--nontoken=$tool_ngram_nontoken_filename");}
    if ($tool_ngram_stop_checkval eq "1") {push(@args, "--stop=$tool_ngram_stop_filename");}
    if ($tool_ngram_freq_checkval eq "1") {push(@args, "--frequency=$tool_ngram_freq");}
    if ($tool_ngram_ufreq_checkval eq "1") {push(@args, "--ufrequency=$tool_ngram_ufreq");}
    if ($tool_ngram_newline_checkval eq "0") {push(@args, "--newline");}
    push(@args, "$dest/${result_name}_count.txt", $dest);

    print("Getting ngrams\n");
    system(@args);  # run count.pl

    print("Display results (1/0): ");
    my $display = <STDIN>;
    chomp($display);

    if ($display eq "1") {
        open(my $in, "<", "$dest/${result_name}_count.txt") or warn "Could not open $dest/${result_name}_count.txt, $!\n";
        while(my $line = <$in>) {
            print($line);
        }
    }

    if ($n lt "5" and $n gt "1") {
        @args = ($^X, "$tool_ngram_script_dir/statistic.pl", "--ngram=$n", "--precision=$tool_ngram_precision");
        if ($n eq "2") {push(@args, $tool_ngram_measure_2);}
        elsif ($n eq "3") {push(@args, $tool_ngram_measure_3);}
        elsif ($n eq "4") {push(@args, $tool_ngram_measure_4);}
        push(@args, "$dest/${result_name}_stat.txt", "$dest/${result_name}_count.txt");

        print("Calculating statistic\n");
        system(@args);  # run statistic.pl

        print("Display statistic (1/0): ");
        $display = <STDIN>;
        chomp($display);

        if ($display eq "1") {
            open(my $in, "<", "$dest/${result_name}_stat.txt") or warn "Could not open $dest/${result_name}_stat.txt, $!\n";
            while(my $line = <$in>) {
                print($line);
            }
        }
    }

    opendir(DH, $dest) or warn "opendir() failed: $!";
    my @new_files = readdir(DH);
    closedir(DH);
    foreach my $file (@new_files) {
        if (! ($file =~ /_count.txt$/) and ! ($file =~ /_stat.txt$/) ) {
            unlink "$dest/$file" or warn "Could not unlink $file: $!";
        }
    }
}

sub run_keyword {
    print("Creating FreqDist for keyword files\n");
    $keyword_freqdist = new FreqDist;

    if ($tool_keyword_reference_checkval eq "1") {
        foreach my $filename (@tool_keyword_files) {
            my $current_freq_dist = new FreqDist;
            $current_freq_dist->open_from_txt($filename);
            $keyword_freqdist->update($current_freq_dist);
        }
    }
    else {
        foreach my $filename (@tool_keyword_files) {
            my $current_freq_dist = tokenize_file($filename, $splitter);
            $keyword_freqdist->update($current_freq_dist);
        }
    }

    if ($tool_keyword_save_freqdist) {
        $keyword_freqdist->out_to_txt($keyword_outfilename);
    }

    print("Calculating keyword analysis\n");
    $keyword_obj->set_freqdist1($wordlist_freqdist);
    $keyword_obj->set_freqdist2($keyword_freqdist);

    $keyword_obj->keyword_analysis($tool_keyword_p);

    my $done = 0;
    while (! $done) {  # loop so you don't lose the whole thing because you mistyped
        print("Filename (or 0 to print to screen, or -1 to exit): ");
        my $result_name = <STDIN>;
        chomp($result_name);

        # TODO: get printing to STDOUT to work
        if ($result_name eq "0") {
            $keyword_obj->print_keywords(*STDOUT);
        }
        elsif ($result_name eq "-1") {
            $done = 1;
        }
        else {
            $keyword_obj->print_keywords($result_name);
        }
    }
}

sub main {
    my $choice = "-1";
    my $seleciton = "-1";
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
        last if ($choice eq "0");
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
                    opendir(DIR, $dirname) or warn "Could not open $dirname, $!\n";
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
            print("Indexes of files to remove separated by spaces or 'all' to remove all: ");
            my $input = <STDIN>;
            chomp($input);
            if ($input eq "all") {
                @filenames = ();
            }
            else {
                my @indexes = split(" ", $input);
                foreach my $del_idx (@indexes) {
                    $del_idx = int($del_idx);
                    splice(@filenames, $del_idx, 1);
                }
            }
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
        elsif ($choice eq "8") {
            run_ngrams();
        }
        elsif ($choice eq "9") {
            run_keyword();
        }
    }
}

main();
