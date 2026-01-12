# Multi-Schema Setup for Umami Analytics

> Blueprint for isolating Umami tables in a custom PostgreSQL schema for multi-tenant Supabase deployments.

---

## Overview

By default, Umami creates tables in the `public` schema. This document describes how to modify Umami to use a custom `umami` schema for better isolation when sharing a Supabase database with other projects.

### Why Use a Custom Schema?

| Benefit | Description |
|---------|-------------|
| **Isolation** | Keep Umami tables separate from other project tables |
| **Organization** | Clear separation of concerns in shared databases |
| **Multi-tenancy** | Run multiple projects in one Supabase instance |
| **Clean Drops** | Easy to remove all Umami tables by dropping the schema |

---

## Prerequisites

- Supabase project with PostgreSQL database
- Access to Supabase SQL Editor
- Forked/cloned Umami repository

---

## Step 1: Run Migration SQL in Supabase

Run the SQL from `docs/migration.sql` in Supabase **SQL Editor**. This will:
- Create the `umami` schema
- Create all 13 tables with indexes
- Create the default admin user (`admin` / `umami`)

See [migration.sql](./migration.sql) for the complete script.

---

## Step 2: Modify Prisma Schema

Edit `prisma/schema.prisma` with the following changes:

### 2.1 Update Generator Block

Add `previewFeatures` for multi-schema support:

```prisma
generator client {
  provider        = "prisma-client"
  output          = "../src/generated/prisma"
  engineType      = "client"
  previewFeatures = ["multiSchema"]
}
```

### 2.2 Update Datasource Block

Add `schemas` array to datasource:

```prisma
datasource db {
  provider     = "postgresql"
  url          = env("DATABASE_URL")
  relationMode = "prisma"
  schemas      = ["umami"]
}
```

### 2.3 Add @@schema to All Models

Add `@@schema("umami")` to each model. The complete list of models and their modifications:

#### User Model
```prisma
model User {
  // ... existing fields ...

  @@schema("umami")
  @@map("user")
}
```

#### Session Model
```prisma
model Session {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("session")
}
```

#### Website Model
```prisma
model Website {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("website")
}
```

#### WebsiteEvent Model
```prisma
model WebsiteEvent {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("website_event")
}
```

#### EventData Model
```prisma
model EventData {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("event_data")
}
```

#### SessionData Model
```prisma
model SessionData {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("session_data")
}
```

#### Team Model
```prisma
model Team {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("team")
}
```

#### TeamUser Model
```prisma
model TeamUser {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("team_user")
}
```

#### Report Model
```prisma
model Report {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("report")
}
```

#### Segment Model
```prisma
model Segment {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("segment")
}
```

#### Revenue Model
```prisma
model Revenue {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("revenue")
}
```

#### Link Model
```prisma
model Link {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("link")
}
```

#### Pixel Model
```prisma
model Pixel {
  // ... existing fields and indexes ...

  @@schema("umami")
  @@map("pixel")
}
```

---

## Step 3: Full Modified Schema Reference

Below is the complete modified `prisma/schema.prisma` file:

```prisma
generator client {
  provider        = "prisma-client"
  output          = "../src/generated/prisma"
  engineType      = "client"
  previewFeatures = ["multiSchema"]
}

datasource db {
  provider     = "postgresql"
  url          = env("DATABASE_URL")
  relationMode = "prisma"
  schemas      = ["umami"]
}

model User {
  id          String    @id @unique @map("user_id") @db.Uuid
  username    String    @unique @db.VarChar(255)
  password    String    @db.VarChar(60)
  role        String    @map("role") @db.VarChar(50)
  logoUrl     String?   @map("logo_url") @db.VarChar(2183)
  displayName String?   @map("display_name") @db.VarChar(255)
  createdAt   DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt   DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt   DateTime? @map("deleted_at") @db.Timestamptz(6)

  websites  Website[]  @relation("user")
  createdBy Website[]  @relation("createUser")
  links     Link[]     @relation("user")
  pixels    Pixel[]    @relation("user")
  teams     TeamUser[]
  reports   Report[]

  @@schema("umami")
  @@map("user")
}

model Session {
  id         String    @id @unique @map("session_id") @db.Uuid
  websiteId  String    @map("website_id") @db.Uuid
  browser    String?   @db.VarChar(20)
  os         String?   @db.VarChar(20)
  device     String?   @db.VarChar(20)
  screen     String?   @db.VarChar(11)
  language   String?   @db.VarChar(35)
  country    String?   @db.Char(2)
  region     String?   @db.VarChar(20)
  city       String?   @db.VarChar(50)
  distinctId String?   @map("distinct_id") @db.VarChar(50)
  createdAt  DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  websiteEvents WebsiteEvent[]
  sessionData   SessionData[]
  revenue       Revenue[]

  @@index([createdAt])
  @@index([websiteId])
  @@index([websiteId, createdAt])
  @@index([websiteId, createdAt, browser])
  @@index([websiteId, createdAt, os])
  @@index([websiteId, createdAt, device])
  @@index([websiteId, createdAt, screen])
  @@index([websiteId, createdAt, language])
  @@index([websiteId, createdAt, country])
  @@index([websiteId, createdAt, region])
  @@index([websiteId, createdAt, city])
  @@schema("umami")
  @@map("session")
}

model Website {
  id        String    @id @unique @map("website_id") @db.Uuid
  name      String    @db.VarChar(100)
  domain    String?   @db.VarChar(500)
  shareId   String?   @unique @map("share_id") @db.VarChar(50)
  resetAt   DateTime? @map("reset_at") @db.Timestamptz(6)
  userId    String?   @map("user_id") @db.Uuid
  teamId    String?   @map("team_id") @db.Uuid
  createdBy String?   @map("created_by") @db.Uuid
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt DateTime? @map("deleted_at") @db.Timestamptz(6)

  user        User?         @relation("user", fields: [userId], references: [id])
  createUser  User?         @relation("createUser", fields: [createdBy], references: [id])
  team        Team?         @relation(fields: [teamId], references: [id])
  eventData   EventData[]
  reports     Report[]
  revenue     Revenue[]
  segments    Segment[]
  sessionData SessionData[]

  @@index([userId])
  @@index([teamId])
  @@index([createdAt])
  @@index([shareId])
  @@index([createdBy])
  @@schema("umami")
  @@map("website")
}

model WebsiteEvent {
  id             String    @id() @map("event_id") @db.Uuid
  websiteId      String    @map("website_id") @db.Uuid
  sessionId      String    @map("session_id") @db.Uuid
  visitId        String    @map("visit_id") @db.Uuid
  createdAt      DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  urlPath        String    @map("url_path") @db.VarChar(500)
  urlQuery       String?   @map("url_query") @db.VarChar(500)
  utmSource      String?   @map("utm_source") @db.VarChar(255)
  utmMedium      String?   @map("utm_medium") @db.VarChar(255)
  utmCampaign    String?   @map("utm_campaign") @db.VarChar(255)
  utmContent     String?   @map("utm_content") @db.VarChar(255)
  utmTerm        String?   @map("utm_term") @db.VarChar(255)
  referrerPath   String?   @map("referrer_path") @db.VarChar(500)
  referrerQuery  String?   @map("referrer_query") @db.VarChar(500)
  referrerDomain String?   @map("referrer_domain") @db.VarChar(500)
  pageTitle      String?   @map("page_title") @db.VarChar(500)
  gclid          String?   @db.VarChar(255)
  fbclid         String?   @db.VarChar(255)
  msclkid        String?   @db.VarChar(255)
  ttclid         String?   @db.VarChar(255)
  lifatid        String?   @map("li_fat_id") @db.VarChar(255)
  twclid         String?   @db.VarChar(255)
  eventType      Int       @default(1) @map("event_type") @db.Integer
  eventName      String?   @map("event_name") @db.VarChar(50)
  tag            String?   @db.VarChar(50)
  hostname       String?   @db.VarChar(100)

  eventData EventData[]
  session   Session     @relation(fields: [sessionId], references: [id])

  @@index([createdAt])
  @@index([sessionId])
  @@index([visitId])
  @@index([websiteId])
  @@index([websiteId, createdAt])
  @@index([websiteId, createdAt, urlPath])
  @@index([websiteId, createdAt, urlQuery])
  @@index([websiteId, createdAt, referrerDomain])
  @@index([websiteId, createdAt, pageTitle])
  @@index([websiteId, createdAt, eventName])
  @@index([websiteId, createdAt, tag])
  @@index([websiteId, sessionId, createdAt])
  @@index([websiteId, visitId, createdAt])
  @@index([websiteId, createdAt, hostname])
  @@schema("umami")
  @@map("website_event")
}

model EventData {
  id             String    @id() @map("event_data_id") @db.Uuid
  websiteId      String    @map("website_id") @db.Uuid
  websiteEventId String    @map("website_event_id") @db.Uuid
  dataKey        String    @map("data_key") @db.VarChar(500)
  stringValue    String?   @map("string_value") @db.VarChar(500)
  numberValue    Decimal?  @map("number_value") @db.Decimal(19, 4)
  dateValue      DateTime? @map("date_value") @db.Timestamptz(6)
  dataType       Int       @map("data_type") @db.Integer
  createdAt      DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  website      Website      @relation(fields: [websiteId], references: [id])
  websiteEvent WebsiteEvent @relation(fields: [websiteEventId], references: [id])

  @@index([createdAt])
  @@index([websiteId])
  @@index([websiteEventId])
  @@index([websiteId, createdAt])
  @@index([websiteId, createdAt, dataKey])
  @@schema("umami")
  @@map("event_data")
}

model SessionData {
  id          String    @id() @map("session_data_id") @db.Uuid
  websiteId   String    @map("website_id") @db.Uuid
  sessionId   String    @map("session_id") @db.Uuid
  dataKey     String    @map("data_key") @db.VarChar(500)
  stringValue String?   @map("string_value") @db.VarChar(500)
  numberValue Decimal?  @map("number_value") @db.Decimal(19, 4)
  dateValue   DateTime? @map("date_value") @db.Timestamptz(6)
  dataType    Int       @map("data_type") @db.Integer
  distinctId  String?   @map("distinct_id") @db.VarChar(50)
  createdAt   DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  website Website @relation(fields: [websiteId], references: [id])
  session Session @relation(fields: [sessionId], references: [id])

  @@index([createdAt])
  @@index([websiteId])
  @@index([sessionId])
  @@index([sessionId, createdAt])
  @@index([websiteId, createdAt, dataKey])
  @@schema("umami")
  @@map("session_data")
}

model Team {
  id         String    @id() @unique() @map("team_id") @db.Uuid
  name       String    @db.VarChar(50)
  accessCode String?   @unique @map("access_code") @db.VarChar(50)
  logoUrl    String?   @map("logo_url") @db.VarChar(2183)
  createdAt  DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt  DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt  DateTime? @map("deleted_at") @db.Timestamptz(6)

  websites Website[]
  members  TeamUser[]
  links    Link[]
  pixels   Pixel[]

  @@index([accessCode])
  @@schema("umami")
  @@map("team")
}

model TeamUser {
  id        String    @id() @unique() @map("team_user_id") @db.Uuid
  teamId    String    @map("team_id") @db.Uuid
  userId    String    @map("user_id") @db.Uuid
  role      String    @db.VarChar(50)
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)

  team Team @relation(fields: [teamId], references: [id])
  user User @relation(fields: [userId], references: [id])

  @@index([teamId])
  @@index([userId])
  @@schema("umami")
  @@map("team_user")
}

model Report {
  id          String    @id() @unique() @map("report_id") @db.Uuid
  userId      String    @map("user_id") @db.Uuid
  websiteId   String    @map("website_id") @db.Uuid
  type        String    @db.VarChar(50)
  name        String    @db.VarChar(200)
  description String    @db.VarChar(500)
  parameters  Json
  createdAt   DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt   DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)

  user    User    @relation(fields: [userId], references: [id])
  website Website @relation(fields: [websiteId], references: [id])

  @@index([userId])
  @@index([websiteId])
  @@index([type])
  @@index([name])
  @@schema("umami")
  @@map("report")
}

model Segment {
  id         String    @id() @unique() @map("segment_id") @db.Uuid
  websiteId  String    @map("website_id") @db.Uuid
  type       String    @db.VarChar(50)
  name       String    @db.VarChar(200)
  parameters Json
  createdAt  DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt  DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)

  website Website @relation(fields: [websiteId], references: [id])

  @@index([websiteId])
  @@schema("umami")
  @@map("segment")
}

model Revenue {
  id        String    @id() @unique() @map("revenue_id") @db.Uuid
  websiteId String    @map("website_id") @db.Uuid
  sessionId String    @map("session_id") @db.Uuid
  eventId   String    @map("event_id") @db.Uuid
  eventName String    @map("event_name") @db.VarChar(50)
  currency  String    @db.VarChar(10)
  revenue   Decimal?  @db.Decimal(19, 4)
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)

  website Website @relation(fields: [websiteId], references: [id])
  session Session @relation(fields: [sessionId], references: [id])

  @@index([websiteId])
  @@index([sessionId])
  @@index([websiteId, createdAt])
  @@index([websiteId, sessionId, createdAt])
  @@schema("umami")
  @@map("revenue")
}

model Link {
  id        String    @id() @unique() @map("link_id") @db.Uuid
  name      String    @db.VarChar(100)
  url       String    @db.VarChar(500)
  slug      String    @unique() @db.VarChar(100)
  userId    String?   @map("user_id") @db.Uuid
  teamId    String?   @map("team_id") @db.Uuid
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt DateTime? @map("deleted_at") @db.Timestamptz(6)

  user User? @relation("user", fields: [userId], references: [id])
  team Team? @relation(fields: [teamId], references: [id])

  @@index([slug])
  @@index([userId])
  @@index([teamId])
  @@index([createdAt])
  @@schema("umami")
  @@map("link")
}

model Pixel {
  id        String    @id() @unique() @map("pixel_id") @db.Uuid
  name      String    @db.VarChar(100)
  slug      String    @unique() @db.VarChar(100)
  userId    String?   @map("user_id") @db.Uuid
  teamId    String?   @map("team_id") @db.Uuid
  createdAt DateTime? @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt DateTime? @updatedAt @map("updated_at") @db.Timestamptz(6)
  deletedAt DateTime? @map("deleted_at") @db.Timestamptz(6)

  user User? @relation("user", fields: [userId], references: [id])
  team Team? @relation(fields: [teamId], references: [id])

  @@index([slug])
  @@index([userId])
  @@index([teamId])
  @@index([createdAt])
  @@schema("umami")
  @@map("pixel")
}
```

