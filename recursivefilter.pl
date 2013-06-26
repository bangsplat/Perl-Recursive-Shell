#!perl
use strict;	# Enforce some good programming rules

use Getopt::Long;
use Cwd;
use File::Find;

#
# recursivefilter.pl
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
#
# --help | -?
# Displays help message
#
# Other parameters may, of course, be added
#

my ( $param_directory, $param_recurse, $param_delete, $param_help );

GetOptions(	'directory|d=s'	=> \$param_directory,
		'recurse|r!'	=> \$param_recurse,
		'delete|del!'	=> \$param_delete,
		'help|?'	=> \$param_help );

# If user asked for help, display help message and exit
if ( $param_help ) {
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
if ( $param_directory eq undef ) { $param_directory = cwd; }	# Current working directory
if ( $param_recurse eq undef ) { $param_recurse = 1; }		# True
if ( $param_delete eq undef ) { $param_delete = 0; }		# False

chdir( $param_directory );	# Change to the target directory
find( \&encode, "." ); 		# Begin file filtering

sub encode {
	# We have to check to see if each file is in the target directory of a subdirectory
	# Of course, if recursion is on, process all of the files
	# Test for any file attributes desired
	if ( $param_recurse || $File::Find::dir eq "." ) {
		my $full_path = $param_directory . "/" . $File::Find::name;	# Create full path
		$full_path =~ s/\\/\//g;					# Turn around any backwards slashes
		$full_path =~ s/\/.\//\//;					# Remove extra "/./"
		$full_path =~ s/\/\//\//g;					# Remove any duplicate slashes
		if ( -d ) { $full_path .= "/"; }				# Add slash to directory names
		
		# Just for sake of example, print full path name
		print "$full_path\n";
		# Process the file as desired
		
		if ( $param_delete ) { unlink( $full_path ); }
	}
}
