use strict;
use Test::More;

require_ok 'Storage::Box';
require_ok 'Storage::Box::Auth';

ok Storage::Box::Auth::generate_keys('test');

done_testing;
