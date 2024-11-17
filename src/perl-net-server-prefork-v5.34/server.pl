#!/usr/bin/perl -w
package Q;
use 5.12.0;
use base qw( Net::Server::PreFork );
use JSON;
use DBI qw( :sql_types );
use DBD::Pg qw( :pg_types :async );

our $connection = "DBI:Pg:dbname=testdb;host=postgres;port=5432;sslmode=disable";
my $port = shift || 8088;
Q->run( port => $port, no_close_by_child => 1 );

sub sth {
    my $self = shift;
    my $query = shift;
    my $dbh = $self->{dbh};
    if ( ! $dbh ) {
        $dbh = $self->{dbh} = DBI->connect( $connection, "testuser", "testpass", { PrintError => 0, RaiseError => 0 } )
            || return out( "DB connect error: ".$DBI::errstr );
    }
    my $sth = $self->{sth}{ $query } ||= $dbh->prepare( $query );
    out( "Failed to prepare handle:\n$query\n".( $dbh->errstr || $DBI::errstr ) )
        if ! $sth;
    return $sth;
}

sub out {
    my $data = shift;
    $data = { error => $data }
        if ! ref $data;
    my $json = JSON->new->allow_nonref()->encode( $data );
    my $size = length $json;
    print "HTTP/1.1 200 OK\nContent-Type: application/json\nContent-Length: $size\n\n$json";
    return;
}

sub process_request {
    my $self = shift;
	my ( $request ) = ( <> ) || die "Could not read headers\n";
    return out( "No handler for: $request" )
        if $request !~ /GET\s\S+[?](\S+)\s/;

    my $args = { map {
        my ( $k, $v ) = /(\S+?)=(.+)/;
        $v =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $k => $v } split /[&]/, $1 };

    my $keys = [qw( _records _text_param _int_param _ts_param _bool_param )];
    my $params = [ map { defined $args->{ $_ } ? $args->{ $_ } : () } @$keys ];
    return out( "Invalid params, missing: "
        .( join ',', map { defined $args->{ $_ } ? () : $_ } @$keys ) )
        if @$params != 5;

    my $sth = $self->sth( 'SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar
    FROM public.test_func_v1( $1::int,$2::text, $3::int, $4::timestamp, $5::bool )' )
        || return;
    $sth->execute( @$params );
    my $data = $sth->fetchall_arrayref({});
    return out( $data );
}

1;
