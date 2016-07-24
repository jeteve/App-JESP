package App::JESP::Driver::SQLite;

use Moose;
extends qw/App::JESP::Driver/;

=head1 NAME

App::JESP::Driver::SQLite - SQLite driver. Subclasses App::JESP::Driver

=cut

=head2 apply_sql

Specific version that allows multiple statements in SQLite.
See superclass.

=cut

sub apply_sql{
    my ($self, $sql) = @_;
    # note that we reuse the same dbh as the application.
    my $dbh = $self->jesp()->dbix_simple()->dbh();
    local $dbh->{sqlite_allow_multiple_statements} = 1;
    return $dbh->do( $sql ) // confess( $dbh->errstr() );
}

__PACKAGE__->meta->make_immutable();
1;
