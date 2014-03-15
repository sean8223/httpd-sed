A Web Server Written in Sed
===========================

The sed script translates HTTP protocol into shell commands
that return files. It implements the `GET` method as defined in
[RFC 2618](http://www.w3.org/Protocols/rfc2616/rfc2616.html).
Mostly: absolute URIs are not supported, and the Host 
header is required.


Quick Start
===========

1. Create a named pipe; this will connect the shell that executes the
   output of the `httpd.sed` script:

    mkfifo /tmp/httpd.sed.fifo

2. Change to the directory containing the files you want to serve:

    cd /path/to/my/doc/root

3. Start a shell that takes its input from the named pipe created in
   step 1; Start `nc` in listen mode on a port (e.g. 8080) and send
   its output to httpd.sed; close the loop by sending the output
   of http.sed to the named pipe:

    sh < /tmp/httpd.sed.fifo | nc -k -l 8080 | sed -u -n -f httpd.sed > /tmp/httpd.sed.fifo

4. Any files in the docroot are now available via HTTP. `httpd.sed`
   will convert URIs that reference directories to "index.html".


Note: `httpd.sed` requires GNU sed (`gsed` on a Mac). Little or no input
validation is performed beyond basic URL decoding. Use at your own
risk.
