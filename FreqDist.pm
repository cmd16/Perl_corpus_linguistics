#!/Users/cat/perl
use strict;
use warnings;
package FreqDist;
use Data::Dumper qw(Dumper);
# use diagnostics;
# use Switch;
use lib '/Users/cat/perl5/lib/perl5';

sub new {
    my $class = shift;
    my %hash;
    my %keyword_dict;

    my $self = {
        _types => 0,
        _tokens => 0,
        _hash => \%hash,
        _keyword_dict => \%keyword_dict,
    };
    bless $self, $class;
    return $self;
}

sub get_types {
    my ($self) = @_;
    return $self->{_types};
}

sub get_tokens {
    my ($self) = @_;
    return $self->{_tokens};
}

sub get_keys {
    my ($self) = @_;
    my @keys = ();
    foreach my $key (sort { $self->{_hash}{$b} <=> $self->{_hash}{$a} } keys $self->{_hash}) {
        push(@keys, $key);
    }
    return @keys;
}

sub get_hash {
    my ($self) = @_;
    return $self->{_hash};
}

sub get_count {
    my ($self, $token) = @_;
    my $count = $self->{_hash}{$token};
    if ($count) {
        return $count;
    }
    else {
        return 0;
    }
}

sub get_prob_token {
    my ($self, $token) = @_;
    if ($self->get_tokens() == 0) {
        return 0;
    }
    else {
        return $self->get_count($token) / $self->get_tokens();
    }
}

sub get_prob_type {
    my ($self, $type) = @_;
    if ($self->get_types() == 0) {
        return 0;
    }
    else {
        return 1 / $self->get_types();
    }
}

sub get_normalized_freq {
    my ($self, $token) = @_;
    if ($token eq "" or $self->get_tokens() == 0) { return 0; }
    return $self->get_count($token) / $self->get_tokens() * 1000000;
}

sub add_token {
    my ($self, $token) = @_;
    $self->{_hash}{$token} += 1;
    $self->{_tokens} += 1;
    $self->{_types} = scalar keys %{$self->{_hash}};
}

sub remove_type {
    my ($self, $type) = @_;
    my $tokens = $self->get_count($type);
    delete $self->{_hash}{$type};
    $self->{_tokens} -= $tokens;
    $self->{_types} -= 1;
}

sub add_token_freq {
    my ($self, $token, $freq) = @_;
    if ($freq > 0) {
        $self->{_hash}{$token} += $freq;
        $self->{_tokens} += $freq;
        $self->{_types} = keys %{$self->{_hash}};
    }
}

sub get_max {
    my ($self) = @_;
    my $max_token;
    my $max_freq = 0;
    scalar keys $self->{_hash}; # reset the internal iterator so a prior each() doesn't affect the loop
    while(my($token, $freq) = each $self->{_hash}) {
        if ($freq > $max_freq) {
            $max_token = $token;
            $max_freq = $freq;
        }
    }
    return ($max_token, $max_freq)
}

sub clear_hash {  # TODO: fix this
    my ($self) = @_;
    $self->{_hash} = {};
    $self->{_types} = 0;
    $self->{_tokens} = 0;
    $self->{_keyword_dict} = {};
}

sub out_to_txt {
    my ($self, $filename) = @_;
    open(my $out, ">", $filename) or die "Couldn't open $filename, $!";
    printf $out "#Word types: %d\n", $self->{_types};
    printf $out "#Word tokens: %d\n", $self->{_tokens};
    printf $out "#Search results: 0\n";
    my $rank = 1;
    foreach my $key (sort { $self->{_hash}{$b} <=> $self->{_hash}{$a} } keys $self->{_hash}) {
        printf $out "%d\t%d\t%s\n", $rank, $self->{_hash}{$key}, $key;
        $rank += 1;
    }
    close $out;
}

sub open_from_txt {
    my ($self, $filename) = @_;
    # clear out the old values
    $self->clear_hash();
    # read in the new values
    open(my $in, "<", $filename) or die "Couldn't open $filename, $!";
    while(my $line = <$in>) {
        next if $. < 2;  # skip first 2 lines which have types and tokens (https://stackoverflow.com/questions/14393295/best-way-to-skip-a-header-when-reading-in-from-a-text-file-in-perl)
        chomp($line);  # get rid of newline at end
        my @word_and_freq = split(/\t/, $line);
        my $len = @word_and_freq;
        next if $len < 3;
        my $freq = $word_and_freq[1];
        $freq = int($freq);
        $self->add_token_freq($word_and_freq[2], $freq);
    }
    close $in;
}

