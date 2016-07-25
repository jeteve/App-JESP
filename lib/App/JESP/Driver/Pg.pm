package App::JESP::Driver::Pg;

use Moose;
extends qw/App::JESP::Driver/;

=head1 NAME

App::JESP::Driver::Pg - Pg (postgresql) driver. Subclasses App::JESP::Driver

=cut

__PACKAGE__->meta->make_immutable();
1;
