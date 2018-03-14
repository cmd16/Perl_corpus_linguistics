#!/Users/cat/perl
use strict;
use warnings;
# use diagnostics;
# use Switch;
use lib '/Users/cat/perl5/lib/perl5';
package FreqDist;

sub new {
    my $class = shift;
    my $self = {
        _types => 0,
        _tokens => 0,
        _hash => {},
        _keyword_dicts => ()
    };
    bless $self, $class;
    return $self;
}

sub get_types {
    return $self->{_types};
}

sub get_tokens {
    return $self->{_tokens};
}

sub get_hash {
    return $self->{_hash};
}

sub get_count($token) {
    return $self->{_hash}{$token};
}

sub get_prob_token($token) {
    return $self->{_hash}{$token} / $self->{_tokens};
}

sub get_prob_type($type) {
    return 1 / $self->{_types};
}

sub get_normalized_freq($token) {
    return $self->{_hash}{$token} / $self->{_tokens} * 1000000;
}

sub add_token($token) {
    $self->{_hash}{$token} += 1;
    $self->{_tokens} += 1;
    $self->{_types} = keys % $self->{_hash};
}

sub remove_type($type) {
    my $tokens = $self->{_hash}{$type};
    delete $self->{_hash}{$type};
    $self->{_tokens} -= $tokens;
    $self->{_types} -= 1;
}

sub add_token_freq($token, $freq) {
    $self->{_hash}{$token} += $freq;
    $self->{_tokens} += $freq;
    $self->{_types} = keys % $self->{_hash};
}

sub get_max {
    my $max_token;
    my $max_freq = 0;
    keys $self->{_hash}; # reset the internal iterator so a prior each() doesn't affect the loop
    while(my($token, $freq) = each $self->{_hash}) {
        if ($freq > max_freq) {
            max_token = $token;
            max_freq = $freq;
        }
    }
    return ($max_token, $max_freq)
}

sub clear_hash {
    $self->{_hash} = {};
    $self->{_types} = 0;
    $self->{_tokens} = 0;
    $self->{_keyword_dicts} = ();
}

sub out_to_txt($filename) {
    open(my $out, ">", $filename) or die "Couldn't open $filename, $!";
    printf $out "#Word types: %d\n", $self->{_types};
    printf $out "#Word tokens: %d\n", $self->{_tokens};
    foreach my $key (sort { $self->{_hash}{$b} <=> $self->{_hash}{$a} } keys $self->{_hash}) {
        printf $out "%s\t%d\n", $key, $self->{_hash}{$key};
    }
    close $out;
}

sub open_from_txt($filename) {
    # clear out the old values
    foreach my $key ($self->{_hash}) {
        $self->remove_type($key);
    }
    # read in the new values
    open(my $in, "<", $filename) or die "Couldn't open $filename, $!";
    while($line = <$in>) {
        next if $. < 2;  # skip first 2 lines which have types and tokens (https://stackoverflow.com/questions/14393295/best-way-to-skip-a-header-when-reading-in-from-a-text-file-in-perl)
        my @word_and_freq = split(/\t/, $line);
        $self->add_token_freq($word_and_freq[0], $word_and_freq[1]);
    }
    close $in;
}

sub update($other) {  # TODO: check declaration
    %other_hash = $other->get_hash(); # reset the internal iterator so a prior each() doesn't affect the loop
    while(my($token, $freq) = each $other_hash) {
        $self->add_token_freq($token, $freq);
    }
}

sub keyword_analysis($other, $p) {  # TODO: check declaration
    my $crit;
    switch($p) {
        case 0.05 { $crit = 3.84; }
        case 0.01 { $crit = 6.63; }
        case 0.001 { $crit = 10.83; }
        case 0.0001 { $crit = 15.13; }
        else { $crit = 0; }
    }
    my %keyword_hash = {};
    keys $self->{_hash}; # reset the internal iterator so a prior each() doesn't affect the loop
    while(my($token, $freq1) = each $self->{_hash}) {
        my $freq2 = $other->get_count($token);
        my $norm1 = $self->get_normalized_freq($token);
        my $norm2 = $other->get_normalized_freq($token);
        my $num = ($freq1 + $freq2) / ($tokens1 + $tokens2);
        my $E1 = $tokens1 * $num;
        my $E2 = $tokens2 * $num;
        my $keyness = $E2 > 0? 2 * ($freq1 * math.log($freq1/$E1) + ($freq2 * math.log($freq2/$E2))) : 2 * ($freq1 * math.log($freq1/$E1));
        if ($keyness < $crit) {
            next;
        }
        %keyword_hash{$token} = {'keyness'=> $keyness, 'freq1'=>freq1, 'norm1'=>$norm1, 'freq2'=>$freq2, 'norm2'=>$norm2};
    }
    push($self->{_keyword_dicts}, %keyword_hash);  # TODO: change this later?
}

sub print_keywords(@filenames, @indexes) {
    foreach my $index (@indexes) {
        my $filename = @filenames[$index];
        open(my $out, ">", $filename) or die "Couldn't open $filename, $!";
        %keyword_hash = $self->{_keyword_dicts}[$index];
        foreach my $key (sort { $keyword_hash{$a}{'keyness'} <=> $keyword_hash{$b}{'keyness'} } keys %keyword_hash) {
            printf ($out "%s\t%f\t%f\t%f\t%f\t%f", $key, %keyword_hash{$key}{'keyness'}, %keyword_hash{$key}{'freq1'},
            %keyword_hash{$key}{'norm1'}, %keyword_hash{$key}{'freq2'}, %keyword_hash{$key}{'norm2'});
        }
        close($out);
    }
}
