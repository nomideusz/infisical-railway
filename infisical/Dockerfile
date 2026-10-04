FROM infisical/infisical:v0.165.16
# Listen on IPv6 too: Railway's private network is IPv6 (upstream binds 0.0.0.0).
ENV HOST=::
COPY --chmod=755 railway-entrypoint.sh /backend/railway-entrypoint.sh
CMD ["./railway-entrypoint.sh"]
