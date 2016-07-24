#! perl -w

use Test::Most;
BEGIN{
    eval "use Test::PostgreSQL";
    plan skip_all => "Test::PostgreSQL is required for this test" if $@;
}

use App::JESP;

my $pgsql = Test::PostgreSQL->new();

my $jesp = App::JESP->new({ dsn => $pgsql->dsn(),,
                            password => '',
                            username => 'postgres',
                            home => './t/home_pgsql/'
                        });
throws_ok(sub{ $jesp->deploy() } , qr/ERROR querying meta/ );

# Time to install
$jesp->install();
# And deploy
is( $jesp->deploy(), 2, "Ok applied 2 patches");
is( $jesp->deploy(), 0, "Ok applied 0 patches on the second call");

# Now let's insert one country. This should work just fine.
$jesp->dbix_simple()->insert('country', { country => 'Groland' });
my $hashes = $jesp->dbix_simple()->select( 'country' , [ 'country' ] )->hashes();
is( $hashes->[0]->{country} , 'Groland' );

done_testing();
