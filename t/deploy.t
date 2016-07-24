#! perl -w

use Test::Most;
use App::JESP;

# Test deployment in SQLite

# use Log::Any::Adapter qw/Stderr/;

# A home that is there.
my $jesp = App::JESP->new({ dsn => 'dbi:SQLite:dbname=:memory:',
                            username => undef,
                            password => undef,
                            home => './t/home/'
                        });
throws_ok(sub{ $jesp->deploy() } , qr/ERROR querying meta/ );

# Time to install
$jesp->install();
is( $jesp->deploy(), 3, "Ok applied 3 patches");
is( $jesp->deploy(), 0, "Ok applied 0 patches on the second call");

# After this is installed, we should be able to use and query the
# table foobar with all its columns.
{
    $jesp->dbix_simple()->insert('foobar', { id => 1 , bla => 'some' , baz => 'thing' });
    my @rows = @{ $jesp->dbix_simple()->select( 'foobar' , [ 'id', 'bla', 'baz' ] )->hashes() };
    is( scalar( @rows ) , 1 );
}

# And also do clever stuff with the customer table and the customer_address view
{
    $jesp->dbix_simple()->insert('customer', { cust_id => 123 , cust_name => 'Armand' , cust_addr => 'Rue de la mouffette' });
    {
        my $hashes = $jesp->dbix_simple()->select( 'customer_address' , [ 'cust_id', 'cust_addr' ] )->hashes();
        use DDP;
        is( $hashes->[0]->{cust_addr} , 'Rue de la mouffette' );
    }
    {
        $jesp->dbix_simple()->update( 'customer_address', { cust_addr => 'Rue de la pierre en bois' } ,{ cust_id => 123 } );
        my $hashes = $jesp->dbix_simple()->select( 'customer' , [ 'cust_id', 'cust_addr' ] )->hashes();
        is( $hashes->[0]->{cust_addr} , 'Rue de la pierre en bois' , "The trigger did work!" );
    }
}

done_testing();