---

## Step 4: Environment Variables

### For Vercel (Production)

| Variable | Value | Required |
|----------|-------|----------|
| `DATABASE_URL` | `postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres?schema=umami` | Yes |
| `SKIP_DB_MIGRATION` | `true` | Yes |

**CRITICAL:** The `DATABASE_URL` **MUST** include `?schema=umami` at the end. Without this parameter, Umami will fail with "relation does not exist" errors. See [Troubleshooting](#error-relation-website_event-does-not-exist) for details.

**Important:** `SKIP_DB_MIGRATION=true` is required to prevent the build from hanging. See [Troubleshooting](#build-hangs-after-database-version-check-successful) for details.

### For Local Development

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | `postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres?schema=umami` |

**Note:** The `?schema=umami` parameter is required for both production and local development.

---

## Step 5: Deploy

### Option A: Push to GitHub (Vercel Auto-Deploy)

```bash
git add .
git commit -m "feat: use custom umami schema for multi-tenant isolation"
git push origin main
```

Vercel will automatically deploy.

### Option B: Manual Vercel Deploy

1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your forked repository
3. Add `DATABASE_URL` environment variable
4. Deploy

---

## Verification

After deployment, verify tables are in the `umami` schema:

1. Go to Supabase **Table Editor**
2. Click the schema dropdown (usually shows "public")
3. Select "umami"
4. You should see: `user`, `session`, `website`, `website_event`, etc.

Or run this SQL:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'umami';
```

---

## Troubleshooting

### Build hangs after "Database version check successful"

**Symptom**: Vercel build hangs indefinitely after showing:
```
✓ DATABASE_URL is defined.
✓ Database connection successful.
✓ Database version check successful.
```

**Cause**: This is a [known issue with Umami v3.0.3](https://github.com/umami-software/umami/issues/3914). The `prisma migrate deploy` command in `scripts/check-db.js` hangs when using a custom schema because the existing migrations were written for the `public` schema.

**Solution**:
1. Add environment variable in Vercel: `SKIP_DB_MIGRATION=true`
2. Run `docs/migration.sql` manually in Supabase SQL Editor to create tables
3. Redeploy

### Error: "Failed to execute 'json' on 'Response': Unexpected end of JSON input"

**Symptom**: Login page shows this error when trying to log in.

**Cause**: Database tables don't exist. This happens when `SKIP_DB_MIGRATION=true` is set but the migration SQL wasn't run.

**Solution**: Run `docs/migration.sql` in Supabase SQL Editor to create all tables and the default admin user.

### Error: Schema "umami" does not exist

**Solution**: Run `docs/migration.sql` in Supabase SQL Editor - it includes the CREATE SCHEMA statement.

### Error: Permission denied for schema umami

**Solution**: Grant permissions to the necessary roles:
```sql
GRANT ALL ON SCHEMA umami TO postgres, anon, authenticated, service_role;
```

### Tables created in public instead of umami

**Solution**: Ensure both changes are made:
1. `schemas = ["umami"]` in datasource block
2. `@@schema("umami")` in every model

### Error: relation "website_event" does not exist

**Symptom**: Umami dashboard shows "Something went wrong" errors. Vercel logs show:
```
Error [PrismaClientKnownRequestError]:
Invalid `prisma.$queryRawUnsafe()` invocation:
Raw query failed. Code: `42P01`. Message: `relation "website_event" does not exist`
```

**Cause**: The `DATABASE_URL` is missing the `?schema=umami` query parameter. Even though the Prisma schema has `@@schema("umami")` annotations and the tables exist in the `umami` schema in Supabase, the Umami application code requires the schema to be specified in the connection string.

**Why this happens**: Umami's Prisma client initialization (`src/lib/prisma.ts`) extracts the schema from the URL:

```typescript
function getSchema() {
  const connectionUrl = new URL(process.env.DATABASE_URL);
  return connectionUrl.searchParams.get('schema');  // Returns null if not in URL
}

function getClient() {
  const schema = getSchema();
  const baseAdapter = new PrismaPg({ connectionString: url }, { schema });  // schema is null!
}
```

Without `?schema=umami`, `getSchema()` returns `null`, and all queries go to PostgreSQL's default `public` schema.

**Solution**:
1. Go to Vercel → Settings → Environment Variables
2. Edit `DATABASE_URL` to include `?schema=umami`:
   ```
   postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres?schema=umami
   ```
3. Redeploy the Umami project

**Verified**: January 12, 2026 - This fix resolved the issue for VicSee's Umami deployment.

---

## Updating Umami

When pulling updates from upstream:

1. Sync your fork on GitHub
2. Pull changes locally: `git pull origin main`
3. Check if new models were added to `schema.prisma`
4. Add `@@schema("umami")` to any new models
5. Push and redeploy

---

## Related Files

| File | Purpose |
|------|---------|
| `prisma/schema.prisma` | Database schema definition |
| `prisma.config.ts` | Prisma configuration |
| `.env` / `.env.local` | Environment variables (local) |

---

## References

- [Prisma Multi-Schema Documentation](https://www.prisma.io/docs/orm/prisma-schema/data-model/multi-schema)
- [Supabase Connection Pooling](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler)
- [Umami Self-Hosting Guide](https://umami.is/docs/install)
