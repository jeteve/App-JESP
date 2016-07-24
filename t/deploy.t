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
is( $jesp->deploy(), 2, "Ok applied 2 patches");
is( $jesp->deploy(), 0, "Ok applied 0 patches on the second call");

# After this is installed, we should be able to use and query the
# table foobar with all its columns.
$jesp->dbix_simple()->insert('foobar', { id => 1 , bla => 'some' , baz => 'thing' });
my @rows = $jesp->dbix_simple()->select( 'foobar' , [ 'id', 'bla', 'baz' ] );
is( scalar( @rows ) , 1 );

done_testing();
