#! perl -w

use Test::Most;

BEGIN{
    eval "use Test::mysqld";
    plan skip_all => "Test::mysqld is required for this test" if $@;
    eval "use Test::PostgreSQL";
    plan skip_all => "Test::PostgreSQL is required for this test" if $@;
}

use App::JESP;
use File::Spec;

# use Log::Any::Adapter qw/Stderr/;

# First something with SQLite.
my @connection_params = ({ dsn => 'dbi:SQLite:dbname=:memory:',
                           username => undef,
                           password => undef
                       });

# Then something with MySQL
my $mysql = Test::mysqld->new( my_cnf => {
    'skip-networking' => '1',
    socket => File::Spec->catfile( File::Spec->tmpdir() , 'socket-'.$$.'-testmysqld')
});

push @connection_params, { dsn => $mysql->dsn(),
                           password => '',
                           username => ''
                       };

my $pgsql = Test::PostgreSQL->new();
push @connection_params, { dsn => $pgsql->dsn(),
                           password => undef,
                           username => 'postgres'
                       };

foreach my $connect_params ( @connection_params ){
    diag("Testing ".$connect_params->{dsn} );

    ok( my $jesp = App::JESP->new({ dsn => $connect_params->{dsn},
                                    username => $connect_params->{username},
                                    password => $connect_params->{postgres},
                                    home => 'bla'
                                }) );
    ok( $jesp->install(), "Ok can install JESP in the given Database");
    my @installed_patches  = $jesp->dbix_simple()->select( $jesp->patches_table_name() )->hashes();

    is( scalar( @installed_patches ) , 1 );
    is( $installed_patches[0]->{id} , $jesp->prefix().'meta_zero' , "Good zero name" );
    ok( exists( $installed_patches[0]->{applied_datetime} ) , "There is an applied time" );
}
done_testing();
