#!/usr/bin/perl
#
# Name:
#	test-table-info.pl.

use strict;
use warnings;

use DBI;
use DBIx::Admin::TableInfo;

# -----------------------------------------------

my($dbh) = DBI -> connect
(
	'DBI:mysql:mids:127.0.0.1', 'root', 'pass',
	{
		AutoCommit			=> 1,
		PrintError			=> 0,
		RaiseError			=> 1,
		ShowErrorStatement	=> 1,
	}
);
my($admin)	= DBIx::Admin::TableInfo -> new(dbh => $dbh);
my($info)	= $admin -> info();

for my $table_name (@{$admin -> tables()})
{
	print "Table: $table_name\n";
	print "Table attributes\n";

	for (sort keys %{$$info{$table_name}{'attributes'} })
	{
	print "$_: $$info{$table_name}{'attributes'}{$_}\n";
	}

	print "\n";

	for my $column_name (@{$admin -> columns($table_name)})
	{
		print "Column: $column_name\n";
		print "Column attributes\n";

		for (sort keys %{$$info{$table_name}{'columns'}{$column_name} })
		{
			print "$_: $$info{$table_name}{'columns'}{$column_name}{$_}\n";
		}

		print "\n";
	}

	print "\n";
}
