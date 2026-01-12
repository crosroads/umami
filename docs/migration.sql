-- Umami Analytics Database Migration
-- Run this in Supabase SQL Editor to create all tables in the 'umami' schema

-- Create schema
CREATE SCHEMA IF NOT EXISTS umami;

-- Grant permissions
GRANT ALL ON SCHEMA umami TO postgres, anon, authenticated, service_role;

-- User table
CREATE TABLE umami."user" (
    user_id UUID PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(60) NOT NULL,
    role VARCHAR(50) NOT NULL,
    logo_url VARCHAR(2183),
    display_name VARCHAR(255),
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6),
    deleted_at TIMESTAMPTZ(6)
);

-- Team table
CREATE TABLE umami.team (
    team_id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    access_code VARCHAR(50) UNIQUE,
    logo_url VARCHAR(2183),
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6),
    deleted_at TIMESTAMPTZ(6)
);

CREATE INDEX team_access_code_idx ON umami.team(access_code);

-- Website table
CREATE TABLE umami.website (
    website_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    domain VARCHAR(500),
    share_id VARCHAR(50) UNIQUE,
    reset_at TIMESTAMPTZ(6),
    user_id UUID REFERENCES umami."user"(user_id),
    team_id UUID REFERENCES umami.team(team_id),
    created_by UUID REFERENCES umami."user"(user_id),
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6),
    deleted_at TIMESTAMPTZ(6)
);

CREATE INDEX website_user_id_idx ON umami.website(user_id);
CREATE INDEX website_team_id_idx ON umami.website(team_id);
CREATE INDEX website_created_at_idx ON umami.website(created_at);
CREATE INDEX website_share_id_idx ON umami.website(share_id);
CREATE INDEX website_created_by_idx ON umami.website(created_by);

-- Session table
CREATE TABLE umami.session (
    session_id UUID PRIMARY KEY,
    website_id UUID NOT NULL,
    browser VARCHAR(20),
    os VARCHAR(20),
    device VARCHAR(20),
    screen VARCHAR(11),
    language VARCHAR(35),
    country CHAR(2),
    region VARCHAR(20),
    city VARCHAR(50),
    distinct_id VARCHAR(50),
    created_at TIMESTAMPTZ(6) DEFAULT NOW()
);

CREATE INDEX session_created_at_idx ON umami.session(created_at);
CREATE INDEX session_website_id_idx ON umami.session(website_id);
CREATE INDEX session_website_id_created_at_idx ON umami.session(website_id, created_at);
CREATE INDEX session_website_id_created_at_browser_idx ON umami.session(website_id, created_at, browser);
CREATE INDEX session_website_id_created_at_os_idx ON umami.session(website_id, created_at, os);
CREATE INDEX session_website_id_created_at_device_idx ON umami.session(website_id, created_at, device);
CREATE INDEX session_website_id_created_at_screen_idx ON umami.session(website_id, created_at, screen);
CREATE INDEX session_website_id_created_at_language_idx ON umami.session(website_id, created_at, language);
CREATE INDEX session_website_id_created_at_country_idx ON umami.session(website_id, created_at, country);
CREATE INDEX session_website_id_created_at_region_idx ON umami.session(website_id, created_at, region);
CREATE INDEX session_website_id_created_at_city_idx ON umami.session(website_id, created_at, city);

-- Website Event table
CREATE TABLE umami.website_event (
    event_id UUID PRIMARY KEY,
    website_id UUID NOT NULL,
    session_id UUID NOT NULL REFERENCES umami.session(session_id),
    visit_id UUID NOT NULL,
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    url_path VARCHAR(500) NOT NULL,
    url_query VARCHAR(500),
    utm_source VARCHAR(255),
    utm_medium VARCHAR(255),
    utm_campaign VARCHAR(255),
    utm_content VARCHAR(255),
    utm_term VARCHAR(255),
    referrer_path VARCHAR(500),
    referrer_query VARCHAR(500),
    referrer_domain VARCHAR(500),
    page_title VARCHAR(500),
    gclid VARCHAR(255),
    fbclid VARCHAR(255),
    msclkid VARCHAR(255),
    ttclid VARCHAR(255),
    li_fat_id VARCHAR(255),
    twclid VARCHAR(255),
    event_type INTEGER NOT NULL DEFAULT 1,
    event_name VARCHAR(50),
    tag VARCHAR(50),
    hostname VARCHAR(100)
);

