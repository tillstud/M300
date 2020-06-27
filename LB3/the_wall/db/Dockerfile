# Template: https://gist.github.com/ju2wheels/3d1a1dfa498977874d03

# The FROM instruction sets the Base Image for subsequent instructions.
# As such, a valid Dockerfile must have FROM as its first instruction.
#
# The tag or digest values are optional. If you omit either of them,
# the builder assumes a latest by default.
#
# The scratch image is an empty base container.
#
# FROM <image>[:<tag>|@<digest]
FROM ubuntu:20.04

# The MAINTAINER instruction sets the Author field of the generated images.
# The LABEL instruction is a much more flexible version of this and you should
# use it instead, as it enables setting any metadata you require, and can be
# viewed easily, for example with docker inspect. To set a label 
# corresponding to the MAINTAINER field you could use:
# 
# LABEL maintainer="SvenDowideit@home.org.au"
#
# This will then be visible from docker inspect with the other labels.

# LABEL maintainer=<name>
LABEL maintainer="personal.spareemail@gmail.com"

# The VOLUME instruction creates a mount point with the specified name and
# marks it as holding externally mounted volumes from native host or other
# containers. The value can be a JSON array, VOLUME ["/var/log/"], or a plain
# string with multiple arguments, such as VOLUME /var/log or VOLUME /var/log
# /var/db. 
#
# * The list is parsed as a JSON array, which means that you must use double
#   quotes (") around words not single-quotes (').
#
# VOLUME <mount_point> ...
# VOLUME [ "<mount_point>", ... ]
VOLUME /var/lib/mysql

# The ARG instruction defines a variable that users can pass at build-time to
# the builder with the docker build command using the --build-arg <varname>=<value>
# flag. If a user specifies a build argument that was not defined in the Dockerfile,
# the build outputs an error.
#
# Warning: It is not recommended to use build-time variables for passing secrets like
#          github keys, user credentials etc. Build-time variable values are visible to
#          any user of the image with the docker history command.
#
# Environment variables defined using the ENV instruction always override an ARG
# instruction of the same name.
#
# Docker has a set of predefined ARG variables that you can use without a corresponding
# ARG instruction in the Dockerfile:
#
# * HTTP_PROXY
# * http_proxy
# * HTTPS_PROXY
# * https_proxy
# * FTP_PROXY
# * ftp_proxy
# * NO_PROXY
# * no_proxy
#
# To use these, simply pass them on the command line using the --build-arg <varname>=<value> flag.
#
# ARG variables are not persisted into the built image as ENV variables are. However, ARG variables do
# impact the build cache in similar ways.
#
# ARG <name>[=<default value>]
ARG root_password=S3cr3tp4ssw0rd

# The EXPOSE instructions informs Docker that the container will listen on
# the specified network ports at runtime. Docker uses this information to
# interconnect containers using links (see the Docker User Guide) and to
# determine which ports to expose to the host when using the -P flag.
#
# EXPOSE <port> [<port>...]
EXPOSE 3306

# The COPY instruction copies new files or directories from <src> and adds
# them to the filesystem of the container at the path <dest>.
#
# Multiple <src> resource may be specified but they must be relative to the
# source directory that is being built (the context of the build).
#
# Each <src> may contain wildcards and matching will be done using Go's
# filepath.Match rules.
#
# The <dest> is an absolute path, or a path relative to WORKDIR, into which
# the source will be copied inside the destination container.
#
# All new files and directories are created with a UID and GID of 0.
#
# The copy obeys the following rules:
#
# * The <src> path must be inside the context of the build; you cannot
#   COPY ../something /something, because the first step of a docker build
#   is to send the context directory (and subdirectories) to the docker
#   daemon.
#
# * If <src> is a directory, the entire contents of the directory are copied,
#   including filesystem metadata.
#   - Note: The directory itself is not copied, just its contents.
#
# * If <src> is any other kind of file, it is copied individually along with
#   its metadata. In this case, if <dest> ends with a trailing slash /, it
#   will be considered a directory and the contents of <src> will be written
#   at <dest>/base(<src>).
#
# * If multiple <src> resources are specified, either directly or due to the
#   use of a wildcard, then <dest> must be a directory, and it must end with
#   a slash /.
#
# * If <dest> does not end with a trailing slash, it will be considered a
#   regular file and the contents of <src> will be written at <dest>.
#
# * If <dest> doesn't exist, it is created along with all missing directories
#   in its path.
#
# COPY <src>... <dest>
# COPY ["<src>"... "<dest>"] (this form is required for paths containing
#                             whitespace)
COPY src/db.sh /tmp/db.sh

