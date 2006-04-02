package Package::oracleinstantclient;

use strict;
use warnings;

use base qw(PackageBinary);

our $VERSION = '10.1';



sub base_url {
	my $self = shift;
	return "http://download-uk.oracle.com/otn/mac/instantclient";

}


sub packagename {
	return "instantclient10_1";
}



sub subpath_for_check {
	return "lib/libclntsh.dylib.10.1";
}


sub unpack {

	my $self = shift @_;

	return if ($self->is_unpacked());

	$self->download();
	$self->log('unpacking');
	$self->cd_srcdir();
	my $downloaddir = $self->config()->downloaddir();
	$self->shell("unzip $downloaddir/$_") foreach ($self->oracle_files());

}



sub install {
	my $self = shift @_;
	return undef if ($self->is_installed());

	$self->log("installing");
	
	$self->cd_packagesrcdir();
	my $prefix = $self->config()->prefix();
	$self->shell("mkdir -p $prefix/oracle");

	foreach my $lib (qw(libclntsh.dylib.10.1 libociei.dylib)) {
		$self->shell("cp $lib $prefix/oracle");
		$self->shell("install_name_tool -id $prefix/oracle/$lib $prefix/oracle/$lib");
	}

	$self->shell("cp -R sdk $prefix/oracle");

	$self->shell("cd $prefix/oracle && ln -s libclntsh.dylib.* libclntsh.dylib");

	# ugly hack: the PDO OCI configure code is not smart enough
	# to use the current platform's dynamic library suffix, '.so'
	# is hardcoded so we provide a symlink to make it happy
	$self->shell("cd $prefix/oracle && ln -s libclntsh.dylib libclntsh.so");

}

sub is_installed {
	my $self = shift @_;
	return -e $self->config()->prefix() . "/oracle";
}




sub is_downloaded {

	my $self = shift @_;

	return ! grep {! (-f $self->config()->downloaddir() . "/$_")} $self->oracle_files();

}


sub download {
	my $self = shift @_;
	
	return if ($self->is_downloaded());
	my @files = $self->oracle_files();
	die "You must download the oracle instant client libraries manually\nWe expect the files @files in the download directory " . $self->config()->downloaddir() . "\n";
}


sub oracle_files {

	return qw(instantclient-basic-macosx-10.1.0.3.zip instantclient-sdk-macosx-10.1.0.3.zip);
	
}



1;