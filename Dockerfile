FROM grapevinehaus/elixir:1.10.0-alpine-1 as builder
WORKDIR /app/example
ENV MIX_ENV=prod
RUN apk add --no-cache gcc git make musl-dev
RUN mix local.rebar --force && mix local.hex --force
COPY mix.* /app/
COPY example/mix.* /app/example/
RUN mix deps.get --only prod
RUN mix deps.compile

FROM node:12.16 as frontend
WORKDIR /app
COPY example/assets/package.json example/assets/yarn.lock /app/
RUN yarn install
COPY example/assets /app
RUN yarn run deploy

FROM builder as releaser
WORKDIR /app/example
ENV MIX_ENV=prod
COPY --from=frontend /priv/static /app/example/priv/static
COPY . /app/
RUN mix release

FROM alpine:3.11
ENV LANG=C.UTF-8
RUN apk add -U bash openssl
WORKDIR /app
COPY --from=releaser /app/example/_build/prod/rel/kantele /app/
COPY example/data /app/data
EXPOSE 4443
EXPOSE 4444
EXPOSE 4500
ENTRYPOINT ["bin/kantele"]
CMD ["start"]
