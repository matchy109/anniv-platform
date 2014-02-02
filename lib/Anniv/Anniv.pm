package Anniv::Anniv;

use strict;
use warnings;

use Anniv::AnnivData;
use Anniv::Config;
use Common::Log;
use LWP::UserAgent;
use HTML::TreeBuilder;
use DateTime;
use DBI;

my @anniv_list;
my $log = Common::Log->new();

sub new {
    my $class = shift;

    my $conf = Anniv::Config->get_instance();
    my ( $mday, $month ) = ( localtime(time) )[ 3 .. 4 ];
    $month += 1;

    my $self = {
        base_url        => $conf->{base_url},
        month_parameter => $conf->{month_parameter},
        day_parameter   => $conf->{day_parameter},
        html_attribute  => $conf->{html_attribute},
        db_hostname     => $conf->{db_hostname},
        db_port         => $conf->{db_port},
        db_name         => $conf->{db_name},
        db_user         => $conf->{db_user},
        db_password     => $conf->{db_password},
        month           => $month,
        day             => $mday
    };

    $self = bless $self, $class;
    $self->create_url()->fetch_results()->parse_results()->insert_anniv_data();

    return $self;
}

sub create_url {
    my $self = shift;

    $self->{url} = sprintf( "%s/?%s=%d&%s=%d",
        $self->{base_url},      $self->{month_parameter}, $self->{month},
        $self->{day_parameter}, $self->{day} );
    $log->info("Connection URL : $self->{url}");
    return $self;
}

sub fetch_results {
    my $self = shift;

    my $ua       = LWP::UserAgent->new;
    my $response = $ua->get( $self->{url} );

    if ( $response->is_success ) {
        $self->{results} = $response->content;
    }
    else {
        die $response->message();
    }

    return $self;
}

sub parse_results {
    my $self = shift;

    my $tree = HTML::TreeBuilder->new;
    $tree->parse( $self->{results} );

    my @items = $tree->look_down( 'class', $self->{html_attribute} )->find('a');
    foreach my $item (@items) {
        my $anniv_data = Anniv::AnnivData->new();

        $anniv_data->name( $item->as_text );
        $anniv_data->month( $self->{month} );
        $anniv_data->day( $self->{day} );

        push( @anniv_list, $anniv_data );
    }
    $log->info( "Number of anniv_data : " . ( $#items + 1 ) );

    return $self;
}

sub insert_anniv_data {
    my $self = shift;

    my $db = DBI->connect(
        "DBI:mysql:$self->{db_name}:$self->{db_hostname}:$self->{db_port}",
        $self->{db_user},
        $self->{db_password},
        {
            mysql_enable_utf8    => 1,
            mysql_auto_reconnect => 0
        }
    ) or die "Can not connect to database: " . DBI->errstr;

    my $sql =
      "INSERT IGNORE INTO anniv_list (name, month, day) VALUE (?, ?, ?)";
    my $sth = $db->prepare($sql)
      or die "Can not prepare statement: " . DBI->errstr;

    foreach my $data (@anniv_list) {
        $sth->execute( $data->{name}, $data->{month}, $data->{day} )
          or die "Can not execute statement: " . $sth->errstr;

        $sth->finish;
    }

    $db->disconnect;

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
