package App::JESP::Cmd::Command::deploy;

use base qw/App::JESP::Cmd::CommandJESP/;
use strict; use warnings;
use Log::Any qw/$log/;

=head1 NAME

App::JESP::Cmd::Command::deploy - Deploy Database patches in the DB

=cut

=head2 abstract

=head2 description

=head2 execute

See L<App::Cmd>

=cut

sub abstract { "Deploy patches from <home>/plan.json in the DB" }
sub description { "Deploys patches from <home>/plan.json in the DB and records their applications in the Meta tables" }
sub execute {
    my ($self, $opt, $args) = @_;
    $self->{__jesp}->deploy();
}

1;