sub update {  # TODO: check declaration
    my ($self, $other) = @_;
    my $other_hash = $other->get_hash(); # reset the internal iterator so a prior each() doesn't affect the loop
    while(my($token, $freq) = each %{$other_hash}) {
        $self->add_token_freq($token, $freq);
    }
}

sub keyword_analysis {  # TODO: check declaration
    my ($self, $other, $p) = @_;
    my $crit;
    # switch($p) {
    #     case 0.05 { $crit = 3.84; }
    #     case 0.01 { $crit = 6.63; }
    #     case 0.001 { $crit = 10.83; }
    #     case 0.0001 { $crit = 15.13; }
    #     case 0 { $crit = 0; }
    #     else { $crit = 6.63; }
    # }
    if ($p == 0.05) { $crit = 3.84; }
    elsif ($p == 0.01) { $crit = 6.63; }
    elsif ($p == 0.001) { $crit = 10.83; }
    elsif ($p == 0.0001) { $crit = 15.13; }
    elsif ($p == 0){ $crit = 0; }
    else {
        warn("Invalid p value. Setting p value to .01\n");
        $crit = 6.63;
    }
    $crit = 6.63;  # TODO: change later
    my %keyword_hash;
    my $types1 = $self->get_types();
    my $types2 = $other->get_types();
    scalar keys $self->{_hash}; # reset the internal iterator so a prior each() doesn't affect the loop
    # print("hash\n");
    # print Dumper($self->{_hash});
    while(my($token, $freq1) = each $self->{_hash}) {
        my $freq2 = $other->get_count($token);
        my $norm1 = $self->get_normalized_freq($token);
        my $norm2 = $freq2 == 0? 0 : $other->get_normalized_freq($token);
        my $tokens1 = $self->get_tokens();
        my $tokens2 = $other->get_tokens();
        my $num = ($freq1 + $freq2) / ($tokens1 + $tokens2);
        my $E1 = $tokens1 * $num;
        my $E2 = $tokens2 * $num;

        my $keyness;
        if ($freq2 == 0 or $E2 == 0) {
            $keyness = 2 * ($freq1 * log($freq1/$E1));
        }
        else {
            $keyness = 2 * ($freq1 * log($freq1/$E1) + ($freq2 * log($freq2/$E2)));
        }
        if ($keyness < $crit) {
            next;
        }
        $keyword_hash{$token} = {'keyness'=> $keyness, 'freq1'=>$freq1, 'norm1'=>$norm1, 'freq2'=>$freq2, 'norm2'=>$norm2};
        print $keyword_hash{$token};
        # ({'keyness'=> $keyness, 'freq1'=>$freq1, 'norm1'=>$norm1, 'freq2'=>$freq2, 'norm2'=>$norm2}, ($types1, $tokens1), ($types2, $tokens));
        print Dumper(\%keyword_hash);
    }
    $self->{_keyword_dict} = \%keyword_hash;  # TODO: deal with types and tokens
}

sub print_keywords {
    my ($self, $filename) = @_;  # @indexes is a list of indexes of keyword hashes
    open(my $out, ">", $filename) or warn("Couldn't open $filename, $!");
    # my %keyword_hash = {$self->{_keyword_dict}};
    # print Dumper($self->{_keyword_dict});
    # print Dumper(\%keyword_hash);
    # printf("%d\t%d", $self->get_types(), $self->get_tokens());
    printf($out "# Corpus 1:\t%d\t%d\n", $self->get_types(), $self->get_tokens());  # TODO: deal with types and tokens
    printf($out "# Corpus 2:\t%d\t%d\n", 0, 0);  # TODO: deal with types and tokens
    printf($out "# %s\t%s\t%s\t%s\t%s\t%s\n", "word", "keyness", "freq1",
    "norm1", "freq2", "norm2");
    foreach my $key (sort { $self->{_keyword_dict}{$a}{'keyness'} <=> $self->{_keyword_dict}{$b}{'keyness'} } keys $self->{_keyword_dict}) {
        printf($out "%s\t%f\t%d\t%f\t%d\t%f\n", $key, $self->{_keyword_dict}{$key}{'keyness'}, $self->{_keyword_dict}{$key}{'freq1'},
        $self->{_keyword_dict}{$key}{'norm1'}, $self->{_keyword_dict}{$key}{'freq2'}, $self->{_keyword_dict}{$key}{'norm2'});
    }
    close($out);
}
1;
