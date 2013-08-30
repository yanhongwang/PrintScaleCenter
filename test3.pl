#! /usr/bin/perl
## 利用 comm_prscale
# sizeof(struct plu_struct) : 68
# sizeof(struct prf_fmt) : 46

use Socket;
use IO::Handle;
use Fcntl;

*username_length = \10;
*password_length = \8;
*lport = 0;

$| = 1;
$flags = fcntl(STDIN,F_GETFL,0);

fcntl(STDIN,F_SETFL,$flags | O_NONBLOCK);
$flags = fcntl(STDOUT,F_GETFL,0);

fcntl(STDOUT,F_SETFL,$flags | O_SYNC);

if($#ARGV == -1)
{
 while(1)
 {
  print "Please input the address:\n";

  $line = "192.168.1.194\n";

  #while(!( defined( $line = <STDIN> ))) {}
  chomp($line);
  if($line =~ /\S/)
  {
   $line =~ s/\s//g;
   $addr = inet_aton($line);
   $port = 0xabcd;
   last;
  }
 }
}
else
{
 $addr = inet_aton($ARGV[0]);
 if($#ARGV > 0)
 { $port = $ARGV[1]; }
 else { $port = 0xabcd; }
}


$proto = getprotobyname('udp');

socket(SOCK,PF_INET,SOCK_DGRAM,$proto) || die "socket: $!";

$iname = sockaddr_in($lport,INADDR_ANY) || die "sockaddr_in: $!";

bind(SOCK,$iname) || die "bind: $!";



$flags = fcntl(SOCK,F_GETFL,0);

fcntl(SOCK,F_SETFL,$flags | O_NONBLOCK);


while(1)
{
 if( defined( $line = <STDIN> ))
 {
  chomp($line);

  if($line =~ /quit/i || $line =~ /bye/i)
  {
   last;
  }
  ($cmd,$scmd,$oprnd) = ($line =~ /^\s*(\S+)\s*(\S*)\s*(.*)/);
  if($cmd eq 'login')
  {
   $scmd = pack 'a' . $username_length,$scmd;
   $oprnd = pack 'a' . $password_length,$oprnd;
   sendout('lg' . $scmd . $oprnd . "\015");
  }
  elsif($cmd eq 'debug')
  {
   sendout(chr(27));
   while(1)
   {
    if( defined( $line = <STDIN> ))
    {
     chomp($line);
     sendout($line . "\015");
     if($line =~ /^$/) { last; }
    }
    if( defined( $ll = <SOCK> ))
    {
     $ll =~ s/\015/\012/g;
     print $ll;
    }
   }
  }
  elsif($cmd eq 'logout')
  {
   sendout('lo' . "\015");
  }
  elsif($cmd eq 'abort')
  {
   sendout("\004");
  }
  elsif($cmd eq 'program')
  {
   sendout('pr' . "\015");
  }
  elsif($cmd eq 'stop')
  {
   sendout('st' . "\015");
  }
  elsif($cmd eq 'start')
  {
   sendout('ST' . "\015");
  }
  elsif($cmd eq 'lock')
  {
   sendout('lk' . "\015");
  }
  elsif($cmd eq 'unlock')
  {
   sendout('ul' . "\015");
  }
  elsif($cmd eq 'read')
  {
   if($scmd eq 'serial')
   {
    sendout('rdsno' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "serial no:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'prog_no')
   {
    sendout('rdpno' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "program release no:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'control')
   {
    sendout('rdcno' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "control board release no:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'current_unit')
   {
    sendout('rdcun' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "current unit:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'weight')
   {
    sendout('rdwgt' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     if($j & 0x800000) { $j &= 0x7fffff;$j = - $j; }
     print "weight:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'tare')
   {
    sendout('rdtar' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "tare:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'unit_price')
   {
    sendout('rdupr' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "unit price:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'current_user')
   {
    sendout('rdcur' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "current user:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'date_time')
   {
    sendout('rddtm' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "time:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'string_length')
   {
    sendout('rdstl' . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = decode(substr($ll,1));
     print "string length:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'format_length')
   {
    @opn = split(/\s+/,$oprnd);
    sendout('rdpfl' . encode($opn[0],2) . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     print "length:" . decode(substr($ll,1)) . "\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'plu')
   {
    @opn = split(/\s+/,$oprnd);
    sendout('rdplu' . encode($opn[0],4) . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     print substr( $ll, 1)  . "\n";

     use Time::tm;
     use Time::Local 'timelocal_nocheck';
     
     $wdate = decode(substr($ll,1,4));
     $test = timelocal_nocheck( 0,0, 0, $wdate + 1, 0,0);
     ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $test ) ;
     $mon += 1;
     $year += 1900;
     $yday += 1;
     print "$sec �� $min �� $hour �I $mday �� $mon�� �褸$year�~ �P��$wday ��365�Ѥ���$yday�� isdst:$isdst\n";
     
     $pdate = decode(substr($ll,5,4));
     $test = timelocal_nocheck( 0,0, 0, $pdate + 1, 0,0);
     ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $test ) ;
     $mon += 1;
     $year += 1900;
     $yday += 1;
     print "$sec �� $min �� $hour �I $mday �� $mon�� �褸$year�~ �P��$wday ��365�Ѥ���$yday�� isdst:$isdst\n";
     
     
     $disc = decode(substr($ll,9,8));
     
     $start_time = decode(substr($ll,17,8));
     $base_time = timelocal_nocheck($start_time,0,0,1,0,0);
     ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $base_time );
     $mon += 1;
     $year += 1900;
     $yday += 1;
     print "$sec �� $min �� $hour �I $mday �� $mon�� �褸$year�~ �P��$wday ��365�Ѥ���$yday�� isdst:$isdst\n";

     
     $stop_time = decode(substr($ll,25,8));

     $uprice = 0;
     for( $i = 33; $i < 39; $i += 2 )
     {
      $uprice <<= 8; 
      $uprice += decode(substr($ll,$i,2));
     }
   
     $prtare = 0;
     for( $i = 39; $i < 45; $i += 2 )
     {
      $prtare <<= 8;
      $prtare += decode(substr($ll,$i,2));
     }
     
     $name = undef;
     for( $i = 45; $i < 85; $i += 2 )
     {$name .= chr(decode(substr($ll,$i,2)));}
     $name =~ s/\00//g;
     
     $number = undef;
     for( $i = 85; $i < 125; $i += 2 )
     {$number .= chr(decode(substr($ll,$i,2)));}
     $number =~	s/\00//g;
     
     $unit = decode(substr($ll,125,2));
	  
     $cunit = decode(substr($ll,127,2));

     $tdisc = decode(substr($ll,129,2));

     $tax = decode(substr($ll,131,2));

     $class = decode(substr($ll,133,2));
     
     $pf = decode(substr($ll,135,2)) + 1;
  
     print "�s�y����G$wdate\n���Ĥ���G$pdate\n�馩�q�G$disc\n�馩�}�l�G$start_time\n�馩�����G$stop_time\n";
     print "����G$uprice\n�����G$prtare\n�~�W�G$name\n�ӫ~���X�G$number\n�p���覡�G$unit\ncunit�G$cunit\n";
     print "tdisc�G$tdisc\n�|�v�G$tax\n������G$class\n����$pf\n";
    }
    else { print $ll . "\n";}
    #  print $ll . "\n";
    #print length($ll) . "\n";
   }
   elsif($scmd eq 'print_format')
   {
    @opn = split(/\s+/,$oprnd);
    if($opn[0] eq 'all')
    {
     if($opn[1] eq '>')
     {
      open PRF_FILE,'> ' . $opn[2];
      $k = 1;
     }
     else { $k = 0; }

     # get all length into @pr_len
     pr_outloop:
     for($i = 0;$i < 12;$i++)
     {
      sendout('rdpfl' . encode($i,2) . "\015");
     
      $ll = get_res();
      if($ll =~ /^\@/)
      {
       $pr_len[$i] = decode(substr($ll,1));#1��12�ո��`�@�����Ƕ��O�w�]�w��
      }
      else
      {
       print "error at $i :" . $ll . "\n";
       last;
      }
      $ll = get_res();

      if($ll ne '^0')
      {
       print "return code error at $i:$ll\n";
       last;
      }
      
      print "len $i:" . $pr_len[$i] . "\n";

      
      for($j = 0;$j < $pr_len[$i];$j++)
      {
       sendout('rdprf' . encode($j,4) . encode($i,2) . "\015");#��ĴX���A�β�1-12���䤤�@��
       
       $prfcnt = get_res();
       if($prfcnt !~ /^\@/)
       {
        print "Fail at $i , $j : $prfcnt\n";
        last pr_outloop;
       }
       else { $prfcnt = substr($prfcnt,1); }
      
       $ll = get_res();
       if($ll ne '^0')
       {
        print "read $i , $j print format fail.\n";
        last pr_outloop;
       }
       
       if($k)
       {
        print PRF_FILE $j . ' ' . $i . ' ' . $prfcnt . "\n";
       }
       else
       {
        print $j . ' ' . $i . ' ' . $prfcnt . "\n";
       }
      }

    }

     if($k)
     {
      close PRF_FILE;
     }
    }
    else
    {
     sendout('rdprf' . encode($opn[0],4) . encode($opn[1],2) . "\015");
     print "variable is" . encode($opn[0],4) . "\t" . encode($opn[1],2) . "\n";
     $ll = get_res();
     if($ll =~ /^\@/)
     {
      $prf{'item'} = decode(substr($ll,1,2));#���q�B���q�p���I�B����B����p���I��m�K�K�K1��20���ǱƦC
      $prf{'rep'} = decode(substr($ll,3,2));#��{�Φ��G1���Ʀr�B2���r��B3�����X�B7�������r��
      if ( $prf{'rep'} ne 7 )
      {
	      $prf{'x'} = decode(substr($ll,5,4));#�y��x
	      $prf{'y'} = decode(substr($ll,9,4));#�y��y
	      $prf{'sclx'} = decode(substr($ll,13,2));#��j����x
	      $prf{'scly'} = decode(substr($ll,15,2));#��j����y
	      $prf{'orien'} = decode(substr($ll,17,2));#���ਤ��0��0�A1��90�A2��180�A3��270�A��g��4�A�A�ˬ�8
	      $prf{'pm'} = decode(substr($ll,19,2));#or:2,xor:3,and:1
	      $prf{'xbl'} = decode(substr($ll,21,4));
	      $prf{'yu'} = decode(substr($ll,25,4));#�C�L����d�򡧤W��
	      $prf{'xbr'} = decode(substr($ll,29,4));#
	      $prf{'yd'} = decode(substr($ll,33,4));#�C�L���Žd�򡧤U��
	      $prf{'xbitl'} = decode(substr($ll,37,2));
	      $prf{'xbitr'} = decode(substr($ll,39,2));
      }
      
      if( ( $prf{'rep'} eq 2 ) || ( $prf{'rep'} eq 1 ) )
      {#�Y���r���
	      if( ( $prf{'z00'} = decode(substr($ll,41,4) ) ) > 99 )#�r��榡�]�w�e�ix
	      {
		      $prf{'z00'} -= 2 ** 16;
	      }
	      if( ( $prf{'z01'} = decode(substr($ll,45,4) ) ) > 99 )#�r��榡�]�w�e�iy
	      {
		      $prf{'z01'} -= 2 ** 16;
	      }
	      $prf{'z02'} = decode(substr($ll,49,4));#�r��榡�]�w�^�Yx
	      $prf{'z03'} = decode(substr($ll,53,4));#�r��榡�]�w�^�Yy
	      if( ( $prf{'z04'} = decode(substr($ll,57,4) ) ) > 99 )#�r��榡�]�w����x
	      {
		      $prf{'z04'} -= 2 ** 16;
	      }
	      if( ( $prf{'z05'} = decode(substr($ll,61,4) ) ) > 99 )#�r��榡�]�w����y
	      {
		      $prf{'z05'} -= 2 ** 16;
	      }
      }
      
      if( $prf{'rep'} eq 1 )
      {
	      $prf{'z060'} = decode(substr($ll,70,1));#��R�r��
	      $prf{'z06'} = decode(substr($ll,71,2));#�O�_���a�Ÿ�
      }#�Y���Ʀr�]�w�ɨ��R�r���A0���L�����A1���a�Ÿ�

      if( $prf{'rep'} eq 3 )
      {
	      $prf{'z07'} = decode(substr($ll,41,2));#�Y�����X�A����X���A�Gcode128 or Codabar�A�Ȭ�0��7
	      #decode(substr($ll,43,2));�S���Ψ�
	      $prf{'z08'} = decode(substr($ll,45,4));#�D�鰪
	      $prf{'z09'} = decode(substr($ll,49,4));#�@�u��
	      $prf{'z10'} = decode(substr($ll,53,2));#�u�e
	      $prf{'z11'} = decode(substr($ll,55,2));#���e
      }
      if( $prf{'rep'} eq 7 )#�����r��
      {
	      $prf{'z12'} = decode(substr($ll,5,2));#�����r��
	      $prf{'z13'} = decode(substr($ll,7,2));#�_�l
	      $prf{'z14'} = decode(substr($ll,9,2));#����
	      $prf{'z15'} = decode(substr($ll,11,2));#������m
      }
      
					  
      foreach( sort( keys( %prf ) ) ) 
      {
	      print "$_   $prf{$_} \n";
      }

      $i  = 7;
      while( ( ( 2 ** $i-- ) & $prf{'xbitl'} ) eq 0 ){}
      $i = 7 - $i - 1;
      $xl= $prf{'xbl'} * 8 + $i ;
      

      $i = 0;
      while( ( ( 2 ** $i++ ) & $prf{'xbitr'} ) eq 0 ){}
      $xr= $prf{'xbr'} * 8 + $i - 1;
																    
      print "xl :$xl  \n";
      print "xr :$xr  \n";
	  
$xl= undef;
$xr= undef;
%prf = undef;
      
      print $ll  . ( length( $ll ) - 1 ) .  "\n";
     }
     else { print $ll . "\n"; }
    }
   }
   elsif($scmd eq 'label')
   {
    @opn = split(/\s+/,$oprnd);
    sendout('rdlab' . encode($opn[0],2) . "\015");
    $ll = get_res();
    if($ll =~ /^\@/ && length($ll) >= 24)
    {
     $tp = decode(substr($ll,1,2));
     $w = decode(substr($ll,5,4));
     $l = decode(substr($ll,9,4));
     $gap = decode(substr($ll,13,4));
     $bk = decode(substr($ll,17,4));
     $tl = decode(substr($ll,21,4));
     if($tp) { print '�K��' . "\n"; }
     else { print '�s���' . "\n"; }
     print "�ex���G $w x $l\n����: $gap\n�˰h�I��: $bk\n�~�t: $tl\n";
    }
    else { print $ll . "\n"; }
   }
   elsif($scmd eq 'string')
   {
    @opn = split(/\s+/,$oprnd);
    sendout('rdstr' . encode($opn[0],2) . "\015");
    $ll = get_res();
    if($ll =~ /^\@/)
    {
     $j = '';
     $k = 0;
     $i = substr( $ll, 1 );
     while( $tmp = decode( substr( $i, $k, 2 ) ) )
     {
      $k += 2;
      $j .= chr( $tmp );
     }
     print "string:" . $j . "\n";
    }
    else { print $ll . "\n"; }
   }
   else
   {
    print "Syntax error!\n";
   }
  }
  elsif($cmd eq 'write')
  {
   if($scmd eq 'tare')
   {
    chomp($oprnd);
    sendout('wrtar' . encode($oprnd,6) . "\015");
   }
   elsif($scmd eq 'print_format')
   {
    @opn = split(/\s+/,$oprnd);
    if($opn[0] eq 'all')
    {
     if($opn[1] eq '<')
     {
      if(-f $opn[2])
      {
       open PRF_FILE, '< ' . $opn[2];
       while($line = <PRF_FILE>)
       {
        chomp($line);
        @subopn = split(/\s+/,$line);
        sendout('wrprf' . encode($subopn[0],4) . encode($subopn[1],2) .	$subopn[2] . "\015");
        $ll = get_res();
#        $ll =~ s/\015/\012/g;
#        print $ll . "\n";
        chomp($ll);
        if($ll ne '^0')
        {
         print "Print format setting failed .. " . $ll . "\n";
         last;
        }
       }
       close PRF_FILE;
      }
      else
      {
       print "FILE " . $opn[2] . " dose not exist.\n";
      }
     }
    }
    else
    {
     sendout('wrprf' . encode($opn[0],4) . encode($opn[1],2) .
	$opn[2] . "\015");
    }
   }
   elsif($scmd eq 'string' || $scmd eq 'strapp')
   {
    @opn = split(/\s+/,$oprnd,2);
    $opstr = '';
    if($opn[1] =~ /^\</)
    {	# from file
     @opn = split(/\s+/,$oprnd,3);
     if(-f $opn[2])
     {
      open STR_FILE,'< ' . $opn[2];
      $l = 0;
      while($line = <STR_FILE>)
      {
       $l += length($line);
       for($i = 0;$i < length($line);$i++)
       {
        $opstr .= encode(ord(substr($line,$i,1)),2);
       }
      }
      close STR_FILE;
     }
     else
     {
      print "FILE " . $opn[2] . " dose not exist.\n";
     }
    }
    else
    {
     $opn[1] =~ s/\\n/\n/g;
     $opn[1] =~ s/\\/\\\\/g;
     $opn[1] =~ s/\\(.)/$1/g;
     $l = length($opn[1]);
     for($i = 0;$i < $l;$i++)
     {
      $opstr .= encode(ord(substr($opn[1],$i,1)),2);
     }
    }
    if($opstr)
    {
     if($scmd eq 'string') 
     {
      sendout('wrstr' . encode($opn[0],2) . encode($l,2) . $opstr . "\015");
     }
     else 
     {
      sendout('wrsra' . encode($opn[0],2) . encode($l,2) . $opstr . "\015");
     }
    }
   }
#   elsif($scmd eq 'strap')
#   {
#    @opn = split(/\s+/,$oprnd);
#    $opstr = '';
#    if($opn[1] eq '<')
#    {	# from file
#     if(-f $opn[2])
#     {
#      open STR_FILE,'< ' . $opn[2];
#      $l = 0;
#      while($line = <STR_FILE>)
#      {
#       $l += length($line);
#       for($i = 0;$i < length($line);$i++)
#       {
#        $opstr .= encode(ord(substr($line,$i,1)),2);
#       }
#      }
#      close STR_FILE;
#     }
#     else
#     {
#      print "FILE " . $opn[2] . " dose not exist.\n";
#     }
#    }
#    else
#    {
#     $l = length($opn[1]);
#     for($i = 0;$i < $l;$i++)
#     {
#      $opstr .= encode(ord(substr($opn[1],$i,1)),2);
#     }
#    }
#    if($opstr)
#    {
#     sendout('wrsra' . encode($opn[0],2) . encode($l,2) . $opstr . "\015");
#    }
#   }
   else
   {
    print "Syntax error!\n";
   }
  }
  else
  {
   print "Syntax error!\n";
  }
 }
 if( defined( $ll = <SOCK> ) )
 {
  $ll =~ s/\015/\012/g;
  print $ll;
 }
}

close SOCK;

exit 0;

sub encode
{
 my($c,$l,$inp,$i,$rr);

 ($c,$l) = @_;
 $inp = '';
 for($i = 0;$i < $l;$i++)
 {
  $inp .= chr(($c & 0xf) + ord('A'));
  $c >>= 4;
 }
 $rr = '';
 for($i = $l - 1;$i >= 0;$i--)
 {
  $rr .= substr($inp,$i,1);
 }
 return $rr;
}

sub decode		# 2 chars
{
 my($i,$c,$inp,$cc);

 ($inp) = @_;
 for($c = 0,$i = 0;$i < length($inp);$i++)
 {
  $cc = substr($inp,$i,1);
  if(ord($cc) <= ord('P') && ord($cc) >= ord('A'))
  {
   $c <<= 4;
   $c += ord($cc) - ord('A');
  }
 }
 return $c;
}

sub get_res	# get result
{
 my($ln,$ll);

 $ll = '';
 while(1)
 {
  if( defined( $ln = <SOCK>) )
  {
   $ln =~ s/\015/\012/g;
   $ll .= $ln;
   if(substr($ln,-1,1) eq "\n")
   { last; }
  }
 }
 chomp($ll);
 return $ll;
}

sub sendout
{
 my ($str);

 ($str) = @_;
 send(SOCK,$str,0,sockaddr_in($port,$addr));
 print "#\n";
}
