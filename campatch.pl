#!/usr/bin/perl
###!/perl/bin/perl -w

use Text::ParseWords qw (&old_shellwords);

###SUBROUTINES BEGIN
sub what_os{

print "Are these Unix or NT servers? \n";
print "Please enter 'Unix' or 'NT'. \n";

my $IsValid=0;
				
	until($IsValid){
		$os=<STDIN>;
		chomp ($os);

		### Is response valid.
			if ($os eq 'q' or $os =~ m/Unix|NT/i){
				$IsValid=1;

				if ($os =~m/NT/i){
					print "Doing NT server patches \n";
				}
		
				else {
					print "Doing Unix server patches \n";
				}
			}
			else
				{print "Please enter 'Unix' or 'NT' \n";
			}
	}
return $os;
}
###SUBROUTINES ENDS

###SUBROUTINE BEGINS
sub find_flavor{

use Net::Telnet;

$telnet= new Net::Telnet (Timeout => 30,								   Prompt => '/.* [#] $/',
		   Errmode=> 'return');

$telnet->open($server)
	or warn "Cannot connect to $server";
$telnet->login($ftp_user, $ftp_password)
	or warn "Cannot login to $server";
@flavortype = $telnet->cmd ('uname -a');
return @flavortype;
}
###SUBROUTINES ENDS

###SUBROUTINES BEGINS
sub send_patch{

use Net::Telnet;

# $telnet= new Net::Telnet (Timeout => 30,				#				    Prompt => '/.* [#] $/',
#		   Errmode=> 'return');

# $telnet->open($server)
#	or warn "Cannot connect to $server";
# $telnet->login($ftp_user, $ftp_password)
#	or warn "Cannot login ";
@caipath=$telnet->cmd ("page /etc/catngcampath");
chomp($caipath[0]);
$caimsq=$caipath[0];
$cai="CAI_MSQ=";
$concat=$cai.$caimsq;
$export="; export CAI_MSQ";
$define.=$concat.$export;
$telnet->cmd ($define);
$telnet->cmd ("echo $CAI_MSQ");

use Net::FTP;

$ftp = Net::FTP->new($server)
	or warn "Cannot connect to $server";
$ftp->login($ftp_user, $ftp_password)
 	or warn "Cannot login on $server", $ftp->message;
$ftp->cwd("/opt/tng/aw/services")
	or warn "Cannot change working directory on $server", $ftp->message;
$ftp->cmd("bin")
	or warn "not in binary mode", $ftp->message;
$ftp->put($tarz)
	or warn "get failed on $server", $ftp->message;
$ftp->quit;

$telnet->cmd ("cd opt/tng/aw/services");
$uncompress=("uncompress < ");
$catun=$uncompress.$tarz;
$tar=" | tar xvf -";
$uncom .=$catun.$tar;
$telnet->cmd ($uncom);
$telnet->cmd("chmod +x ./CAMInstall")
	or warn "Cannot chmod on $server";
$telnet->cmd("./CAMInstall")
	or warn "Cannot execute script on $server";
$telnet->cmd("rm *.ok")
	or warn "Cannot execute script on $server";
$telnet->close($server);
}

###SUBROUTINE ENDS

print "Please enter the user name. \n";
$ftp_user=<STDIN>;
chomp ($ftp_user);
if ($ftp_user =~m/sudo/i){
	system ("stty -echo");
}
print "Please enter the user password. \n";
$ftp_password=<STDIN>;
chomp ($ftp_password);
if ($ftp_user =~m/sudo/i){
	system ("stty echo");
}
else{
system("cls");
}
print "Enter servername's file. \n";
$server_list=<STDIN>;
chomp $server_list;

#   Read server list..

open (LOG, "<$server_list");
@servers = <LOG>;

#   Create server log files.

		shift (@servers);
		what_os();
		if ($os =~m/NT/i){
			goto ITSNT;
		}

