use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => "A wrapper around DBI's table_info() and column_info()",
    ) : (),
	clean				=>
	{
		FILES			=> 'blib/* Makefile MANIFEST DBIx-Admin-TableInfo-*'
	},
	dist				=>
	{
		COMPRESS		=> 'gzip',
		SUFFIX			=> 'gz'
	},
	DISTNAME			=> 'DBIx-Admin-TableInfo',
	NAME				=> 'DBIx::Admin::TableInfo',
	PREREQ_PM			=> {Carp => 0, DBI => 0},
	VERSION_FROM		=> 'TableInfo.pm',
);
