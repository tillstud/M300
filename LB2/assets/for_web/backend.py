#!/usr/bin/python


import cgi, cgitb
form = cgi.FieldStorage()
uname =  form.getvalue('uname')
proposal = form.getvalue('proposal')

f = open("/usr/share/tmp/text.txt", "a")
f.write(f"\n")
f.write(uname + " proposed: " + proposal)
f.close()