#-*- mode: Perl -*-
# vim: set syntax=perl:

requires 'DBI', '>= 1.636';
requires 'DBIx::Simple', '>= 1.35';
requires 'Log::Any', '>= 1.040';
requires 'Moose' , '>= 2.1801';
requires 'SQL::Abstract', '>= 1.81';

test_requires 'DBD::SQLite', '>= 1.50';
test_requires 'Test::Most', '>= 0.34';
test_requires 'Test::Pod::Coverage', '>= 1.08';
