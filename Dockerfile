FROM alpine
ENV AKAMAI_CLI_HOME=/cli GOROOT=/usr/lib/go GOPATH=/go
RUN mkdir -p /cli/.akamai-cli && mkdir /pipeline
RUN apk add --no-cache git bash python2 python2-dev py2-pip python3 python3-dev npm wget jq openssl openssl-dev curl nodejs build-base libffi libffi-dev util-linux go dep bind-tools 
RUN wget -q `curl -s https://api.github.com/repos/akamai/cli/releases/latest | jq .assets[].browser_download_url | grep linuxamd64 | grep -v sig | sed s/\"//g`

RUN mv akamai-*-linuxamd64 /usr/local/bin/akamai && chmod +x /usr/local/bin/akamai 
RUN go get github.com/akamai/cli && cd $GOPATH/src/github.com/akamai/cli && dep ensure && go build -o /usr/local/bin/akamai && chmod +x /usr/local/bin/akamai 
RUN pip install --upgrade pip

RUN echo 'eval "$(/usr/local/bin/akamai --bash)"' >> /root/.bashrc 
RUN echo "[cli]" > /cli/.akamai-cli/config && \
    echo "cache-path            = /cli/.akamai-cli/cache" >> /cli/.akamai-cli/config && \
    echo "config-version        = 1" >> /cli/.akamai-cli/config && \
    echo "enable-cli-statistics = false" >> /cli/.akamai-cli/config && \
    echo "last-ping             = 2019-03-28T01:56:29Z" >> /cli/.akamai-cli/config && \
    echo "client-id             = github.com/aalquist" >> /cli/.akamai-cli/config && \
    echo "install-in-path       =" >> /cli/.akamai-cli/config && \
    echo "last-upgrade-check    = ignore" >> /cli/.akamai-cli/config

RUN echo "PS1='Akamai CLI Docker[\w]$ '" >> /root/.bashrc 
RUN pip install httpie-edgegrid 
RUN mkdir /root/.httpie 
RUN echo '{' >> /root/.httpie/config.json && \
    echo '"__meta__": {' >> /root/.httpie/config.json && \
    echo '    "about": "HTTPie configuration file", ' >> /root/.httpie/config.json && \
    echo '    "httpie": "1.0.0-dev"' >> /root/.httpie/config.json && \
    echo '}, ' >> /root/.httpie/config.json && \
    echo '"default_options": ["--timeout=300","--style=autumn"], ' >> /root/.httpie/config.json && \
    echo '"implicit_content_type": "json"' >> /root/.httpie/config.json && \
    echo '}' >> /root/.httpie/config.json

VOLUME /root
WORKDIR /root
ENTRYPOINT ["/bin/bash"]