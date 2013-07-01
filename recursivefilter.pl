#!/usr/bin/perl
use strict;	# Enforce some good programming rules

use Getopt::Long;
use Cwd;
use File::Find;

#
# recursivefilter.pl
#
# Version 1.2a
#
# created 2006-04-10
# modified 2012-06-30
#
# Version History
#
# Version 1.0 2006-04-10
# Version 1.1 2007-05-19
# 	Added --directory, --debug, and --test flags
#	fixed --help function
# Version 1.2 2013-06-26
# 	Added --filter function
# Version 1.2a 2013-06-30
# 	clean-up comments
#

#
# Shell project which recursively searches through a directory
# Use for writing file filter scripts
#
# Default flags:
#
# --directory | -d
# Specifies starting directory
# Default is current working directory
#
# --[no]recurse | -[no]r
# Recursively search sub-folders
# Negated by prepending "no" (i.e., --norecurse or -nor)
# Default is recursive searching
#
# --[no]delete | --[no]del
# Delete source file after filtering
# Negated by prepending "no" (i.e., --nodelete or --nodel)
# Default is no delete
#
# --help | -?
# Displays help message
#
# --[no]debug
# Display debugging information
# Default is no debug mode
#
# --[no]test
# Test mode - display file names but do not process
# Default is no test mode
#
# Other parameters may, of course, be added
#

my ( $directory_param, $recurse_param, $delete_param, $filter_param, $help_param );
my ( $debug_param, $test_param );

GetOptions(	'directory|d=s'	=> \$directory_param,
			'recurse|r!'	=> \$recurse_param,
			'delete|del!'	=> \$delete_param,
			'filter|f=s'	=> \$filter_param,
			'help|?'		=> \$help_param,
			'debug!'		=> \$debug_param,
			'test!'			=> \$test_param );

# If user asked for help, display help message and exit
if ( $help_param ) {
	print "recursivefileter.pl\n";
	print "\n";
	print "Sample Perl script for recursive file filtering\n";
	print "\n";
	print "--directory | -d <directory> - set starting directory\n";
	print "default is current working directory\n";
	print "\n";
	print "--[no]recurse | -[no]r - recursive directory search\n";
	print "search through subdirectories for WAV files to convert\n";
	print "default is recursive search\n";
	print "\n";
	print "--filter | -f <regex> - specifies a filename filter for processing\n";
	print "<regex> is a regular expression\n";
	print "\n";
	print "--[no]delete | --[no]del - delete source files after encoding\n";
	print "default is not to delete source files after encoding\n";
	print "\n";
	print "--help | -? - help\n";
	print "displays this message\n";
	exit;
}

# Set parameter defaults
if ( $directory_param eq undef ) { $directory_param = cwd; }	# Current working directory
if ( $recurse_param eq undef ) { $recurse_param = 1; }			# True
if ( $delete_param eq undef ) { $delete_param = 0; }			# False
if ( $debug_param eq undef ) { $debug_param = 0; }				# False
if ( $test_param eq undef ) { $test_param = 0; }				# False

chdir( $directory_param );		# Change to the target directory
find( \&doittoit, "." ); 		# Begin file filtering
# find() is part of File::Find - it searches through a directory and its sub-directories
# starting with the directory specified in the second parameter
# "." is the current directory
# for each item, the subroutine referenced by the first parameter is called

sub doittoit {
	# Check to see if we should process the file/directory or not
	# If --recurse is not on, only process files from the starting directory
	# Only process files ( ! -d ) - is not a directory
	# If --filter is on, check to see if the file name matches the filter
	if ( ( ( $recurse_param || $File::Find::dir eq "." ) && ( ! -d ) ) &&
	( $filter_param eq undef || ( ( $filter_param ne undef ) && ( /$filter_param/ ) ) ) ) {
	
		# Get some information about the item
		#	Full path of item
		#	Full path of parent directory
		#	Branch (name of parent directory's parent directory - may be empty)
		#	Twig (name of parent directory)
		#	Leaf (name of file or directory)
		my ( $full_path, $parent_dir, $leaf_name, $twig_name, $branch_name, $work_space );
		
		$full_path = $directory_param . "/" . $File::Find::name;	# Create full path
		$full_path =~ s/\\/\//g;					# Turn around any backwards slashes
		if ( -d ) { $full_path .= "/"; }			# Add slash to end of the path if it is a directory
		$full_path =~ s/\/\.\//\//;					# Remove extra "/./"
		$full_path =~ s/\/\//\//g;					# Remove any duplicate slashes
				
		$parent_dir = $full_path;
		$parent_dir =~ s/\/$//g;					# Strip any trailing slash
		$parent_dir =~ s/\/([^\/]+)$//;				# Delete and remember anything after after the last non-empty slash
		$leaf_name = $1;
		
		$work_space = $parent_dir;
		$work_space =~ s/\/([^\/]+)$//g;
		$twig_name = $1;
		$work_space =~ s/\/([^\/]+)$//g;
		$branch_name = $1;
		
		##### Do whatever file processing is to be done here
				
		##### Example - report back file names
		if ( $test_param ) {
			print "Full Path: $full_path\n";
			print "Parent Dir: $parent_dir\n";
			print "Leaf Name: $leaf_name\n";
			print "Twig Name: $twig_name\n";
			print "Branch Name: $branch_name\n";
			print "\n";
		}
		
		##### Example - if --delete is specified		
#		if ( $delete_param ) { unlink( $full_path ); }
		# BE CAREFUL - unlink() deletes a file immediately and you can't undo it
		# if you uncomment this line and run with --delete, it will delete every file
		# in the directory, and any sub-directories if --recurse is turned on
	}
}
