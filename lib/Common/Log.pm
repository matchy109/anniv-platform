package Common::Log;

use strict;
use warnings;

use Anniv::Config;

sub new {
    my $class = shift;
    my $conf  = Anniv::Config->get_instance();
    my $self  = {
        dir     => $conf->{log_dir},
        file    => $conf->{log_file},
        level   => "",
        message => ""
    };

    return bless $self, $class;
}

sub error {
    my $self = shift;
    my ($message) = @_;

    $self->{level}   = "ERROR";
    $self->{message} = $message;
    $self->write;

    return $self;
}

sub info {
    my $self = shift;
    my ($message) = @_;

    $self->{level}   = "INFO";
    $self->{message} = $message;
    $self->write;

    return $self;
}

sub write {
    my $self = shift;
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    my $now = sprintf(
        "%04d-%02d-%02d %02d:%02d:%02d",
        $year + 1900,
        $mon + 1, $mday, $hour, $min, $sec
    );

    open( my $fp, ">>:utf8", "$self->{dir}/$self->{file}" ) or die "$!";
    print ${fp} "[$now][$self->{level}] $self->{message}\n";
    close($fp);
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
