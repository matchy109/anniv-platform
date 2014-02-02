#!/urs/bin/env perl

=head1 NAME

update_anniv.pl

=head1 DESCRIPTION

fetch anniv data from setting url and update data on DB

=head1 USAGE

 perl update_anniv.pl -c your_configurations.conf
 perl update_anniv.pl [-h|help]

 you need configuration file for this script and you should set following options in cofigration file.

 ex)
  base_url => "http://www.anniv.co.jp",
  month_parameter => "month",
  day_parameter => "day",
  html_attribute => "anniv",
  log_dir => "/var/log/anniv",
  mail_to => "mail_to\@example.com",
  mail_from => "mail_from\@example.com",
  db_hostname => "db_host@example.com",
  db_port=> "3306",
  db_name => "anniv_db",
  db_user => "anniv_user",
  db_password => "anniv_user"

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Anniv::Config;
use Anniv::Anniv;
use Common::Log;
use Common::Mail;

our $VERSION = "1.0";

sub main() {
    my $conf = Anniv::Config->get_instance();
    my $log  = Common::Log->new();

    eval {
        $log->info("Start fetching anniv data");
        my $anniv = Anniv::Anniv->new();
        $log->info("Finish fetching anniv data");

        exit 0;
    };

    if ($@) {
        my $error_message = $@;
        eval {
            my $mail = Common::Mail->new();
            $mail->error->body("$error_message")->send();
            $log->error("$error_message");
        };
        exit 1;
    }
}

main() if ( __FILE__ eq $0 );

1;
__END__

=head1 AUTHOR

Masahiko TOKUMARU

=cut

# vim: ts=4 sw=4 et ft=perl:
