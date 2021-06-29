from ros:noetic

# install build tools
RUN apt-get update && apt-get install -y \
      python3-catkin-tools \
      python3-osrf-pycommon \
      git \
    && rm -rf /var/lib/apt/lists/*

ENV WORKSPACE=/opt/ros_ws
ARG PACKAGE_NAME=roscpp_tutorials
RUN mkdir -p $WORKSPACE/src
WORKDIR $WORKSPACE

RUN git -C src clone \
      -b noetic-devel \
      https://github.com/ros/ros_tutorials.git

# install ros package dependencies
RUN apt-get update && \
    rosdep update && \
    rosdep install -y \
      --from-paths \
        src/ros_tutorials \
      --ignore-src && \
    rm -rf /var/lib/apt/lists/*

RUN catkin config --extend /opt/ros/$ROS_DISTRO && catkin build $PACKAGE_NAME

# source ros package from entrypoint
RUN sed --in-place --expression \
      '$isource "$WORKSPACE/devel/setup.bash"' \
      /ros_entrypoint.sh

# run ros package launch file
CMD ["roslaunch", "roscpp_tutorials", "talker_listener.launch"]
