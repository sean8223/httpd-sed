:reqline {

    /^\(GET \)\(.*\)\( HTTP\/1\.1\)\r$/ {
      s/^\(.*\)\r$/reqline='\1'/
      h
      s/^\(reqline='\)\(GET \)\(.*\)\( HTTP\/1\.1\)'/\3/
      s/?.*$//
      s/%/\\\\x/g
      s/\+/ /g
      s/\(.*\)/uri='\1'/
      H
      n
      b header
    }

    /^\([A-Z]* \)\(.*\)\( HTTP\/1\.1\)\r$/ {
      s/^\(.*\)\r$/reqline='\1'/
      h
      s/.*/code="405"\nreason="Method Not Allowed"/
      H
      b error
    }

    /^\([A-Z]* \)\(.*\)\( HTTP\/\)\(.*\)\r$/ {
      s/^\(.*\)\r$/reqline='\1'/
      h
       s/.*/code="505"\nreason="HTTP Version Not Supported"/
       H
       b error
    }

    /^\r$/ {
      n
      b reqline
    }

   s/.*/code="400"\nreason="Bad Request"/
   H
   b error

}

:header {

   /^Host: / {
     s/^\(Host: \)\(.*\)\r$/host='\2'/
     H
     n
     b header
   }

   /^\(.*\)\(:\)\([ ]*\)\(.*\)\r$/ {
     n
     b header
   }

    /^\r$/ {
       b send
   }	

   s/.*/code=400\nreason="Bad Request"/
   H
   b error

}

:ignore {

    /\([A-Z]* \)\(.*\)\( HTTP\/1\.1\)\r$/ {
    s/^\(.*\)\([A-Z]* \)\(.*\)\( HTTP\/1\.1\)\r$/GET\2\3\4\r/
    b reqline
  }

  n
  b ignore

}

:error {
g
p
i\
cl=0
i\
echo "HTTP/1.1 $code $reason"
i\
echo "Content-Length: $cl"
i\
echo ""
i\
date=`date "+[%d/%b/%Y:%T %z]"`
i\
echo "- - - $date " '"'"$reqline"'"' "$code $cl" 1>&2
n
b ignore
}

:send {
g
p
i\
path=`printf "%b" $uri`
i\
if [ -d $path ]
i\
then
i\
   file=".$path/index.html"
i\
else
i\
   file=.$path
i\
fi
i\
if [ "$host" == "" ]
i\
then
i\
  code=400
i\
  cl=0
i\
  echo "HTTP/1.1 $code Bad Request"
i\
  echo "Content-Length: 0"
i\
  echo ""
i\
elif [ -f "$file" ]
i\
then
i\
   cl=`stat -f "%Uz" $file`
i\
   ct=`file -Ib $file`
i\
   code=200
i\
   echo "HTTP/1.1 $code OK"
i\
   echo "Content-Length: $cl"
i\
   echo "Content-Type: $ct"
i\
   echo ""
i\
   cat $file
i\
else
i\
  code=404
i\
  cl=0
i\
  echo "HTTP/1.1 $code Not Found"
i\
  echo "Content-Length: cl"
i\
  echo ""
i\
fi
i\
date=`date "+[%d/%b/%Y:%T %z]"`
i\
echo "- - - $date " '"'"$reqline"'"' "$code $cl" 1>&2
n
b reqline
}
