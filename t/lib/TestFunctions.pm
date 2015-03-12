package TestFunctions;

###############################################################################
#
# TestFunctions - Helper functions for test cases.
#
# based upon Excel::Writer::XLSX TestFunctions
# reverse('©'), September 2010, John McNamara, jmcnamara@cpan.org
#

use Exporter;
use strict;
use warnings;
use Test::More;

our @ISA         = qw(Exporter);
our @EXPORT      = ();
our %EXPORT_TAGS = ();
our @EXPORT_OK   = qw(
  _expected_to_aref
  _got_to_aref
  _is_deep_diff
  _compare_xlsx_files
  _xml_str_to_array
);

our $VERSION = '1.00';

###############################################################################
#
# Turn the embedded XML in the __DATA__ section of the calling test program
# into an array ref for comparison testing. Also performs some minor string
# formatting to make comparison easier with _got_to_aref().
#
# The XML data in the testcases is taken from Excel 2007 files with formatting
# via "xmllint --format".
#
sub _expected_to_aref {

    my @data;

    # Ignore warning for files that don't have a 'main::DATA'.
    no warnings 'once';

    while ( <main::DATA> ) {
        chomp;
        next unless /\S/;    # Skip blank lines.
        s{/>$}{ />};         # Add space before element end like XML::Writer.
        s{^\s+}{};           # Remove leading whitespace from XML.
        push @data, $_;
    }

    return \@data;
}

###############################################################################
#
# Convert an XML string returned by the XMLWriter subclasses into an
# array ref for comparison testing with _expected_to_aref().
#
sub _got_to_aref {

    my $xml_str = shift;

    # Remove the newlines after the XML declaration and any others.
    $xml_str =~ s/[\r\n]//g;

    # Split the XML into chunks at element boundaries.
    my @data = split /(?<=>)(?=<)/, $xml_str;

    return \@data;
}

###############################################################################
#
# Convert an XML string into an array for comparison testing.
#
sub _xml_str_to_array {

    my $xml_str = shift;
    my @xml     = @{ _got_to_aref( $xml_str ) };

    s{(\S)/>$}{$1 />} for @xml;

    return @xml;
}

###############################################################################
#
# Compare two array refs for equality.
#
sub _arrays_equal {

    my $exp = shift;
    my $got = shift;

    if ( @$exp != @$got ) {
        return 0;
    }

    for my $i ( 0 .. @$exp - 1 ) {
        if ( $exp->[$i] ne $got->[$i] ) {
            return 0;
        }
    }

    return 1;
}


###############################################################################
#
# Re-order the relationship elements in an array of XLSX XML rel (relationship)
# data. This is necessary for comparison since Excel can produce the elements
# in a semi-random order.
#
sub _sort_rel_file_data {

    my @xml_elements = @_;
    my $header       = shift @xml_elements;
    my $tail         = pop @xml_elements;

    # Sort the relationship elements.
    @xml_elements = sort @xml_elements;

    return $header, @xml_elements, $tail;
}


###############################################################################
#
# Use Test::Differences::eq_or_diff() where available or else fall back to
# using Test::More::is_deeply().
#
sub _is_deep_diff {
    my ( $got, $expected, $caption, ) = @_;

    eval {
        require Test::Differences;
        Test::Differences->import();
    };

    if ( !$@ ) {
        eq_or_diff( $got, $expected, $caption, { context => 1 } );
    }
    else {
        is_deeply( $got, $expected, $caption );
    }

}


1;


__END__