CREATE INDEX website_event_created_at_idx ON umami.website_event(created_at);
CREATE INDEX website_event_session_id_idx ON umami.website_event(session_id);
CREATE INDEX website_event_visit_id_idx ON umami.website_event(visit_id);
CREATE INDEX website_event_website_id_idx ON umami.website_event(website_id);
CREATE INDEX website_event_website_id_created_at_idx ON umami.website_event(website_id, created_at);
CREATE INDEX website_event_website_id_created_at_url_path_idx ON umami.website_event(website_id, created_at, url_path);
CREATE INDEX website_event_website_id_created_at_url_query_idx ON umami.website_event(website_id, created_at, url_query);
CREATE INDEX website_event_website_id_created_at_referrer_domain_idx ON umami.website_event(website_id, created_at, referrer_domain);
CREATE INDEX website_event_website_id_created_at_page_title_idx ON umami.website_event(website_id, created_at, page_title);
CREATE INDEX website_event_website_id_created_at_event_name_idx ON umami.website_event(website_id, created_at, event_name);
CREATE INDEX website_event_website_id_created_at_tag_idx ON umami.website_event(website_id, created_at, tag);
CREATE INDEX website_event_website_id_session_id_created_at_idx ON umami.website_event(website_id, session_id, created_at);
CREATE INDEX website_event_website_id_visit_id_created_at_idx ON umami.website_event(website_id, visit_id, created_at);
CREATE INDEX website_event_website_id_created_at_hostname_idx ON umami.website_event(website_id, created_at, hostname);

-- Event Data table
CREATE TABLE umami.event_data (
    event_data_id UUID PRIMARY KEY,
    website_id UUID NOT NULL REFERENCES umami.website(website_id),
    website_event_id UUID NOT NULL REFERENCES umami.website_event(event_id),
    data_key VARCHAR(500) NOT NULL,
    string_value VARCHAR(500),
    number_value DECIMAL(19, 4),
    date_value TIMESTAMPTZ(6),
    data_type INTEGER NOT NULL,
    created_at TIMESTAMPTZ(6) DEFAULT NOW()
);

CREATE INDEX event_data_created_at_idx ON umami.event_data(created_at);
CREATE INDEX event_data_website_id_idx ON umami.event_data(website_id);
CREATE INDEX event_data_website_event_id_idx ON umami.event_data(website_event_id);
CREATE INDEX event_data_website_id_created_at_idx ON umami.event_data(website_id, created_at);
CREATE INDEX event_data_website_id_created_at_data_key_idx ON umami.event_data(website_id, created_at, data_key);

-- Session Data table
CREATE TABLE umami.session_data (
    session_data_id UUID PRIMARY KEY,
    website_id UUID NOT NULL REFERENCES umami.website(website_id),
    session_id UUID NOT NULL REFERENCES umami.session(session_id),
    data_key VARCHAR(500) NOT NULL,
    string_value VARCHAR(500),
    number_value DECIMAL(19, 4),
    date_value TIMESTAMPTZ(6),
    data_type INTEGER NOT NULL,
    distinct_id VARCHAR(50),
    created_at TIMESTAMPTZ(6) DEFAULT NOW()
);

CREATE INDEX session_data_created_at_idx ON umami.session_data(created_at);
CREATE INDEX session_data_website_id_idx ON umami.session_data(website_id);
CREATE INDEX session_data_session_id_idx ON umami.session_data(session_id);
CREATE INDEX session_data_session_id_created_at_idx ON umami.session_data(session_id, created_at);
CREATE INDEX session_data_website_id_created_at_data_key_idx ON umami.session_data(website_id, created_at, data_key);

