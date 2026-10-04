#!/bin/sh
# Start Infisical, then claim the instance for INFISICAL_ADMIN_EMAIL on first boot.
# Upstream leaves /admin/signup open to whoever finds the URL first; the bootstrap
# API creates the admin + organization and turns public sign-up off. On every
# later boot it answers "already set up" and nothing changes.
./standalone-entrypoint.sh &
pid=$!
trap 'kill -TERM $pid; wait $pid; exit' TERM INT

if [ -n "$INFISICAL_ADMIN_EMAIL" ]; then
  until curl -sf -o /dev/null "http://localhost:$PORT/api/status"; do
    kill -0 $pid 2>/dev/null || exit 1
    sleep 1
  done
  node -e '
    const e = process.env;
    fetch(`http://localhost:${e.PORT}/api/v1/admin/bootstrap`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ email: e.INFISICAL_ADMIN_EMAIL, password: e.INFISICAL_ADMIN_PASSWORD, organization: e.INFISICAL_ORGANIZATION || "My Organization" })
    }).then(async (r) => {
      const b = await r.json().catch(() => ({}));
      // Never print the body on success: it carries an admin machine-identity token.
      console.log(r.ok ? `[railway] Admin ${e.INFISICAL_ADMIN_EMAIL} created, public sign-up disabled` : `[railway] Bootstrap skipped: ${b.message}`);
    }).catch((err) => console.log(`[railway] Bootstrap failed: ${err.message}`));
  '
fi
wait $pid