# The RUN instruction will execute any commands in a new layer on top of
# the current image and commit the results. The resulting committed image
# will be used for the next step in the Dockerfile.
#
# The exec form makes it possible to avoid shell string munging, and to
# RUN commands using a base image that does not contain /bin/sh.
#
# * To use a different shell, other than '/bin/sh', use the exec form
#   passing in the desired shell. For example, RUN ["/bin/bash", "-c",
#   "echo hello"]
# * The exec form is parsed as a JSON array, which means that you must
#   use double-quotes (") around words not single-quotes (').
# * The exec form does not invoke a command shell. This means that normal
#   shell processing like variable substitution does not happen.
#
# Note: To use a different shell, other than ‘/bin/sh’, use the exec form
#       passing in the desired shell. For example, RUN ["/bin/bash", "-c", "echo hello"]
# Note: The exec form is parsed as a JSON array, which means that you must
#       use double-quotes (“) around words not single-quotes (‘).
# Note: Unlike the shell form, the exec form does not invoke a command shell.
#       This means that normal shell processing does not happen. For example,
#       RUN [ "echo", "$HOME" ] will not do variable substitution on $HOME.
#       If you want shell processing then either use the shell form or execute a
#       shell directly, for example: RUN [ "sh", "-c", "echo $HOME" ].
# Note: In the JSON form, it is necessary to escape backslashes. This is particularly
#       relevant on Windows where the backslash is the path separator. The following line
#       would otherwise be treated as shell form due to not being valid JSON, and fail in an
#       unexpected way: RUN ["c:\windows\system32\tasklist.exe"] The correct syntax for this
#       example is: RUN ["c:\\windows\\system32\\tasklist.exe"]
#
# RUN <command> (the command is run in a shell - /bin/sh -c - shell form)
# RUN ["executable", "param1", "param2"] (exec form)


# set root password, so that no dialog pops up
RUN echo 'mysql-server mysql-server/root_password password S3cr3tp4ssw0rd' | debconf-set-selections 
RUN echo 'mysql-server mysql-server/root_password_again password S3cr3tp4ssw0rd' | debconf-set-selections 

# installation
RUN apt-get update && apt-get install -y mysql-server

# open MySQL port
# modify /etc/mysql/mysql.conf.d/mysqld.cnf file via sed so that the MySQL prot is open for all
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN /tmp/db.sh

# Restart for config changes
RUN service mysql restart


# There can only be one CMD instruction in a Dockerfile. If you list more
# than one CMD then only the last CMD will take effect.
#
# The main purpose of a CMD is to provide defaults for an executing container.
# These defaults can include an executable, or they can omit the executable,
# in which case you must specify an ENTRYPOINT instruction as well.
#
# Note: If CMD is used to provide default arguments for the ENTRYPOINT instruction,
#       both the CMD and ENTRYPOINT instructions should be specified with the
#       JSON array format.
# Note: The exec form is parsed as a JSON array, which means that you must
#       use double-quotes (“) around words not single-quotes (‘).
# Note: Unlike the shell form, the exec form does not invoke a command shell.
#       This means that normal shell processing does not happen. For example,
#       CMD [ "echo", "$HOME" ] will not do variable substitution on $HOME.
#       If you want shell processing then either use the shell form or execute a
#       shell directly, for example: CMD [ "sh", "-c", "echo $HOME" ].
#
# If you would like your container to run the same executable every time,
# then you should consider using ENTRYPOINT in combination with CMD. 
#
# CMD ["executable","param1","param2"] (exec form, this is the preferred form)
# CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
# CMD command param1 param2 (shell form)
CMD ["mysqld"]

# Both CMD and ENTRYPOINT instructions define what command gets executed when
# running a container. There are few rules that describe their co-operation.
#
# 1. Dockerfile should specify at least one of CMD or ENTRYPOINT commands.
# 2. ENTRYPOINT should be defined when using the container as an executable.
# 3. CMD should be used as a way of defining default arguments for an ENTRYPOINT command
#    or for executing an ad-hoc command in a container.
# 4. CMD will be overridden when running the container with alternative arguments.

# The STOPSIGNAL instruction sets the system call signal that will be sent to the container to exit.
# This signal can be a valid unsigned number that matches a position in the kernel’s syscall table,
# for instance 9, or a signal name in the format SIGNAME, for instance SIGKILL.
#
# STOPSIGNAL signal
STOPSIGNAL SIGTERM

# The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working.
# This can detect cases such as a web server that is stuck in an infinite loop and unable to handle new
# connections, even though the server process is still running.
#
# When a container has a healthcheck specified, it has a health status in addition to its normal status.
# This status is initially 'starting'. Whenever a health check passes, it becomes 'healthy' (whatever state it
# was previously in). After a certain number of consecutive failures, it becomes 'unhealthy'.
#
# The options that can appear before CMD are:
#
# * --interval=DURATION (default: 30s)
# * --timeout=DURATION (default: 30s)
# * --retries=N (default: 3)
#
# The health check will first run 'interval' seconds after the container is started, and then again
# 'interval' seconds after each previous check completes.
#
# If a single run of the check takes longer than 'timeout' seconds then the check is considered to have failed.
#
# It takes 'retries' consecutive failures of the health check for the container to be considered 'unhealthy'.
#
# There can only be one HEALTHCHECK instruction in a Dockerfile. If you list more than one then only the last
# HEALTHCHECK will take effect.
#
# The command’s exit status indicates the health status of the container. The possible values are:
#
# * 0: success - the container is healthy and ready for use
# * 1: unhealthy - the container is not working correctly
# * 2: reserved - do not use this exit code
#
# To help debug failing probes, any output text (UTF-8 encoded) that the command writes on stdout or
# stderr will be stored in the health status and can be queried with docker inspect. Such output should be kept
# short (only the first 4096 bytes are stored currently).
#
# When the health status of a container changes, a health_status event is generated with the new status.
#
# HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
# HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f localhost:3306 || exit 1