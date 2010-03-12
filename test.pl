#!/usr/local/bin/perl

# Sys::HostAddr test.pl
# $Id: test.pl,v 1.2 2010/03/06 21:36:35 jkister Exp $
# Copyright (c) 2010 Jeremy Kister.
# Released under Perl's Artistic License.

use strict;
use Test;

BEGIN { plan tests => 7 };

use Sys::HostAddr;
print "# testing Sys::HostAddr v$Sys::HostAddr::VERSION...\n"; 

my $sysaddr = Sys::HostAddr->new( debug => 0 );

ok(1);

my $main_ip = $sysaddr->main_ip();
print "# Main IP Address appears to be: $main_ip\n";
ok( $main_ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ );

my $first_ip = $sysaddr->first_ip();
print "# First IP Adddress is: $first_ip\n";
ok( $first_ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ );

my $yn;
print "# allow Internet access to determine public IP address? [Y/n]: ";
eval {
    local $SIG{ALRM} = sub { die "timeout on response; allowing.\n" };
    alarm(6);
    chop($yn=<STDIN>);
    alarm(0);
};
alarm(0);
warn $@ if $@;

if( $yn =~ /^n/i ){
    skip(1);
}else{
    my $public = $sysaddr->public();
    print "public IP address: $public\n";
    ok( $public =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ );
}
    
my $href = $sysaddr->ip();
print "# IP info:\n";
my $i = 0;
my $a = 0;
foreach my $interface ( keys %{$href} ){
    $i++ unless ($interface =~ /^lo\d*/);
    foreach my $aref ( @{$href->{$interface}} ){
         print "# $interface: $aref->{address}/$aref->{netmask}\n";
        $a++ unless($aref->{address} =~ /^127\./);
    }
}
ok( $i && $a );

my $addr_aref = $sysaddr->addresses();
foreach my $address ( @{$addr_aref} ){
    print "# Found IP address: $address\n";
}
ok( @{$addr_aref} > 0 ); # 127.0? + other - win32 doesnt include 127

my $int_aref = $sysaddr->interfaces();
foreach my $interface ( @{$int_aref} ){
    print "# Found interface: $interface\n";
}

ok( @{$int_aref} > 0 );

