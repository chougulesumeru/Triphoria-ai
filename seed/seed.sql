INSERT INTO hotel_bookings (id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT
    gen_random_uuid(),
    (ARRAY['11111111-1111-1111-1111-111111111111',
           '22222222-2222-2222-2222-222222222222',
           '33333333-3333-3333-3333-333333333333']::uuid[])[1 + floor(random()*3)::int],
    'hotel-' || (1 + floor(random()*20))::text,
    (ARRAY['delhi','mumbai','bangalore','goa','chennai'])[1 + floor(random()*5)::int],
    CURRENT_DATE - (floor(random()*60))::int,
    CURRENT_DATE - (floor(random()*60))::int + 2,
    (500 + random()*20000)::numeric(12,2),
    (ARRAY['confirmed','cancelled','completed','pending'])[1 + floor(random()*4)::int],
    NOW() - (floor(random()*45) || ' days')::interval
FROM generate_series(1, 150);

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT id, 'created', '{"source":"seed"}'::jsonb, created_at
FROM hotel_bookings
WHERE random() < 0.6;