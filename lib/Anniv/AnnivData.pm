package Anniv::AnnivData;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {
        name  => undef,
        month => undef,
        day   => undef
    };

    return bless $self, $class;
}

sub name {
    my $self = shift;

    if (@_) {
        $self->{name} = $_[0];
    }
    return $self->{name};
}

sub month {
    my $self = shift;

    if (@_) {
        $self->{month} = $_[0];
    }
    return $self->{month};
}

sub day {
    my $self = shift;

    if (@_) {
        $self->{day} = $_[0];
    }
    return $self->{day};
}

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    my (@arg) = @_;

    if ( $AUTOLOAD =~ m/.*::(.*)/ ) {
        if ( $1 eq 'DESTROY' ) { return }
        my $field = $1;
        if ( $#arg >= 0 ) {
            $self->{$field} = $arg[0];
        }
        else {
            return $self->{$field};
        }
    }
    return $self;
}

1;
__END__

=head1 AUTHOR

Masahiko TOKUMARU

=cut

# vim: ts=4 sw=4 et ft=perl:
