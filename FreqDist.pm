#!/Users/cat/perl
use strict;
use warnings;
use diagnostics;
use lib '/Users/cat/perl5/lib/perl5';
package FreqDist;

sub new {
    my $class = shift;
    my $self = {
        _types = 0;
        _tokens = 0;
        _hash = {};
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
    keys $self->{_hash}; # reset the internal iterator so a prior each() doesn't affect the loop
    my $max_token;
    my $max_freq = 0;
    while(my($token, $freq) = each $self->{_hash}) {
        if ($freq > max_freq) {
            max_token = $token;
            max_freq = $freq;
        }
    }
    return ($max_token, $max_freq)
}

sub out_to_txt($filename) {
    open(my $out, ">", $filename) or die "Couldn't open $filename, $!";
    foreach my $key (sort { $self->{_hash}{$b} <=> $self->{_hash}{$a} } keys $self->{_hash}) {
        printf "%s\t%d\n", $key, $self->{_hash}{$key};
    }
}

sub update(FreqDist) {

}
