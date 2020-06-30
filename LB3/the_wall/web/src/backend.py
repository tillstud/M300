#!/usr/bin/python

import cgi, cgitb  # to pars the web input
import mysql.connector  # For Help: https://dev.mysql.com/doc/connector-python/en/connector-python-examples.html
import sys, getopt  # for the CLI


# defining the functions
def connect_sql():
    """creates the connection to the sql server"""
    config = {
      'user': 'www-data',
      'password': 'S3cr3tp4ssw0rd',
      'host': '172.20.0.11',
      'database': 'proposals',
      'raise_on_warnings': True
    }

    cnx = mysql.connector.connect(**config)
    return cnx


def write_sql(uname, proposal):
    """writing to remote MySQL server"""
    cnx = connect_sql()
    cursor = cnx.cursor()

    add_proposal = ("INSERT INTO data "
               "(uname, proposal) "
               "VALUES (%s, %s)")
    data_proposal = (uname, proposal)

    # Insert new proposal
    cursor.execute(add_proposal, data_proposal)
    
    # Make sure data is committed to the database
    cnx.commit()

    cnx.close()
    pass


def read_sql():
    """reading from remote MySQL server"""
    cnx = connect_sql()
    cursor = cnx.cursor()

    query = ("SELECT uname, proposal FROM data")

    cursor.execute(query)

    clear_local()
    for (uname, proposal) in cursor:
      write_local(uname, proposal)

    cnx.close()
    pass


def write_local(uname, proposal):
    """writing input to local tmp file"""
    f = open("/usr/share/tmp/text.txt", "a")
    f.write("\n")
    f.write(str(uname) + " proposed: " + str(proposal))
    f.close()
    pass


def clear_local():
    """clears the local tmp file from the old entries"""
    with open("/usr/share/tmp/text.txt", "w") as f:
        f.write("\n")
    pass


# getting the input from HTML from
form = cgi.FieldStorage()
uname = form.getvalue("uname")
proposal = form.getvalue("proposal")

def cli(argv):
    """This function provides the Comand line interface"""
    uname = ""
    proposal = ""
    try:
       opts, args = getopt.getopt(argv,"h:n:p:",["uname=","proposal="])
    except getopt.GetoptError:
       print ("backend.py -n <uname> -p <proposal>")
       sys.exit(2)
    for opt, arg in opts:
       if opt == "-h":
          print ("backend.py -n <uname> -p <proposal>")
          sys.exit()
       elif opt in ("-n", "--uname"):
          uname = arg
       elif opt in ("-p", "--proposal"):
          proposal = arg
    return uname, proposal

uname, proposal = cli(sys.argv[1:])
write_sql(uname, proposal)
read_sql()
