FROM ubuntu:19.10
MAINTAINER Leandro Bugnon <lbugnon@gmail.com>

# Web Demo Builder - Base Docker image for Python 3.x

ENV python_env="/python_env"

# Install base packages
RUN DEBIAN_FRONTEND=noninteractive

# tzdata issue
ENV TZ 'Europe/Amsterdam'
RUN echo $TZ > /etc/timezone && \
  apt-get update && apt-get install -y tzdata && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get clean
  


RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      pkg-config \
      gfortran \
      libatlas-base-dev \
      fonts-lyx \
      libfreetype6-dev \
      libpng-dev \
      python3 \
      python3-dev \
      python3-pip \
      python3-tk \
      tk-dev \
      sudo \
      imagemagick && \
    rm -rf /var/lib/apt/lists/*


# python packages
RUN pip3 install -U virtualenv
RUN virtualenv ${python_env}

COPY install_python_module /usr/local/bin/
RUN install_python_module pip
RUN install_python_module nltk
RUN install_python_module numpy
RUN install_python_module scipy
RUN install_python_module scikit-learn
RUN install_python_module matplotlib
RUN install_python_module pandas
RUN install_python_module PIL
RUN install_python_module torch
RUN install_python_module torchvision
RUN install_python_module ipdb
RUN install_python_module flair

RUN ln -s ${python_env}/bin/python /usr/local/bin/python
RUN [ "/usr/local/bin/python", "-c", "import nltk; nltk.download('punkt')" ]


# Create a new user "developer".
# It will get access to the X11 session in the host computer

ENV uid=1000
ENV gid=${uid}

COPY init.sh /
COPY create_user.sh /
COPY matplotlibrc_tkagg /
COPY matplotlibrc_agg /

ENTRYPOINT ["/init.sh"]
CMD ["/create_user.sh"]

