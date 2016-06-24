openinfoman-rapidpro
====================

OpenInfoMan RapidPRO

Provides text/SMS for menu based selection of facilities in an organizational hierarchy.  

It makes use of the OpenInfoMan software https://github.com/openhie/openinfoman

Ubuntu Installation
===================
You can easily install on Ubuntu 14.04 and Ubuntu 14.10 using the following commands
<pre>
sudo add-apt-repository ppa:openhie/release
sudo apt-get update
sudo apt-get install openinfoman-rapidpro
</pre>



Manual Installation
===================


Assumes that you have installed BaseX and OpenInfoMan according to:
> https://github.com/openhie/openinfoman/wiki/Install-Instructions


Directions
----------
To get the libarary:
<pre>
cd ~/
git clone https://github.com/openhie/openinfoman-rapidpro
</pre>

Library Module
--------------
There is no library module at the time of writing.


Stored Functions
----------------
To install the stored functions you can do: 
<pre>
cd ~/basex/resources/stored_query_definitions
ln -sf ~/openinfoman-rapidpro/resources/stored_query_definitions/* .
</pre>
Be sure to reload the stored functions: 
> https://github.com/openhie/openinfoman/wiki/Install-Instructions#Loading_Stored_Queries


RapidPro Endpoints
--------------
To make the GET endpoints available:  
<pre>
cd ~/basex/webapp
ln -sf ~/openinfoman-rapidpro/webapp/openinfoman_rapidpro_bindings.xqm
</pre>

