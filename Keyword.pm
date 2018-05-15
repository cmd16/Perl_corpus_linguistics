#!/Users/cat/perl
use strict;
use warnings;
package Keyword;
use FreqDist;
use Data::Dumper;

sub new {
    my $class = shift;
    my (%args) = @_;
    my %keyword_dict;
    my $freqdist1 = $args{freqdist1} // new FreqDist;  # // is defined-or operator introduced in Perl 5.10
    my $freqdist2 = $args{freqdist2} // new FreqDist;
    my $name1 = $args{name1} // "Corpus 1";
    my $name2 = $args{name2} // "Corpus 2";

    my $self = {
        _freqdist1 => $freqdist1,  # make empty FreqDist because this will be easier to deal with later
        _freqdist2 => $freqdist2,
        _name1 => $name1,
        _name2 => $name2,
        _keyword_dict => \%keyword_dict,
    };
    bless $self, $class;
    return $self;
}

sub set_name1 {
    my ($self, $name1) = @_;  # TODO: type checking in case user gives non-string?
    $self->{_name1} = $name1;
}

sub get_name1 {
    my ($self) = @_;
    return $self->{_name1};
}

sub set_name2 {
    my ($self, $name2) = @_;  # TODO: type checking in case user gives non-string?
    $self->{_name2} = $name2;
}

sub set_freqdist1 {
    my ($self, $freqdist1) = @_;
    $self->{_freqdist1} = $freqdist1;
}

sub get_freqdist1 {
    my ($self) = @_;
    return $self->{_freqdist1};
}

sub set_freqdist2 {
    my ($self, $freqdist2) = @_;
    $self->{_freqdist2} = $freqdist2;
}

sub get_freqdist2 {
    my ($self) = @_;
    return $self->{_freqdist2};
}

sub swap_freqdists {
    my ($self) = @_;
    my $new_1 = $self->{_freqdist2};
    my $new_2 = $self->{_freqdist1};
    $self->set_freqdist1($new_1);
    $self->set_freqdist2($new_2);
}

sub get_tokens {
    my ($self) = @_;
    return keys $self->{_keyword_dict};
}

sub get_token_stats {
    my ($self, $token) = @_;
    if ($token eq "") {
        return {};
    }
    return $self->{_keyword_dict}{$token};
}

sub get_token_keyness {
    my ($self, $token) = @_;
    my %entry = $self->get_token_stats($token);
    if (%entry) {
        return $entry{'keyness'};
    }
    return -1;
}

sub keyword_analysis {
    my ($self, $p) = @_;
    my $crit;
    if ($p == 0.05) { $crit = 3.84; }
    elsif ($p == 0.01) { $crit = 6.63; }
    elsif ($p == 0.001) { $crit = 10.83; }
    elsif ($p == 0.0001) { $crit = 15.13; }
    elsif ($p == 0){ $crit = 0; }
    else {
        warn("Invalid p value. Setting p value to .01\n");
        $crit = 6.63;
    }
    my %keyword_hash;
    my $types1 = $self->{_freqdist1}->get_types();
    my $types2 = $self->{_freqdist2}->get_types();

    printf("# Corpus 1:\t%d\t%d\n", $self->{_freqdist1}->get_types(), $self->{_freqdist1}->get_tokens());
    printf("# Corpus 2:\t%d\t%d\n", $self->{_freqdist2}->get_types(), $self->{_freqdist2}->get_tokens());

    scalar keys $self->{_keyword_dict}; # reset the internal iterator so a prior each() doesn't affect the loop
    while(my($token, $freq1) = each $self->{_freqdist1}->get_hash()) {
        my $freq2 = $self->{_freqdist2}->get_count($token);
        my $norm1 = $self->{_freqdist1}->get_normalized_freq($token);
        my $norm2 = $freq2 == 0? 0 : $self->{_freqdist2}->get_normalized_freq($token);

        next if ($norm2 > $norm1);  # avoid double counting when going both ways
        # Note: double counting will still occur when $norm2 == $norm1, but in that case the log likelihood is 0 so we don't care

        my $tokens1 = $self->{_freqdist1}->get_tokens();
        my $tokens2 = $self->{_freqdist2}->get_tokens();
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

        next if ($keyness < $crit);

        $keyword_hash{$token} = {'keyness'=> $keyness, 'freq1'=>$freq1, 'norm1'=>$norm1, 'freq2'=>$freq2, 'norm2'=>$norm2};
    }
    $self->{_keyword_dict} = \%keyword_hash;  # TODO: deal with types and tokens
    # print(Dumper($self->{_keyword_dict}));
    return \%keyword_hash;  # return hash in case we want to use it later
}

sub print_keywords {
    my ($self, $filename) = @_;
    my $out;
    my $success;

    if ($filename eq "STDOUT") {
        $success = 0;  # did not open a file
        $out = *STDOUT;
    }
    else {
        $success = open($out, ">", $filename);
        if (! $success) {
            warn "Couldn't open $filename, $!\n";
            return -1;
        }
    }

    printf($out "# Corpus 1:\t%d\t%d\n", $self->{_freqdist1}->get_types(), $self->{_freqdist1}->get_tokens());
    printf($out "# Corpus 2:\t%d\t%d\n", $self->{_freqdist2}->get_types(), $self->{_freqdist2}->get_tokens());
    printf($out "# %s\t%s\t%s\t%s\t%s\t%s\n", "word", "keyness", "freq1",
    "norm1", "freq2", "norm2");
    foreach my $key (sort { $self->{_keyword_dict}{$a}{'keyness'} <=> $self->{_keyword_dict}{$b}{'keyness'}
                            or $a cmp $b } keys $self->{_keyword_dict}) {
        printf($out "%s\t%f\t%d\t%f\t%d\t%f\n", $key, $self->{_keyword_dict}{$key}{'keyness'}, $self->{_keyword_dict}{$key}{'freq1'},
        $self->{_keyword_dict}{$key}{'norm1'}, $self->{_keyword_dict}{$key}{'freq2'}, $self->{_keyword_dict}{$key}{'norm2'});
    }
    close($out) if $success;  # don't close STDOUT
}

1;