-- Team User table
CREATE TABLE umami.team_user (
    team_user_id UUID PRIMARY KEY,
    team_id UUID NOT NULL REFERENCES umami.team(team_id),
    user_id UUID NOT NULL REFERENCES umami."user"(user_id),
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6)
);

CREATE INDEX team_user_team_id_idx ON umami.team_user(team_id);
CREATE INDEX team_user_user_id_idx ON umami.team_user(user_id);

-- Report table
CREATE TABLE umami.report (
    report_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES umami."user"(user_id),
    website_id UUID NOT NULL REFERENCES umami.website(website_id),
    type VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(500) NOT NULL,
    parameters JSONB NOT NULL,
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6)
);

CREATE INDEX report_user_id_idx ON umami.report(user_id);
CREATE INDEX report_website_id_idx ON umami.report(website_id);
CREATE INDEX report_type_idx ON umami.report(type);
CREATE INDEX report_name_idx ON umami.report(name);

-- Segment table
CREATE TABLE umami.segment (
    segment_id UUID PRIMARY KEY,
    website_id UUID NOT NULL REFERENCES umami.website(website_id),
    type VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    parameters JSONB NOT NULL,
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6)
);

CREATE INDEX segment_website_id_idx ON umami.segment(website_id);

-- Revenue table
CREATE TABLE umami.revenue (
    revenue_id UUID PRIMARY KEY,
    website_id UUID NOT NULL REFERENCES umami.website(website_id),
    session_id UUID NOT NULL REFERENCES umami.session(session_id),
    event_id UUID NOT NULL,
    event_name VARCHAR(50) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    revenue DECIMAL(19, 4),
    created_at TIMESTAMPTZ(6) DEFAULT NOW()
);

CREATE INDEX revenue_website_id_idx ON umami.revenue(website_id);
CREATE INDEX revenue_session_id_idx ON umami.revenue(session_id);
CREATE INDEX revenue_website_id_created_at_idx ON umami.revenue(website_id, created_at);
CREATE INDEX revenue_website_id_session_id_created_at_idx ON umami.revenue(website_id, session_id, created_at);

-- Link table
CREATE TABLE umami.link (
    link_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    url VARCHAR(500) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    user_id UUID REFERENCES umami."user"(user_id),
    team_id UUID REFERENCES umami.team(team_id),
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6),
    deleted_at TIMESTAMPTZ(6)
);

CREATE INDEX link_slug_idx ON umami.link(slug);
CREATE INDEX link_user_id_idx ON umami.link(user_id);
CREATE INDEX link_team_id_idx ON umami.link(team_id);
CREATE INDEX link_created_at_idx ON umami.link(created_at);

-- Pixel table
CREATE TABLE umami.pixel (
    pixel_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    user_id UUID REFERENCES umami."user"(user_id),
    team_id UUID REFERENCES umami.team(team_id),
    created_at TIMESTAMPTZ(6) DEFAULT NOW(),
    updated_at TIMESTAMPTZ(6),
    deleted_at TIMESTAMPTZ(6)
);

CREATE INDEX pixel_slug_idx ON umami.pixel(slug);
CREATE INDEX pixel_user_id_idx ON umami.pixel(user_id);
CREATE INDEX pixel_team_id_idx ON umami.pixel(team_id);
CREATE INDEX pixel_created_at_idx ON umami.pixel(created_at);

-- Create default admin user (password: umami)
-- Password hash is bcrypt of 'umami'
INSERT INTO umami."user" (user_id, username, password, role, created_at)
VALUES (
    gen_random_uuid(),
    'admin',
    '$2b$10$BUli0c.muyCW1ErNJc3jL.vFRFtFJWrT8/GcR4A.sUdCznaXiqFXa',
    'admin',
    NOW()
);
