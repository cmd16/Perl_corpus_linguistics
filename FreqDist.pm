#!/Users/cat/perl
use strict;
use warnings;
package FreqDist;
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
    return 0;
}

sub get_prob_token {
    my ($self, $token) = @_;
    if ($self->get_tokens() == 0) { return 0; }
    return $self->get_count($token) / $self->get_tokens();
}

sub get_prob_type {
    my ($self, $type) = @_;
    if ($self->get_types() == 0) { return 0; }
    return 1 / $self->get_types();
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
    foreach my $key (sort { $self->{_hash}{$b} <=> $self->{_hash}{$a}
                            or $a cmp $b } keys $self->{_hash}) {
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

1;
