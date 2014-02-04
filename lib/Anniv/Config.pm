package Anniv::Config;

use strict;
use warnings;

use File::Basename;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

my $singleton;
my @options = ();

sub get_instance {
    return $singleton;
}

sub usage {
    my @usage = `perldoc $0`;
    print @usage;
    exit(1);
}

sub set_default {
    my $self = shift;

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    my $log_dir = "/var/log/anniv";
    my $log_file =
      sprintf( "anniv-%04d%02d%02d.log", $year + 1900, $mon + 1, $mday );
    $self->log_dir("$log_dir");
    $self->log_file("$log_file");

    $self->month($mon+1);
    $self->day($mday);

    $self->mail_from("");
    $self->mail_to("");

    $self->db_hostname("localhost");
    $self->db_port("3306");

    return $self;
}

sub get_cl_option {
    my $self   = shift;
    my %optctl = ();
    my $conf   = "";

    local (@ARGV) = @ARGV;
    GetOptions(
        \%optctl,
        'o|option:s' => \@options,
        'c:s'        => \$conf,
        'h|help:s'
    );

    if ( defined( $optctl{"h"} ) || defined( $optctl{"help"} ) || $conf eq '' )
    {
        &usage();
    }
    $self->config_file( ${conf} );

    return $self;
}

sub set_cl_option {
    my $self = shift;

    foreach my $option (@options) {
        my @tmp = sprit( '=', $option );
        if ( $tmp[0] eq "config_file" ) { next; }
        if ( $#tmp == 1 ) {
            if ( exists $self->{"$tmp[0]"} ) {
                $self->{"$tmp[0]"} = $tmp[1];
            }
            else {
                die "fail";
            }
        }
    }
    return $self;
}

sub set_configfile_option {
    my $self = shift;

    if ( -f $self->{config_file} ) {
        my $conf = do $self->{config_file} or die $!;

        foreach my $key ( keys %{$conf} ) {
            $self->{"$key"} = $conf->{$key};
        }
    }
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

BEGIN {
    $singleton = bless {}, __PACKAGE__;
    $singleton->set_default->get_cl_option->set_configfile_option
      ->set_cl_option;
}

1;

__END__

=head1 AUTHOR

Masahiko TOKUMARU

=cut

# vim: ts=4 sw=4 et ft=perl:
