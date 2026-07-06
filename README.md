# Hotel Bookings Infra + DB Reliability

## Setup
1. `docker compose up -d`
2. Wait a few seconds, then seed data: `docker exec -i hotel_db psql -U appuser -d hotel_app < db/seed/seed.sql`
3. Backup: `./scripts/backup.sh`
4. Restore: `./scripts/restore.sh backups/<file>.dump`

## Terraform
- `cd infra/envs/dev && terraform init && terraform fmt -check && terraform validate && terraform plan -var-file=dev.tfvars`
- Same steps in `infra/envs/prod` with `prod.tfvars`

## Index choice

## Query to optimized 

SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;

## The index
CREATE INDEX idx_hotel_bookings_city_created_at
ON hotel_bookings (city, created_at);

The WHERE clause filters on city (equality) and created_at (a range).
Postgres can use a composite index efficiently when the equality column comes first, 
followed by the range column — this lets it jump straight to all delhi rows and then narrow by date using one index scan, 
instead of scanning the whole table. The GROUP BY on org_id, status happens on the small, 
already-filtered result set, so it doesn't need its own index.

## Verifying restore
Compare row counts between `hotel_app` and `hotel_app_restore`.
