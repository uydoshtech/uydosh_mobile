-- =====================================================
-- Uydosh Database Complete Setup Script
-- Generated from migrations _0001 through _0030 and current models
-- Database: uydosh
-- Last updated: 2025-02-24
-- =====================================================

-- Set search path
SET search_path TO public;

-- =====================================================
-- 1. CREATE ENUM TYPES
-- =====================================================

DO $$ BEGIN
  CREATE TYPE subway_line_enum AS ENUM ('chilanzar', 'uzbekiston', 'yunusabad', 'independence');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE enum_users_role AS ENUM ('tenant', 'landlord', 'manager', 'moderator', 'admin', 'service_provider', 'service_requester');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE enum_message_type AS ENUM ('text', 'image', 'file', 'location', 'system');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE enum_complaint_status AS ENUM ('pending', 'resolved', 'dismissed');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- =====================================================
-- 2. CREATE SEQUENCES
-- =====================================================

CREATE SEQUENCE IF NOT EXISTS public.amenities_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.complaint_categories_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.complaints_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.conversations_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.favorites_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.universities_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.fcm_tokens_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.listing_amenities_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.listing_photos_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.listing_types_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.listing_views_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.listings_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.locations_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.message_attachments_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.message_read_status_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.messages_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.otp_codes_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.regions_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.search_analytics_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.subway_stations_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.support_chat_messages_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.support_chat_threads_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.user_achievements_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.user_gamification_stats_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.user_profiles_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.user_saved_searches_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.users_id_seq AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

