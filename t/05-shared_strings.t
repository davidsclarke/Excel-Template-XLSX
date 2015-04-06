#!perl

use strict;
use warnings;

use lib 't/lib';
use Excel::Writer::XLSX;
use Excel::Template::XLSX;
use Test::More;
use File::Temp qw(tempfile);

# Can be set to 1 to see the created template and output file during debugging
$File::Temp::KEEP_ALL = 0;

# Create expected workbook content
my ( $efh, $efilename ) = tempfile( SUFFIX => '.xlsx' );
my $wbk = Excel::Writer::XLSX->new($efilename);
my $red = $wbk->add_format();
$red->set_color('red');

my $wksheet = $wbk->add_worksheet();
$wksheet->write( 'A1', 'A1A1' );
$wksheet->write_rich_string( 'A2', 'Some ', $red, 'red ', 'text' );

$wbk->close();

# Get workbook content as a template
my ( $gfh, $gfilename ) = tempfile( SUFFIX => '.xlsx' );
my ( $self, $twbk ) = Excel::Template::XLSX->new( $gfilename, $efilename );
$self->parse_template();

my $got1 = ( sort keys %{ $twbk->{_str_table} } )[1];
is( $got1, 'A1A1', "String" );

my $expected_rich = <<"END_RICH";
<r><t xml:space="preserve">
Some </t></r><r><rPr><sz val="11"/>
<color rgb="FFFF0000"/><rFont val="Calibri"/>
<family val="2"/>
<scheme val="minor"/></rPr>
<t xml:space="preserve">red </t></r><r>
<rPr><sz val="11"/>
<color rgb="FF000000"/><rFont val="Calibri"/>
<family val="2"/><scheme val="minor"/>
</rPr><t>text</t></r>
END_RICH
$expected_rich =~ tr/\r\n//d;

# Split the XML into chunks at element boundaries.
my @expected_rich = split /(?<=>)(?=<)/, $expected_rich;

my $got_rich = ( sort keys %{ $twbk->{_str_table} } )[0];
my @got_rich = split /(?<=>)(?=<)/, $got_rich;

for ( 0 .. $#got_rich ) {
   is( $got_rich[$_], $expected_rich[$_], "Rich String element $_" );
}

$twbk->close();

warn "Files \n$efilename\n$gfilename\n not deleted\n"
    if $File::Temp::KEEP_ALL;
done_testing;

__END__
