FROM chef/inspec

RUN gem install --no-document rake

ENTRYPOINT ["rake"]
CMD ["-T"]
VOLUME ["/share"]
WORKDIR /share
