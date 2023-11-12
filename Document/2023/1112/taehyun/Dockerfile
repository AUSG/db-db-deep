FROM mysql:5.7

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=test_group_by

COPY ./query.sql /docker-entrypoint-initdb.d/

CMD ["--max_allowed-packet=32505856"]
