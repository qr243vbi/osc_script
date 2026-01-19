FROM opensuse/tumbleweed
RUN zypper install -y --repo repo-oss git
RUN mkdir /extra /app

WORKDIR /script

ENV OBS_USER a
ENV OBS_PASSWORD a
ENV OBS_PROJECTS a
ENV CONTAINER_RUN yes
USER root
ENTRYPOINT ["bash"]
CMD ["/script/github_actions.sh"]