do{

		DOSERVER:{
		$servername=pop(@servers);
		$server=$servername;
		chomp ($server);
			if ($server eq ""){
			goto LAST;
			}
		}
		$suffix="_camstat.log";
		$camstat_log=$server.$suffix;
		chomp($servername);
		$command="camstat $servername > $camstat_log";
		system ($command);
		open (CAM_STAT, "<$camstat_log");
		@runcamstat = <CAM_STAT>;
		close (CAM_STAT);
		if (-z $camstat_log){
			open (CAM_STAT, ">>$camstat_log");
			print CAM_STAT "camstat: status failed";
			close (CAM_STAT);
			goto DOSERVER;
		}

		$camstat_version=$runcamstat[1];
		
			#   detect CAM Version

			if ($camstat_version =~m/Version 1.07/) {
		
				@camstat_build=old_shellwords($camstat_version);
				chop ($camstat_build[6]);
				$build=$camstat_build[6];
				$build=~s/_/./;
				print "$build \n";
								
				if ($build < 220.13) {

					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);
					find_flavor();
					
					@flavor=&old_shellwords($flavortype[0]);
					$theflavor=$flavor[0];

						if ($theflavor eq "SunOS"){
						$tarz="QO71048.tar.Z";
						send_patch();
						}
					
						elsif ($theflavor eq "Linux") {
						$tarz="QO71042.tar.Z";
						send_patch();
						}

						elsif ($theflavor eq "HP-UX") {
						$tarz="QO71040.tar.Z";
						send_patch();
						}

						elsif ($theflavor eq "AIX") {
						$tarz="QO71035.tar.Z";
						send_patch();
						}
					
				}

				elsif($build == 230) {

					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);					
					find_flavor();
					
					@flavor=&old_shellwords($flavor[0]);
					$theflavor=$os[0];

						if ($theflavor eq "SunOS"){
						$tarz="QO71026.tar.Z";
						send_patch();
						}
					
						elsif ($theflavor eq "Linux") {
						$tarz="QO71019.tar.Z";
						send_patch();
						}

						elsif ($theflavor eq "HP-UX") {
						$tarz="QO71016.tar.Z";
						send_patch();
						}
			
						elsif ($theflavor eq "AIX") {
						$tarz="QO71015.tar.Z";
						send_patch();
						}
					
				}

				elsif($build == 231) {

					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);					
					find_flavor();
					
					@flavor=&old_shellwords($flavor[0]);
					$theflavor=$os[0];

						if ($theflavor eq "SunOS"){
						$tarz="QO71026.tar.Z";
						send_patch();
						}
					
						elsif ($theflavor eq "Linux") {
						$tarz="QO71019.tar.Z";
						send_patch();
						}

						elsif ($theflavor eq "HP-UX") {
						$tarz="QO71016.tar.Z";
						send_patch();
						}
			
						elsif ($theflavor eq "AIX") {
						$tarz="QO71015.tar.Z";
						send_patch();
						}
					
				}

				
			}
			
			if ($camstat_version =~m/Version 1.11/) {

				@camstat_build=old_shellwords($camstat_version);
				chop ($camstat_build[6]);
				$build=$camstat_build[6];
				$build=~s/_/./;		

				if ($build < 29.13) {
				
					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);
					find_flavor();

					@flavor=&old_shellwords($flavortype[0]);
					$theflavor=$flavor[0];

						if ($theflavor eq "SunOS"){
						$tarz="QO71026.tar.Z";
						send_patch();
						}
					
						elsif ($theflavor eq "Linux") {
						$tarz="QO71019.tar.Z";
						send_patch();
						}

						elsif ($theflavor eq "HP-UX") {
						$tarz="QO71016.tar.Z";
						send_patch();
						}
	
						elsif ($theflavor eq "AIX") {
						$tarz="QO71015.tar.Z";
						send_patch();
						}	
				}
			}

}until ($#servers<0);

goto LAST;

ITSNT:{

do{

		DO_NTSERVER:{
		$servername=pop(@servers);
		$server=$servername;
		chomp ($server);
			if ($server eq ""){
			goto LAST;
			}
		}
		$suffix="_camstat.log";
		$camstat_log=$server.$suffix;
		chomp($servername);
		$command="camstat $servername > $camstat_log";
		system ($command);
		open (CAM_STAT, "<$camstat_log");
		@runcamstat = <CAM_STAT>;
		close (CAM_STAT);
		if (-z $camstat_log){
			open (CAM_STAT, ">>$camstat_log");
			print CAM_STAT "camstat: status failed";
			close (CAM_STAT);
			goto DO_NTSERVER;
		}

		$camstat_version=$runcamstat[1];

		#   detect CAM Version

		$wacks="\\\\";
		$authserv=$wacks.$server;

			if ($camstat_version =~m/Version 1.07/) {
			$map="map.bat";
			$caz="QO71033.CAZ";
			$patch="ntjcl.bat";
			$ok="220_13_upd.ok";
			@camstat_build=old_shellwords($camstat_version);
			chop ($camstat_build[6]);
			$build=$camstat_build[6];
			$build=~s/_/./;

				if ($build < 220.13) {
					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);
					system ("$map $authserv $ftp_user $ftp_password $caz $patch $ok");
					sleep(60);
					system ("net use Q: /DELETE");
				}

				elsif($build == 230) {
					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);
					system ("$map $authserv $ftp_user $ftp_password $caz $patch $ok");
					sleep(60);
					system ("net use Q: /DELETE");
				}

				elsif($build == 231) {
					open (CAM_STAT, ">>$camstat_log");
					print CAM_STAT "Upgrading $server from $build \n";
					close (CAM_STAT);
					system ("$map $authserv $ftp_user $ftp_password $caz $patch $ok");
					sleep(60);
					system ("net use Q: /DELETE");
				}

			}

			
			if ($camstat_version =~m/Version 1.11/) {

				$map="map.bat";		
				$caz="QO71014.CAZ";
				$patch="ntjcl.bat";
				$ok="29_13_upd.ok";
				@camstat_build=old_shellwords($camstat_version);
				chop ($camstat_build[6]);
				$build=$camstat_build[6];
				$build=~s/_/./;

					if ($build < 29.13) {
						open (CAM_STAT, ">>$camstat_log");
						print CAM_STAT "Upgrading $server from $build \n";
						close (CAM_STAT);
						system ("$map $authserv $ftp_user $ftp_password $caz $patch");
						sleep(60);
						system ("net use Q: /DELETE");
					}
			}
}until ($#servers<0);
}
				
LAST:{
print "All servers in list are finished";
}
