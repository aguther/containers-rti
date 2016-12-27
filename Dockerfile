# define parent
FROM centos:latest

# define maintainer
MAINTAINER Andreas Guther andreas@guther.net

# add RTI Perftest binary package
ADD https://github.com/rticommunity/rtiperftest/releases/download/v2.0/rti_perftest-2.0-rti_connext_dds-5.2.5-x64Linux.tar.gz /rti_perftest-2.0-rti_connext_dds-5.2.5-x64Linux.tar.gz

# extract binary
RUN tar xzf /rti_perftest-2.0-rti_connext_dds-5.2.5-x64Linux.tar.gz

# set stop signal
STOPSIGNAL 9

# define work directory and entrypoint
WORKDIR /perftest-2.0-RTI-Connext-DDS-5.2.5-x64Linux2.6gcc4.1.1
ENTRYPOINT ["/perftest-2.0-RTI-Connext-DDS-5.2.5-x64Linux2.6gcc4.1.1/bin/x64Linux2.6gcc4.1.1/release/perftest_cpp"]
