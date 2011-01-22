#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use S;

my $db = S->test_db;
ok($db);

done_testing();
