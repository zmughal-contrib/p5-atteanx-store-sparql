use 5.010001;
use strict;
use warnings;

package AtteanX::Store::SPARQL;

our $AUTHORITY = 'cpan:KJETILK';
our $VERSION   = '0.001';

use Moo;
use Types::URI -all;
use Types::Standard qw(InstanceOf);
use AtteanX::Parser::SPARQLXML::SAXHandler;
use URI::Escape::XS;
use LWP::UserAgent;
use Data::Dumper;
use Carp;

with 'Attean::API::QuadStore';

has 'endpoint_url' => (is => 'ro', isa => Uri, coerce => 1);
has 'ua' => (is => 'rw', isa => InstanceOf['LWP::UserAgent'], builder => '_build_ua');

sub _build_ua {
	my $self = shift;
	my $ua = LWP::UserAgent->new;
	$ua->default_headers->push_header( 'Accept' => "application/sparql-results+xml;q=1");
	return $ua;
}

sub _get_sparql {
	my ($self, $sparql) = @_;
	my $handler	= AtteanX::Parser::SPARQLXML::SAXHandler->new;
	my $p	= XML::SAX::ParserFactory->parser(Handler => $handler);
	my $ua = $self->ua;
	
# 	warn $sparql;
	
	my $url = $self->endpoint_url->clone;
	my %query = $url->query_form;
	$query{'query'} = uri_escape($sparql);
	$url->query_form(%query);
	my $response	= $ua->get( $url );
	if ($response->is_success) {
		$p->parse_string( $response->decoded_content );
		return $handler->iterator;
	} else {
#		warn "url: $url\n";
#		warn $sparql;
		warn Dumper($response);
		croak 'Error making remote SPARQL call to endpoint ' . $self->endpoint_url->as_string . '(' .$response->status_line. ')';
	}
}


1;

__END__

=pod

=encoding utf-8

=head1 NAME

AtteanX::Store::SPARQL - Attean SPARQL store

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=AtteanX-Store-SPARQL>.

=head1 SEE ALSO

=head1 ACKNOWLEDGEMENTS

This module is heavily influencd (even containing code cutnpasted)
from L<RDF::Trine::Store::SPARQL>.

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2015 by Kjetil Kjernsmo and Gregory
Todd Williams.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

