FROM perl:5.34
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN cpan install JSON
RUN perl -MCPAN -e "install DBI"
RUN perl -MCPAN -e "install DBD::Pg"
RUN perl -MCPAN -e "install Net::Server"
EXPOSE 8088
CMD [ "perl", "-T", "server.pl", "8088" ]
