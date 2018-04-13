#!/Users/cat/perl
use FreqDist;
use Path::Tiny qw( path );
use File::Basename;

$tags_names = {"cc" => "coordinating conjuction",
"cd" => "cardinal number",
"det" => "determiner",
"ex" => "existential there",
"fw" => "foreign word",
"in" => "preposition or subordinating conjuction",
"jj" => "adjective",
"jjr" => "adjective, comparative",
"jjs" => "adjective, superlative",
"ls" => "list item marker",
"md" => "modal",
"nn" => "noun, singular or mass",
"nns" => "noun, plural",
"nnp" => "proper noun, singular",
"nnps" => "proper noun, plural",
"pdt" => "predeterminer",
"pos" => "possessive ending",
"prp" => "determiner, possessive second",  # mine, yours
"prps" => "determiner, possessive",  # their, your
"prp" => "personal pronoun, singular",
"prps" => "personal pronoun, plural",
"rb" => "adverb",
"rbr" => "adverb, comparative",
"rbs" => "adverb, superlative",
"rp" => "particle",
"sym" => "symbol",
"to" => "to",
"uh" => "interjection",
"vb" => "verb, base form",
"vbd" => "verb, past tense",
"vbg" => "verb, gerund or present participle",
"vbn" => "verb, past principle",
"vbp" => "verb, non-3rd person singular present",
"vbz" => "verb, 3rd person singular present",
"wdt" => "wh-determiner",
"wp" => "wh-pronoun",
"wps" => "possesive wh-pronoun",
"wrb" => "adverb, question",
"pp" => "punctuation, sentence ender",
"ppc" => "punctuation, comma",
"ppd" => "punctuation, dollar sign",
"ppl" => "puncutation, quotation mark left",
"ppr" => "punctuation, quotation mark right",
"pps" => "punctuation, colon, semicolon, elipsis",
"lrb" => "punctuation, left bracket",
"rrb" => "punctuation, right bracket"};
$simple_tags = {
    "adjective" => ("jj", "jjr", "jjs"),
    "noun" => ("nn", "nns", "nnp", "nnps"),
    "non-proper noun" => ("nn", "nns"),
    "proper noun" => ("nnp", "nnps"),
    "possessive" => ("pos", "prp", "prps"),
    "adverb" => ("rb", "rbr", "rbs", "rp"),
    "verb" => ("vb", "vbd", "vbg", "vbn", "vbp", "vbz"),
    "question" => ("wdt", "wp", "wps", "wrb"),
    "quotation" => ("ppl", "ppr"),
    "in-sentence punctuation" => ("ppc", "pps"),
    "bracket" => ("lrb", "rrb"),
    "punctuation" => ("pp", "ppc", "ppd", "ppl", "ppr", "pps", "lrb", "rrb")
};

sub parse_tags_from_text {
    my ($text, $tag_dict, $case_sensitive) = @_;
    # tag_dict maps each tag to (the address of) a FreqDist object containing words with that tag and their frequencies
    # my $pos_dict = {};
    foreach my $tag_pair (split($text)) {
        if ($tag_pair =~ /<(.*?)>(.*?)<\/.*?>/) {
            my $tag = $1;
            my $word = $2;
            if (exists($tag_dict{$tag})) {
                $tag_dict{$tag}->add_token($word);
            }
        }
        else {
            die "Text was parsed incorrectly! Check split and regex.";
        }
    }
    return $tag_dict;  # return not necessary; this method modifies tag_dict in place
}

sub parse_tags_from_file {
    my ($filename, $tag_dict, $case_sensitive) = @_;
    # open(my $in, "<", $filename) or {
    #     print "Could not open tokenize $filename, $!\n";
    #     return 0;  # returning false
    # }
    my $text =  path("$filename")->slurp_utf8;
    if ($text) {
        return parse_tags_from_text($text, $tag_dict, $case_sensitive); # return not necessary; this method modifies tag_dict in place
    }
    else {
        print "$filename could not be opened or was empty";
        return undef;
    }
}

sub parse_tags_from_idlist {
    my ($idfilename, $tag_dir, $tag_dict, $case_sensitive) = @_;
    print "$tag_dir";
    open(my $in, "<$idfilename") or die "Could not open idfilename, $!\n";
    while(my $line = <$in>) {
        chomp($line);
        # my $full_name = "$fanfic_dir/$line.txt";
        # my $basename = basename($name, ".txt");
        my $filename = "$tag_dir/${line}_tagged.txt";
        # print($filename, "\n");
        if (-f $filename) {
            parse_tags_from_file($filename, $tag_dict, $case_sensitive);
        }
        else {
            print "$filename does not exist\n";
        }
    }
    close $in;
    return $tag_dict;  # return not necessary; this method modifies tag_dict in place
}

sub combine_tags {
    my ($tag_dict, $combine_maps);
    my $combined_tags = {};
    scalar keys $combine_maps;
    foreach my $simple_tag ($combine_maps) {
        my $simple_freqdist = new FreqDist;
        scalar keys $tag_dict;
        foreach my $tag ($combine_maps{$simple_tag}) {
            if (exists($tag_dict{$tag})) {
                $simple_freqdist->update($tag_dict{$tag});
            }
        }
        $combined_tags{$simple_tag} = $simple_freqdist;
    }
    return $combined_tags;
}

sub tag_dict_to_files {
    my ($tag_dict, $path) = @_;  # tag_dict is reference
    scalar keys $tag_dict;
    foreach my $tag ($tag_dict) {
        my $filename = "$path-$tag.txt";  # TODO: figure out how to change hyphen to underscore
        $tag_dict{$tag}->out_to_txt($path);
    }
}
