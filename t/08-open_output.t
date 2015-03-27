#!perl 

use strict;
use warnings;

use lib 't/lib';
use Excel::Template::XLSX;
use Test::More;

our $CAPTURE = '';

# Setup to capture warnings
my $sig = $SIG{__DIE__};
$SIG{__DIE__} = sub { $CAPTURE = $_[0] };

eval {
# Attempt to create invalid output file when calling Excel::Writer::XLSX->new()
   Excel::Template::XLSX->new( '*', '' );
};

# Restore previous warn handler
$SIG{__DIE__} = $sig;

# remove reason from error message
( my $got = $CAPTURE ) =~ s/object.*/object/s;
is($got,
   "Can't create new Excel::Writer::XLSX object",
   'Failure to create EWX object'
);

done_testing;
