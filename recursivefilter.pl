#!perl
use strict;	# Enforce some good programming rules

use Getopt::Long;
use Cwd;
use File::Find;

#
# recursivefilter.pl
#
# Version 1.1
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

my ( $directory_param, $recurse_param, $delete_param, $help_param );
my ( $debug_param, $test_param );

GetOptions(	'directory|d=s'	=> \$directory_param,
		'recurse|r!'	=> \$recurse_param,
		'delete|del!'	=> \$delete_param,
		'help|?'	=> \$help_param,
		'debug!'	=> \$debug_param,
		'test!'		=> \$test_param );

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
	print "--[no]delete | --[no]del - delete source files after encoding\n";
	print "default is not to delete source files after encoding\n";
	print "\n";
	print "--help | -? - help\n";
	print "displays this message\n";
	exit;
}

# Set parameter defaults
if ( $directory_param eq undef ) { $directory_param = cwd; }	# Current working directory
if ( $recurse_param eq undef ) { $recurse_param = 1; }		# True
if ( $delete_param eq undef ) { $delete_param = 0; }		# False
if ( $debug_param eq undef ) { $debug_param = 0; }		# False
if ( $test_param eq undef ) { $test_param = 0; }		# False

chdir( $directory_param );	# Change to the target directory
find( \&doittoit, "." ); 		# Begin file filtering

sub doittoit {
	# We have to check to see if each file is in the target directory of a subdirectory
	# Of course, if recursion is on, process all of the files
	# Test for any file attributes desired
	# Implement the filter function, too
	if ( $recurse_param || $File::Find::dir eq "." ) {
	
		# Get some information about the item
		#	Full path of item
		#	Full path of parent directory
		#	Branch (name of parent directory's parent directory - may be empty)
		#	Twig (name of parent directory)
		#	Leaf (name of file or directory)
		my ( $full_path, $parent_dir, $leaf_name, $twig_name, $branch_name, $work_space );
		
		$full_path = $directory_param . "/" . $File::Find::name;	# Create full path
		$full_path =~ s/\\/\//g;					# Turn around any backwards slashes
		if ( -d ) { $full_path .= "/"; }				# Add slash to end of the path if it is a directory
		$full_path =~ s/\/.\//\//;					# Remove extra "/./"
		$full_path =~ s/\/\//\//g;					# Remove any duplicate slashes
				
		$parent_dir = $full_path;
		$parent_dir =~ s/\/$//g;					# Strip any trailing slash
		$parent_dir =~ s/\/([^\/]+)$//;					# Delete and remember anything after after the last non-empty slash
		$leaf_name = $1;
		
		$work_space = $parent_dir;
		$work_space =~ s/\/([^\/]+)$//g;
		$twig_name = $1;
		$work_space =~ s/\/([^\/]+)$//g;
		$branch_name = $1;
		
		##### Do whatever file processing is to be done here
				
		## Example - report back file names
		if ( $test_param ) {
			print "Full Path: $full_path\n";
			print "Parent Dir: $parent_dir\n";
			print "Leaf Name: $leaf_name\n";
			print "Twig Name: $twig_name\n";
			print "Branch Name: $branch_name\n";
			print "\n";
		}
		
		## Example - if --delete is specified		
		if ( $delete_param ) { unlink( $full_path ); }
	}
}