-- =====================================================
-- 3. CREATE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS public."SequelizeMeta" (
    name character varying(255) NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS public.users (
    id integer NOT NULL DEFAULT nextval('public.users_id_seq'::regclass),
    email character varying(255),
    firebase_uid character varying(255),
    telegram_id character varying(255),
    role enum_users_role DEFAULT NULL,
    is_blocked boolean DEFAULT false NOT NULL,
    blocked_at timestamp without time zone,
    blocked_until timestamp without time zone,
    blocked_reason text,
    blocked_by_admin_id integer,
    search_filters jsonb, -- last home-search ribbon filters (synced from app)
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_firebase_uid_key UNIQUE (firebase_uid),
    CONSTRAINT users_telegram_id_key UNIQUE (telegram_id),
    CONSTRAINT users_blocked_by_admin_id_fkey FOREIGN KEY (blocked_by_admin_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.regions (
    id integer NOT NULL DEFAULT nextval('public.regions_id_seq'::regclass),
    name_uz character varying(200) NOT NULL,
    name_ru character varying(200) NOT NULL,
    name_en character varying(200) NOT NULL,
    short_name_uz character varying(50),
    short_name_ru character varying(50),
    short_name_en character varying(50),
    latitude decimal(10,8) NOT NULL,
    longitude decimal(11,8) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT regions_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.locations (
    id integer NOT NULL DEFAULT nextval('public.locations_id_seq'::regclass),
    name_uz character varying(200) NOT NULL,
    name_ru character varying(200) NOT NULL,
    name_en character varying(200) NOT NULL,
    short_name_uz character varying(50),
    short_name_ru character varying(50),
    short_name_en character varying(50),
    latitude decimal(10,8) NOT NULL,
    longitude decimal(11,8) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT locations_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.subway_stations (
    id integer NOT NULL DEFAULT nextval('public.subway_stations_id_seq'::regclass),
    name_uz character varying(100) NOT NULL,
    name_ru character varying(100) NOT NULL,
    name_en character varying(100) NOT NULL,
    line integer NOT NULL,
    ordinal integer DEFAULT 0,
    location_id integer,
    latitude decimal(10,8),
    longitude decimal(11,8),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT subway_stations_pkey PRIMARY KEY (id),
    CONSTRAINT subway_stations_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.listing_types (
    id integer NOT NULL DEFAULT nextval('public.listing_types_id_seq'::regclass),
    name_uz character varying(50) NOT NULL,
    name_ru character varying(50) NOT NULL,
    name_en character varying(50) NOT NULL,
    code character varying(20) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT listing_types_pkey PRIMARY KEY (id),
    CONSTRAINT listing_types_code_key UNIQUE (code)
);

CREATE TABLE IF NOT EXISTS public.universities (
    id integer NOT NULL DEFAULT nextval('public.universities_id_seq'::regclass),
    name_uz character varying(200) NOT NULL,
    name_ru character varying(200) NOT NULL,
    name_en character varying(200) NOT NULL,
    short_name_uz character varying(100),
    short_name_ru character varying(100),
    short_name_en character varying(100),
    latitude decimal(10,8) NOT NULL,
    longitude decimal(11,8) NOT NULL,
    location_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT universities_pkey PRIMARY KEY (id),
    CONSTRAINT universities_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.listings (
    id integer NOT NULL DEFAULT nextval('public.listings_id_seq'::regclass),
    user_id integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    listing_type_id integer NOT NULL,
    price integer NOT NULL,
    subway_station_id integer,
    subway_line_id integer,
    location_id integer,
    gender integer DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    move_in_date timestamp without time zone,
    private_room boolean DEFAULT false NOT NULL,
    rooms_number integer,
    featured_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT listings_pkey PRIMARY KEY (id),
    CONSTRAINT listings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT listings_listing_type_id_fkey FOREIGN KEY (listing_type_id) REFERENCES public.listing_types(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT listings_subway_station_id_fkey FOREIGN KEY (subway_station_id) REFERENCES public.subway_stations(id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT listings_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id integer NOT NULL DEFAULT nextval('public.user_profiles_id_seq'::regclass),
    user_id integer NOT NULL,
    name character varying(100) NOT NULL,
    gender integer NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    region_id integer,
    university_id integer,
    avatar_url character varying(500),
    telegram character varying(100),
    rating integer,
    about_me text,
    employed boolean,
    cleanliness smallint,
    noise_level smallint,
    sociability smallint,
    guests_allowed boolean,
    smoking_preference character varying(50),
    alcohol_preference character varying(50),
    cooking_habits boolean,
    pets_preference character varying(50),
    wakeup_time character varying(20),
    sleep_time character varying(20),
    preferred_language character varying(10),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
    CONSTRAINT user_profiles_user_id_key UNIQUE (user_id),
    CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT user_profiles_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT user_profiles_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.universities(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.favorites (
    id integer NOT NULL DEFAULT nextval('public.favorites_id_seq'::regclass),
    user_id integer NOT NULL,
    listing_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT favorites_pkey PRIMARY KEY (id),
    CONSTRAINT favorites_user_id_listing_id_key UNIQUE (user_id, listing_id),
    CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT favorites_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.otp_codes (
    id integer NOT NULL DEFAULT nextval('public.otp_codes_id_seq'::regclass),
    email character varying(255) NOT NULL,
    code character varying(4) NOT NULL,
    type character varying(20) DEFAULT 'email_verification' NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT otp_codes_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.complaint_categories (
    id integer NOT NULL DEFAULT nextval('public.complaint_categories_id_seq'::regclass),
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT complaint_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.complaints (
    id integer NOT NULL DEFAULT nextval('public.complaints_id_seq'::regclass),
    complainant_id integer NOT NULL,
    listing_id integer NOT NULL,
    category_id integer NOT NULL,
    text text,
    status enum_complaint_status DEFAULT 'pending' NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT complaints_pkey PRIMARY KEY (id),
    CONSTRAINT complaints_complainant_id_fkey FOREIGN KEY (complainant_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT complaints_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT complaints_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.complaint_categories(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS public.conversations (
    id integer NOT NULL DEFAULT nextval('public.conversations_id_seq'::regclass),
    listing_id integer NOT NULL,
    initiator_id integer NOT NULL,
    participant_id integer NOT NULL,
    last_message_at timestamp without time zone,
    last_message_content text,
    last_message_sender_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT conversations_pkey PRIMARY KEY (id),
    CONSTRAINT conversations_unique_listing_participants UNIQUE (listing_id, initiator_id, participant_id),
    CONSTRAINT conversations_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT conversations_initiator_id_fkey FOREIGN KEY (initiator_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT conversations_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT conversations_last_message_sender_id_fkey FOREIGN KEY (last_message_sender_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.messages (
    id integer NOT NULL DEFAULT nextval('public.messages_id_seq'::regclass),
    conversation_id integer NOT NULL,
    sender_id integer NOT NULL,
    content text NOT NULL,
    previous_content text,
    message_type enum_message_type DEFAULT 'text' NOT NULL,
    reply_to_message_id integer,
    is_edited boolean DEFAULT false NOT NULL,
    edited_at timestamp without time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT messages_pkey PRIMARY KEY (id),
    CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT messages_reply_to_message_id_fkey FOREIGN KEY (reply_to_message_id) REFERENCES public.messages(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.message_attachments (
    id integer NOT NULL DEFAULT nextval('public.message_attachments_id_seq'::regclass),
    message_id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_url character varying(500) NOT NULL,
    file_type character varying(100) NOT NULL,
    file_size bigint,
    mime_type character varying(100),
    thumbnail_url character varying(500),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT message_attachments_pkey PRIMARY KEY (id),
    CONSTRAINT message_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.message_read_status (
    id integer NOT NULL DEFAULT nextval('public.message_read_status_id_seq'::regclass),
    message_id integer NOT NULL,
    user_id integer NOT NULL,
    read_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT message_read_status_pkey PRIMARY KEY (id),
    CONSTRAINT message_read_status_unique UNIQUE (message_id, user_id),
    CONSTRAINT message_read_status_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT message_read_status_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.sessions (
    token character varying(64) NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT sessions_pkey PRIMARY KEY (token),
    CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.amenities (
    id integer NOT NULL DEFAULT nextval('public.amenities_id_seq'::regclass),
    code character varying(50) NOT NULL,
    name_en character varying(100) NOT NULL,
    name_ru character varying(100) NOT NULL,
    name_uz character varying(100) NOT NULL,
    ordinal integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT amenities_pkey PRIMARY KEY (id),
    CONSTRAINT amenities_code_key UNIQUE (code)
);

CREATE TABLE IF NOT EXISTS public.listing_amenities (
    id integer NOT NULL DEFAULT nextval('public.listing_amenities_id_seq'::regclass),
    listing_id integer NOT NULL,
    amenity_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT listing_amenities_pkey PRIMARY KEY (id),
    CONSTRAINT listing_amenities_listing_id_amenity_id_key UNIQUE (listing_id, amenity_id),
    CONSTRAINT listing_amenities_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT listing_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.listing_photos (
    id integer NOT NULL DEFAULT nextval('public.listing_photos_id_seq'::regclass),
    listing_id integer NOT NULL,
    photo_url character varying(500) NOT NULL,
    photo_order integer NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT listing_photos_pkey PRIMARY KEY (id),
    CONSTRAINT listing_photos_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.search_analytics (
    id integer NOT NULL DEFAULT nextval('public.search_analytics_id_seq'::regclass),
    listing_type_id integer,
    location_id integer,
    subway_station_id integer,
    subway_station_ids jsonb,
    subway_line_id integer,
    gender integer,
    min_price decimal(10,2),
    max_price decimal(10,2),
    private_room boolean,
    search_type character varying(50) DEFAULT 'search' NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT search_analytics_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.listing_views (
    id integer NOT NULL DEFAULT nextval('public.listing_views_id_seq'::regclass),
    listing_id integer NOT NULL,
    viewer_user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT listing_views_pkey PRIMARY KEY (id),
    CONSTRAINT listing_views_listing_viewer_unique UNIQUE (listing_id, viewer_user_id),
    CONSTRAINT listing_views_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE,
    CONSTRAINT listing_views_viewer_user_id_fkey FOREIGN KEY (viewer_user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.user_gamification_stats (
    id integer NOT NULL DEFAULT nextval('public.user_gamification_stats_id_seq'::regclass),
    user_id integer NOT NULL,
    streak_count integer DEFAULT 0 NOT NULL,
    last_open_date date,
    has_shared boolean DEFAULT false NOT NULL,
    last_seen_achievement_ids text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT user_gamification_stats_pkey PRIMARY KEY (id),
    CONSTRAINT user_gamification_stats_user_id_key UNIQUE (user_id),
    CONSTRAINT user_gamification_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
    id integer NOT NULL DEFAULT nextval('public.user_achievements_id_seq'::regclass),
    user_id integer NOT NULL,
    achievement_id character varying(64) NOT NULL,
    unlocked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT user_achievements_pkey PRIMARY KEY (id),
    CONSTRAINT user_achievements_user_achievement_unique UNIQUE (user_id, achievement_id),
    CONSTRAINT user_achievements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.support_chat_threads (
    id integer NOT NULL DEFAULT nextval('public.support_chat_threads_id_seq'::regclass),
    user_id integer NOT NULL,
    subject character varying(255),
    status character varying(20) DEFAULT 'open' NOT NULL,
    assigned_support_user_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT support_chat_threads_pkey PRIMARY KEY (id),
    CONSTRAINT support_chat_threads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE,
    CONSTRAINT support_chat_threads_assigned_support_user_id_fkey FOREIGN KEY (assigned_support_user_id) REFERENCES public.users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.support_chat_messages (
    id integer NOT NULL DEFAULT nextval('public.support_chat_messages_id_seq'::regclass),
    thread_id integer NOT NULL,
    sender_user_id integer NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT support_chat_messages_pkey PRIMARY KEY (id),
    CONSTRAINT support_chat_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.support_chat_threads(id) ON DELETE CASCADE,
    CONSTRAINT support_chat_messages_sender_user_id_fkey FOREIGN KEY (sender_user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.fcm_tokens (
    id integer NOT NULL DEFAULT nextval('public.fcm_tokens_id_seq'::regclass),
    user_id integer NOT NULL,
    token text NOT NULL,
    platform character varying(16) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fcm_tokens_pkey PRIMARY KEY (id),
    CONSTRAINT fcm_tokens_token_unique UNIQUE (token),
    CONSTRAINT fcm_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public.user_saved_searches (
    id integer NOT NULL DEFAULT nextval('public.user_saved_searches_id_seq'::regclass),
    user_id integer NOT NULL,
    listing_type_id integer,
    location_id integer,
    subway_station_id integer,
    subway_station_ids jsonb,
    subway_line_id integer,
    gender integer,
    min_price decimal(10,2),
    max_price decimal(10,2),
    private_room boolean,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT user_saved_searches_pkey PRIMARY KEY (id),
    CONSTRAINT user_saved_searches_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- =====================================================
-- 4. CREATE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_amenities_code ON public.amenities USING btree (code);
CREATE INDEX IF NOT EXISTS idx_complaints_complainant_id ON public.complaints USING btree (complainant_id);
CREATE INDEX IF NOT EXISTS idx_complaints_listing_id ON public.complaints USING btree (listing_id);
CREATE INDEX IF NOT EXISTS idx_conversations_listing_id ON public.conversations USING btree (listing_id);
CREATE INDEX IF NOT EXISTS idx_conversations_initiator_id ON public.conversations USING btree (initiator_id);
CREATE INDEX IF NOT EXISTS idx_conversations_participant_id ON public.conversations USING btree (participant_id);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_id ON public.fcm_tokens USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_listing_id ON public.favorites USING btree (listing_id);
CREATE INDEX IF NOT EXISTS idx_listing_amenities_listing_id ON public.listing_amenities USING btree (listing_id);
CREATE INDEX IF NOT EXISTS idx_listing_amenities_amenity_id ON public.listing_amenities USING btree (amenity_id);
CREATE INDEX IF NOT EXISTS idx_listing_photos_listing_id ON public.listing_photos USING btree (listing_id);
CREATE INDEX IF NOT EXISTS idx_listing_views_listing_id ON public.listing_views USING btree (listing_id);
CREATE INDEX IF NOT EXISTS idx_listings_user_id ON public.listings USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_listings_listing_type_id ON public.listings USING btree (listing_type_id);
CREATE INDEX IF NOT EXISTS idx_listings_subway_station_id ON public.listings USING btree (subway_station_id);
CREATE INDEX IF NOT EXISTS idx_listings_location_id ON public.listings USING btree (location_id);
CREATE INDEX IF NOT EXISTS idx_listings_is_active ON public.listings USING btree (is_active);
CREATE INDEX IF NOT EXISTS idx_listings_price ON public.listings USING btree (price);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON public.listings USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_listings_featured_at ON public.listings USING btree (featured_at);
CREATE INDEX IF NOT EXISTS idx_listing_types_code ON public.listing_types USING btree (code);
CREATE INDEX IF NOT EXISTS idx_listing_types_is_active ON public.listing_types USING btree (is_active);
CREATE INDEX IF NOT EXISTS idx_locations_name_uz ON public.locations USING btree (name_uz);
CREATE INDEX IF NOT EXISTS idx_locations_name_ru ON public.locations USING btree (name_ru);
CREATE INDEX IF NOT EXISTS idx_locations_name_en ON public.locations USING btree (name_en);
CREATE INDEX IF NOT EXISTS idx_locations_coordinates ON public.locations USING btree (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_message_attachments_message_id ON public.message_attachments USING btree (message_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages USING btree (conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages USING btree (sender_id);
CREATE INDEX IF NOT EXISTS idx_message_read_status_message_id ON public.message_read_status USING btree (message_id);
CREATE INDEX IF NOT EXISTS idx_message_read_status_user_id ON public.message_read_status USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_otp_codes_email ON public.otp_codes USING btree (email);
CREATE INDEX IF NOT EXISTS idx_otp_codes_expires_at ON public.otp_codes USING btree (expires_at);
CREATE INDEX IF NOT EXISTS idx_search_analytics_subway_station_id ON public.search_analytics USING btree (subway_station_id);
CREATE INDEX IF NOT EXISTS idx_search_analytics_location_id ON public.search_analytics USING btree (location_id);
CREATE INDEX IF NOT EXISTS idx_search_analytics_subway_line_id ON public.search_analytics USING btree (subway_line_id);
CREATE INDEX IF NOT EXISTS idx_search_analytics_created_at ON public.search_analytics USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_subway_stations_line ON public.subway_stations USING btree (line);
CREATE INDEX IF NOT EXISTS idx_subway_stations_line_ordinal ON public.subway_stations USING btree (line, ordinal);
CREATE INDEX IF NOT EXISTS idx_subway_stations_location_id ON public.subway_stations USING btree (location_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_threads_user_id ON public.support_chat_threads USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_threads_status ON public.support_chat_threads USING btree (status);
CREATE INDEX IF NOT EXISTS idx_support_chat_threads_assigned_support_user_id ON public.support_chat_threads USING btree (assigned_support_user_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_messages_thread_id ON public.support_chat_messages USING btree (thread_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_messages_created_at ON public.support_chat_messages USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_universities_location_id ON public.universities USING btree (location_id);
CREATE INDEX IF NOT EXISTS idx_universities_coordinates ON public.universities USING btree (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON public.user_achievements USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_user_gamification_stats_user_id ON public.user_gamification_stats USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_region_id ON public.user_profiles USING btree (region_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_university_id ON public.user_profiles USING btree (university_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_gender ON public.user_profiles USING btree (gender);
CREATE INDEX IF NOT EXISTS idx_user_saved_searches_user_id ON public.user_saved_searches USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_user_saved_searches_created_at ON public.user_saved_searches USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users USING btree (email);

-- =====================================================
-- 5. SET SEQUENCE OWNERSHIP (for tables that use sequences)
-- =====================================================

ALTER SEQUENCE public.amenities_id_seq OWNED BY public.amenities.id;
ALTER SEQUENCE public.complaint_categories_id_seq OWNED BY public.complaint_categories.id;
ALTER SEQUENCE public.complaints_id_seq OWNED BY public.complaints.id;
ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;
ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;
ALTER SEQUENCE public.fcm_tokens_id_seq OWNED BY public.fcm_tokens.id;
ALTER SEQUENCE public.listing_amenities_id_seq OWNED BY public.listing_amenities.id;
ALTER SEQUENCE public.listing_photos_id_seq OWNED BY public.listing_photos.id;
ALTER SEQUENCE public.listing_types_id_seq OWNED BY public.listing_types.id;
ALTER SEQUENCE public.listing_views_id_seq OWNED BY public.listing_views.id;
ALTER SEQUENCE public.listings_id_seq OWNED BY public.listings.id;
ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;
ALTER SEQUENCE public.message_attachments_id_seq OWNED BY public.message_attachments.id;
ALTER SEQUENCE public.message_read_status_id_seq OWNED BY public.message_read_status.id;
ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;
ALTER SEQUENCE public.otp_codes_id_seq OWNED BY public.otp_codes.id;
ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;
ALTER SEQUENCE public.search_analytics_id_seq OWNED BY public.search_analytics.id;
ALTER SEQUENCE public.subway_stations_id_seq OWNED BY public.subway_stations.id;
ALTER SEQUENCE public.support_chat_messages_id_seq OWNED BY public.support_chat_messages.id;
ALTER SEQUENCE public.support_chat_threads_id_seq OWNED BY public.support_chat_threads.id;
ALTER SEQUENCE public.universities_id_seq OWNED BY public.universities.id;
ALTER SEQUENCE public.user_achievements_id_seq OWNED BY public.user_achievements.id;
ALTER SEQUENCE public.user_gamification_stats_id_seq OWNED BY public.user_gamification_stats.id;
ALTER SEQUENCE public.user_profiles_id_seq OWNED BY public.user_profiles.id;
ALTER SEQUENCE public.user_saved_searches_id_seq OWNED BY public.user_saved_searches.id;
ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

-- =====================================================
-- Script completed successfully!
-- =====================================================
