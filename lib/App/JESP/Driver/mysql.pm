package App::JESP::Driver::mysql;

use Moose;
extends qw/App::JESP::Driver/;

use File::Which qw//;
use IPC::Run qw//;
use Log::Any qw/$log/;

use Data::Dumper;
use DBI;
use DBD::mysql;

=head1 NAME

App::JESP::Driver::mysql - mysql driver. Subclasses App::JESP::Driver

=cut

has 'mysql' => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_mysql{
    my ($self) = @_;
    my $mysql = File::Which::which('mysql');
    unless( $mysql ){ die "Cannot find 'mysql' in path ".$ENV{PATH}.". Set this in the plan."; }
    unless( -x $mysql ){
        die "Found '$mysql' but it is not executable\n";
    }
    $log->info("Found mysql client at '$mysql'");
    return $mysql;
}

=head2 apply_sql

Specificaly apply sql to mysql by using the command line client.

See Superclass.

=cut

sub apply_sql{
    my ($self, $sql) = @_;
    my $mysql = $self->mysql();

    my @cmd = ( $mysql );

    # Time to build the command according to the dsn properties
    my $properties = {};
    {
        my ($scheme, $driver, $attr_string, $attr_hash, $driver_dsn) = DBI->parse_dsn( $self->jesp()->dsn() );
        DBD::mysql->_OdbcParse( $driver_dsn , $properties , [] );
        $properties->{user} ||= $self->jesp()->username();
        $properties->{password} ||= $self->jesp()->password();
        $log->trace('mysql properties: '.Dumper( $properties ));
    }

    push @cmd , '-B'; # This is a batch command. We dont want interactive at all.

    if( my $user = $properties->{user} ){
        push @cmd , ( '-u' , $user );
    }
    if( my $database = $properties->{database} ){
        push @cmd , ( '-D' , $database );
    }
    if( my $host = $properties->{host} ){
        push @cmd , ( '-h' , $host );
    }
    if( my $port = $properties->{port} ){
        push @cmd , ( '-P' , $port );
    }
    if( my $mysql_socket = $properties->{mysql_socket} ){
        push @cmd , ( '-S' , $mysql_socket );
    }
    if( my $password = $properties->{password} ){
        push @cmd , ( '-p', $password );
    }


    my $on_stdout = sub{
        $log->info( @_ );
    };
    my $on_stderr = sub{
        $log->warn( @_ );
    };

    # Outside testing, be verbose.
    local $ENV{IPCRUNDEBUG} = 'basic' unless( $ENV{AUTOMATED_TESTING} || $ENV{HARNESS_ACTIVE} );
    IPC::Run::run( \@cmd, \$sql , $on_stdout , $on_stderr ) or die join(' ', @cmd).": $?\n";
    $log->info("Done");
}

__PACKAGE__->meta->make_immutable();
1;
