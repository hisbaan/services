# Post Setup

```sh
docker compose exec wallabag su -s /bin/sh nobody -c 'php bin/console wallabag:install --env=prod --no-interaction'
docker compose exec wallabag su -s /bin/sh nobody -c 'php bin/console doctrine:migrations:migrate --env=prod --no-interaction'
```

Fix perms if they're broken

```sh
docker compose exec wallabag sh -lc 'chown -R nobody:nobody /var/www/wallabag/var/sessions /var/www/wallabag/var/cache /var/www/wallabag/var/logs'
```
