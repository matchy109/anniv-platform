package Common::Mail;

use strict;
use warnings;

use Anniv::Config;

sub new {
    my $class = shift;
    my $conf  = Anniv::Config->get_instance();
    my $self  = {
        to      => $conf->{mail_to},
        from    => $conf->{mail_from},
        subject => "",
        body    => ""
    };

    return bless $self, $class;
}

sub error {
    my $self = shift;

    $self->{subject} = "[ERROR]";
    return $self;
}

sub info {
    my $self = shift;

    $self->{subject} = "[INFO]";
    return $self;
}

sub send {
    my $self = shift;

    my ( $sec, $min, $hour, $mday, $mon, $year, $month, $wday, $isdst ) =
      localtime(time);
    my $send_date = sprintf(
        "%04d-%02d-%02d %02d:%02d:%02d",
        $year + 1900,
        $month + 1, $mday, $hour, $min, $sec
    );

    open( MAIL, "| /usr/sbin/sendmail -t" );
    print MAIL "From: $self->{from}\n";
    print MAIL "To: $self->{to}\n";
    print MAIL "Subject: $self->{subject}\n";
    print MAIL "\n";
    print MAIL "%-13s %s\n", "Date:",    "${send_date}";
    print MAIL "%-13s %s\n", "Message:", "$self->{body}";
    close(MAIL);

    return $self;
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
