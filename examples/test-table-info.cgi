#!/usr/bin/perl
#
# Name:
#	test-table-info.cgi.

use strict;
use warnings;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use DBI;
use DBIx::Admin::TableInfo;
use Error qw/:try/;

# -----------------------------------------------

delete @ENV{'BASH_ENV', 'CDPATH', 'ENV', 'IFS', 'SHELL'}; # For security.

my($title)	= 'Test DBIx::Admin::TableInfo';
my($q)		= CGI -> new();

my(@html);

try
{
	my($dbh) = DBI -> connect
	(
		'DBI:mysql:mids:127.0.0.1', 'root', 'pass',
		{
			AutoCommit			=> 1,
			HandleError			=> sub {Error::Simple -> record($_[0]); 0},
			PrintError			=> 0,
			RaiseError			=> 1,
			ShowErrorStatement	=> 1,
		}
	);
	my($admin)	= DBIx::Admin::TableInfo -> new(dbh => $dbh);
	my($info)	= $admin -> info();

	for my $table_name (@{$admin -> tables()})
	{
		push @html, $q -> th($q -> span({style => 'color: green; font-size: 20px'}, 'Table') ) . $q -> td($q -> span({style => 'color: green; font-size: 20px'}, $table_name) );
		push @html, $q -> th('Table attributes') . $q -> td('&nbsp;');

		for (sort keys %{$$info{$table_name}{'attributes'} })
		{
			push @html, $q -> th($_) . $q -> td($$info{$table_name}{'attributes'}{$_});
		}

		push @html, $q -> th('Columns') . $q -> td('&nbsp;');

		for my $column_name (@{$admin -> columns($table_name)})
		{
			push @html, $q -> th($q -> span({style => 'color: white'}, 'Column') ) . $q -> td($q -> span({style => 'color: white'}, $column_name) );
			push @html, $q -> th('Column attributes') . $q -> td('&nbsp;');

			for (sort keys %{$$info{$table_name}{'columns'}{$column_name} })
			{
				push @html, $q -> th($_) . $q -> td($$info{$table_name}{'columns'}{$column_name}{$_});
			}
		}

		push @html, $q -> th('&nbsp;') . $q -> td('&nbsp;');
	}
}
catch Error::Simple with
{
	my($error) = $_[0] -> text();
	chomp $error;
	push(@html, $q -> th('Error') . $q -> td($error) );
};

print	$q -> header({type => 'text/html;charset=ISO-8859-1'}),
		$q -> start_html({style => {src => '/css/default.css'}, title => $title}),
		$q -> h1({align => 'center'}, $title),
		$q -> start_form({action => $q -> url(), name => 'a_form'}),
		$q -> table
		(
			{align => 'center', border => 1, class => 'submit'},
			$q -> Tr([@html])
		),
		$q -> end_form(),
		$q -> end_html();

